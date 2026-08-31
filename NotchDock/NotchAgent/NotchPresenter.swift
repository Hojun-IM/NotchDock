//
//  NotchPresenter.swift
//  NotchDock
//
//  화면 상단 노치에 붙는 오버레이 프레젠터.
//  패널 생명주기/애니메이션은 OverlayPanelPresenter 가 처리하고,
//  여기서는 "어디에 띄울지"와 "무엇을 띄울지"만 결정한다.
//

import AppKit
import SwiftUI

@MainActor
final class NotchPresenter: OverlayPanelPresenter {
    /// 패널을 화면 상단 중앙에 배치한다.
    /// 노치 크기에 딱 맞추지 않고 여유 있게 잡는 이유:
    /// 확장 콘텐츠가 노치보다 훨씬 넓고 길기 때문에, 패널이 작으면 콘텐츠가 잘린다.
    /// (투명 영역은 마우스 이벤트를 가로채지 않으므로 커도 문제되지 않는다.)
    override func panelFrame(on screen: NSScreen) -> NSRect {
        let size = NSSize(
            width: max(screen.frame.width / 2, OverlayMetrics.expandedSize.width + 80),
            height: max(screen.frame.height / 2, OverlayMetrics.expandedSize.height + 80)
        )
        let origin = NSPoint(
            x: screen.frame.midX - (size.width / 2),
            y: screen.frame.maxY - size.height
        )
        return NSRect(origin: origin, size: size)
    }

    /// 호버 판정 영역 = 화면 상단 중앙에 그려지는 노치 본체.
    ///
    /// 닫힘 상태에서는 화면의 실제 노치 영역(effectiveNotchFrame)을 그대로 사용한다.
    /// 이미 상단 중앙 정렬된 화면 좌표라 별도 계산이 필요 없고,
    /// NotchRootView 가 같은 크기로 그리므로 "보이는 영역 = 반응 영역"이 된다.
    override func hoverZone(on screen: NSScreen) -> NSRect {
        guard model.state == .expanded else {
            return screen.effectiveNotchFrame
        }

        let size = OverlayMetrics.expandedSize
        return NSRect(
            x: screen.frame.midX - (size.width / 2),
            y: screen.frame.maxY - size.height,
            width: size.width,
            height: size.height
        )
    }

    override func makeRootView() -> AnyView {
        AnyView(
            NotchRootView(model: model) { [weak self] hovering in
                self?.handleHover(hovering)
            }
        )
    }
}
