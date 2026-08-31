//
//  OverlayCoordinator.swift
//  NotchDock
//
//  앱 전체에서 하나만 존재하는 오버레이 컨트롤러.
//  - 현재 표시 모드(노치/독)를 보관하고 UserDefaults 에 저장한다.
//  - 모드에 맞는 프레젠터를 만들어 주고, 모드가 바뀌면 상태를 유지한 채 교체한다.
//  상위 UI(메뉴바, 설정 창)는 프레젠터 구현을 몰라도 되고 이 코디네이터만 호출하면 된다.
//

import AppKit
import SwiftUI

@MainActor
@Observable
final class OverlayCoordinator {
    /// 모든 프레젠터가 공유하는 상태/콘텐츠 모델.
    /// 모드를 바꿔도 같은 모델을 넘겨주기 때문에 설정과 콘텐츠가 그대로 유지된다.
    let model = OverlayModel()

    /// 현재 사용 중인 프레젠터.
    private(set) var presenter: any OverlayPresenting

    /// 표시 모드. 변경 시 프레젠터를 교체하고 설정에 저장한다.
    var mode: PresentationMode {
        didSet {
            guard oldValue != mode else { return }
            UserDefaults.standard.set(mode.rawValue, forKey: Self.modeDefaultsKey)
            switchPresenter()
        }
    }

    private static let modeDefaultsKey = "presentationMode"

    init() {
        let savedMode = UserDefaults.standard.string(forKey: Self.modeDefaultsKey)
            .flatMap(PresentationMode.init(rawValue:)) ?? .notch

        self.mode = savedMode
        self.presenter = Self.makePresenter(for: savedMode, model: model)
    }

    /// 현재 오버레이 상태. 뷰에서 관찰할 수 있도록 모델을 경유한다.
    var state: OverlayState { model.state }

    // MARK: - 조작

    /// 앱 시작 시 호출. 최소 상태로 대기시켜 두면 노치에 마우스를 올리는 것만으로 펼칠 수 있다.
    func start() {
        presenter.compact()
    }

    func expand() { presenter.expand() }
    func compact() { presenter.compact() }
    func hide() { presenter.hide() }
    func toggleExpanded() { presenter.toggleExpanded() }

    /// 완전히 숨김 상태라면 다시 대기(최소) 상태로 돌린다.
    func toggleActive() {
        if state == .hidden {
            presenter.compact()
        } else {
            presenter.hide()
        }
    }

    /// 앱 종료 시 패널 정리.
    func shutDown() {
        presenter.tearDown()
    }

    // MARK: - 모드 전환

    /// 기존 프레젠터를 정리하고 새 모드의 프레젠터로 교체한다.
    /// 교체 전 상태를 기억했다가 동일한 상태로 복원해 사용자가 흐름을 잃지 않게 한다.
    private func switchPresenter() {
        let previousState = model.state

        presenter.tearDown()
        presenter = Self.makePresenter(for: mode, model: model)

        switch previousState {
        case .expanded: presenter.expand()
        case .compact: presenter.compact()
        case .hidden: break
        }
    }

    private static func makePresenter(for mode: PresentationMode, model: OverlayModel) -> any OverlayPresenting {
        switch mode {
        case .notch: NotchPresenter(model: model)
        case .dock: DockPresenter(model: model)
        }
    }
}
