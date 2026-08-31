//
//  OverlayPanel.swift
//  NotchDock
//
//  노치/독 UI 를 담는 NSPanel.
//  일반 NSWindow 대신 NSPanel 을 쓰는 이유:
//   - .nonactivatingPanel 스타일로 "앱을 활성화시키지 않고" 마우스 이벤트를 받을 수 있다.
//   - 다른 앱을 사용하는 도중에도 포커스를 빼앗지 않는다.
//

import AppKit

final class OverlayPanel: NSPanel {
    override init(
        contentRect: NSRect,
        styleMask style: NSWindow.StyleMask,
        backing backingStoreType: NSWindow.BackingStoreType,
        defer flag: Bool
    ) {
        super.init(
            contentRect: contentRect,
            styleMask: style,
            backing: backingStoreType,
            defer: flag
        )

        // 배경/그림자는 SwiftUI 쪽에서 직접 그리므로 창 자체는 완전히 투명하게 만든다.
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false

        // 메뉴바/도크보다 위에 떠 있어야 하므로 매우 높은 윈도우 레벨을 사용한다.
        level = .screenSaver

        // 모든 스페이스(가상 데스크탑)에 따라다니고, 미션 컨트롤에서 함께 움직이지 않도록 고정.
        collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary, .ignoresCycle]

        // NSPanel 은 기본값이 hidesOnDeactivate = true 라서,
        // 다른 앱을 클릭하는 순간 오버레이가 사라져 버린다. 항상 떠 있어야 하므로 반드시 꺼 준다.
        hidesOnDeactivate = false

        // 텍스트 입력 등 정말 필요한 경우에만 key 윈도우가 되도록 해서 포커스를 뺏지 않는다.
        becomesKeyOnlyIfNeeded = true

        // 앱 종료 시 자동 해제되지 않도록(수동 생명주기 관리) 설정.
        isReleasedWhenClosed = false
        isMovable = false
        animationBehavior = .none
    }

    /// 텍스트 필드 등 키 입력이 필요한 컨트롤을 담을 수 있도록 key 윈도우가 될 수 있게 허용.
    override var canBecomeKey: Bool { true }

    /// main 윈도우까지 될 필요는 없다. (앱 활성화를 유발하지 않기 위함)
    override var canBecomeMain: Bool { false }

    /// 지정한 크기/위치로 패널을 배치하는 헬퍼.
    func setFrameKeepingTop(_ rect: NSRect) {
        setFrame(rect, display: false)
    }

    /// 알파값을 애니메이션으로 바꾼 뒤 완료를 기다린다. (표시/숨김 시 깜빡임 방지용)
    func animateAlpha(to value: CGFloat, duration: TimeInterval) async {
        await withCheckedContinuation { continuation in
            NSAnimationContext.runAnimationGroup { context in
                context.duration = duration
                context.timingFunction = CAMediaTimingFunction(
                    name: value > 0 ? .easeOut : .easeIn
                )
                animator().alphaValue = value
            } completionHandler: {
                continuation.resume()
            }
        }
    }
}
