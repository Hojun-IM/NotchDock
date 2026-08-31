//
//  OverlayPanelPresenter.swift
//  NotchDock
//
//  NSPanel 생명주기 + 상태 전환 애니메이션을 담당하는 공통 베이스 클래스.
//  노치/독 프레젠터는 이 클래스를 상속해서 "패널을 어디에 둘지"와 "어떤 뷰를 넣을지"만 정의하면 된다.
//
//  서브클래스가 반드시 오버라이드해야 하는 것
//   - panelFrame(on:)  : 패널이 차지할 화면상 영역
//   - makeRootView()   : 패널에 넣을 SwiftUI 루트 뷰
//

import AppKit
import SwiftUI

@MainActor
class OverlayPanelPresenter: OverlayPresenting {
    /// 뷰와 공유하는 상태 모델.
    let model: OverlayModel

    /// 현재 떠 있는 패널. 숨김 상태에서는 nil 이다.
    private(set) var panel: OverlayPanel?

    /// 패널이 올라가 있는 화면. 화면이 바뀌면 패널을 새로 만든다.
    private(set) var currentScreen: NSScreen?

    /// 숨김 애니메이션 후 패널을 제거하는 작업.
    private var teardownTask: Task<Void, Never>?

    /// 호버가 끝난 뒤 compact 로 되돌리는 작업.
    private var collapseTask: Task<Void, Never>?

    /// 디스플레이 구성 변경(해상도/외부 모니터 연결) 옵저버.
    private var screenObserver: NSObjectProtocol?

    /// 다른 앱이 활성일 때도 마우스 위치를 추적하기 위한 폴링 작업.
    /// SwiftUI 의 .onHover 와 NSEvent 전역 모니터는 모두 "우리 앱이 활성일 때"나
    /// 샌드박스 조건에 따라 동작하지 않을 수 있어서, 가장 확실한 방법인 좌표 폴링을 사용한다.
    private var hoverTrackingTask: Task<Void, Never>?

    /// 마우스 위치를 확인하는 주기(초). 60ms 면 체감상 즉각적이면서 비용도 무시할 수준이다.
    private let hoverPollingInterval: TimeInterval = 0.06

    /// 호버가 끝나고 접히기까지의 유예 시간(초). 마우스가 잠깐 벗어나도 바로 닫히지 않게 한다.
    private let collapseDelay: TimeInterval = 0.35

    init(model: OverlayModel) {
        self.model = model
        observeScreenChanges()
    }

    deinit {
        if let screenObserver {
            NotificationCenter.default.removeObserver(screenObserver)
        }
    }

    var state: OverlayState { model.state }

    // MARK: - 서브클래스 오버라이드 지점

    /// 패널이 차지할 프레임. 콘텐츠는 이 안에서 SwiftUI 정렬로 배치된다.
    /// 화면 전체를 덮지 않는 이유는, 불필요하게 큰 투명 창이 성능/이벤트에 영향을 주기 때문이다.
    func panelFrame(on screen: NSScreen) -> NSRect {
        fatalError("서브클래스에서 구현해야 합니다.")
    }

    /// 패널에 호스팅할 SwiftUI 루트 뷰.
    func makeRootView() -> AnyView {
        fatalError("서브클래스에서 구현해야 합니다.")
    }

    /// 마우스가 들어오면 "호버"로 판정할 화면상 영역. (AppKit 좌표계: 좌하단이 원점)
    /// 콘텐츠가 실제로 그려지는 사각형과 일치해야 한다.
    func hoverZone(on screen: NSScreen) -> NSRect {
        fatalError("서브클래스에서 구현해야 합니다.")
    }

    // MARK: - OverlayPresenting

    func expand(on screen: NSScreen) {
        transition(to: .expanded, on: screen)
    }

    func compact(on screen: NSScreen) {
        transition(to: .compact, on: screen)
    }

    func hide() {
        guard model.state != .hidden else { return }

        collapseTask?.cancel()
        teardownTask?.cancel()

        withAnimation(OverlayAnimation.closing) {
            model.state = .hidden
            model.isHovering = false
        }

        // 접히는 애니메이션이 끝난 뒤 페이드아웃 → 패널 제거 순으로 정리한다.
        // 곧바로 닫으면 애니메이션이 잘려 깜빡이는 것처럼 보인다.
        teardownTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(OverlayAnimation.teardownDelay))
            guard !Task.isCancelled, let self else { return }

            await panel?.animateAlpha(to: 0, duration: OverlayAnimation.fadeDuration)
            guard !Task.isCancelled else { return }

            destroyPanel()
        }
    }

    func tearDown() {
        collapseTask?.cancel()
        teardownTask?.cancel()
        model.state = .hidden
        model.isHovering = false
        destroyPanel()
    }

    // MARK: - 상태 전환

    private func transition(to newState: OverlayState, on screen: NSScreen) {
        guard model.state != newState else { return }

        teardownTask?.cancel()

        // 패널이 없거나 다른 화면으로 이동해야 하면 새로 만든다.
        let needsNewPanel = panel == nil || currentScreen != screen

        if needsNewPanel {
            model.updateGeometry(for: screen)
            createPanel(on: screen)

            // 창을 띄우기 "전에" 애니메이션을 시작해야 첫 프레임이 튀지 않는다.
            withAnimation(OverlayAnimation.opening) {
                model.state = newState
            }

            showPanel()
        } else {
            withAnimation(OverlayAnimation.conversion) {
                model.state = newState
            }

            // 숨김 도중 다시 호출된 경우를 대비해 알파를 되돌린다.
            if let panel, panel.alphaValue < 1 {
                Task { await panel.animateAlpha(to: 1, duration: 0.1) }
            }
        }
    }

    // MARK: - 호버 처리

    /// 루트 뷰에서 전달받은 마우스 진입/이탈 처리.
    func handleHover(_ hovering: Bool) {
        guard model.state != .hidden, hovering != model.isHovering else { return }

        withAnimation(OverlayAnimation.hover) {
            model.isHovering = hovering
        }

        if hovering, model.usesHapticFeedback {
            NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .default)
        }

        guard model.expandsOnHover else { return }
        collapseTask?.cancel()

        if hovering {
            // 최소 상태에서 마우스를 올리면 펼친다.
            if model.state == .compact {
                expand(on: currentScreen ?? .preferredForOverlay)
            }
        } else if model.state == .expanded {
            // 마우스가 벗어나면 잠깐 기다렸다가 접는다.
            let delay = collapseDelay
            collapseTask = Task { [weak self] in
                try? await Task.sleep(for: .seconds(delay))
                guard !Task.isCancelled, let self else { return }
                guard !model.isHovering, model.state == .expanded else { return }
                compact(on: currentScreen ?? .preferredForOverlay)
            }
        }
    }

    // MARK: - 패널 관리

    private func createPanel(on screen: NSScreen) {
        destroyPanel()

        // 패널을 만들 때부터 최종 크기를 넘겨준다.
        // .zero 로 만든 뒤 나중에 setFrame 하면 NSHostingView 가 0 크기로 남아 콘텐츠가 그려지지 않는다.
        let frame = panelFrame(on: screen)

        let panel = OverlayPanel(
            contentRect: frame,
            // borderless: 타이틀바 없음 / nonactivatingPanel: 클릭해도 앱이 활성화되지 않음
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        let hostingView = NSHostingView(rootView: makeRootView())
        hostingView.frame = NSRect(origin: .zero, size: frame.size)
        // 패널 크기가 바뀌어도 콘텐츠가 따라오도록 오토리사이징을 켠다.
        hostingView.autoresizingMask = [.width, .height]
        panel.contentView = hostingView

        panel.setFrameKeepingTop(frame)
        panel.layoutIfNeeded()

        self.panel = panel
        currentScreen = screen

        startHoverMonitor()
    }

    private func showPanel() {
        guard let panel else { return }

        // 첫 프레임의 레이아웃 흔들림을 감추기 위해 투명 상태로 띄운 뒤 페이드인한다.
        panel.alphaValue = 0
        // orderFrontRegardless: 앱이 비활성 상태여도 화면 앞으로 올린다.
        panel.orderFrontRegardless()

        Task { await panel.animateAlpha(to: 1, duration: OverlayAnimation.fadeDuration) }
    }

    private func destroyPanel() {
        stopHoverMonitor()
        panel?.orderOut(nil)
        panel?.contentView = nil
        panel?.close()
        panel = nil
        currentScreen = nil
    }

    // MARK: - 전역 호버 감지

    /// 패널이 떠 있는 동안 주기적으로 마우스가 오버레이 영역 안에 있는지 검사한다.
    private func startHoverMonitor() {
        guard hoverTrackingTask == nil else { return }

        let interval = hoverPollingInterval
        hoverTrackingTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(interval))
                guard !Task.isCancelled, let self else { return }
                updateHoverFromMouseLocation()
            }
        }
    }

    private func stopHoverMonitor() {
        hoverTrackingTask?.cancel()
        hoverTrackingTask = nil
    }

    /// 현재 마우스 좌표가 오버레이 영역 안에 있는지 판정한다.
    private func updateHoverFromMouseLocation() {
        guard let screen = currentScreen else { return }
        handleHover(hoverZone(on: screen).contains(NSEvent.mouseLocation))
    }

    // MARK: - 화면 변경 대응

    /// 해상도 변경, 외부 디스플레이 연결/해제 시 패널 위치를 다시 계산한다.
    private func observeScreenChanges() {
        screenObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.reloadForCurrentScreen()
            }
        }
    }

    private func reloadForCurrentScreen() {
        guard model.state.isVisible else { return }

        let screen = currentScreen.flatMap { screen in
            NSScreen.screens.contains(screen) ? screen : nil
        } ?? .preferredForOverlay

        model.updateGeometry(for: screen)
        currentScreen = screen
        panel?.setFrameKeepingTop(panelFrame(on: screen))
    }
}
