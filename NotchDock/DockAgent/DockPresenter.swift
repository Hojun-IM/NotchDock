//
//  DockPresenter.swift
//  NotchDock
//
//  화면 하단에서 떠오르는 독(Dock) 형태의 프레젠터.
//  설정에서 PresentationMode 를 .dock 으로 바꾸면 NotchPresenter 대신 이 프레젠터가 사용된다.
//
//  NotchPresenter 와의 차이는 "패널 위치"와 "루트 뷰"뿐이며,
//  상태 머신·애니메이션·화면 변경 대응은 모두 OverlayPanelPresenter 에서 공유한다.
//

import AppKit
import SwiftUI

@MainActor
final class DockPresenter: OverlayPanelPresenter {
    /// 카드와 화면 아래쪽 사이의 여백. DockRootView 의 padding(.bottom) 과 동일해야 한다.
    static let bottomPadding: CGFloat = 12

    /// 패널이 차지할 최대 크기. 확장 크기(680 × 420)보다 넉넉하게 잡아 그림자/애니메이션 여유를 둔다.
    private let panelSize = NSSize(
        width: OverlayMetrics.expandedSize.width + 80,
        height: OverlayMetrics.expandedSize.height + 80
    )

    /// 화면 하단 중앙(사용 가능 영역 기준)에 배치한다.
    /// visibleFrame 을 쓰면 실제 macOS Dock 위에 자연스럽게 얹힌다.
    override func panelFrame(on screen: NSScreen) -> NSRect {
        let width = min(panelSize.width, screen.visibleFrame.width)
        let origin = NSPoint(
            x: screen.visibleFrame.midX - (width / 2),
            y: screen.visibleFrame.minY
        )
        return NSRect(origin: origin, size: NSSize(width: width, height: panelSize.height))
    }

    /// 호버 판정 영역 = 화면 하단 중앙에 그려지는 카드.
    /// DockRootView 의 bottom padding(12) 과 값을 맞춰야 한다.
    override func hoverZone(on screen: NSScreen) -> NSRect {
        let size = OverlayMetrics.size(for: model.state)
        return NSRect(
            x: screen.visibleFrame.midX - (size.width / 2),
            y: screen.visibleFrame.minY + Self.bottomPadding,
            width: size.width,
            height: size.height
        )
    }

    override func makeRootView() -> AnyView {
        AnyView(
            DockRootView(model: model) { [weak self] hovering in
                self?.handleHover(hovering)
            }
        )
    }
}
