//
//  OverlayTransitions.swift
//  NotchDock
//
//  콘텐츠가 나타나고 사라질 때 쓰는 커스텀 트랜지션.
//  블러 + 스케일 조합으로 "노치 안에서 녹아 나오는" 느낌을 만든다.
//

import SwiftUI

/// 블러 반경을 애니메이션하는 모디파이어.
private struct BlurModifier: ViewModifier {
    let radius: CGFloat

    func body(content: Content) -> some View {
        content.blur(radius: radius)
    }
}

/// x/y 축을 개별적으로 스케일하는 모디파이어. (기본 .scale 은 축 분리가 안 됨)
private struct AxisScaleModifier: ViewModifier {
    let x: CGFloat
    let y: CGFloat
    let anchor: UnitPoint

    func body(content: Content) -> some View {
        content.scaleEffect(x: x, y: y, anchor: anchor)
    }
}

extension AnyTransition {
    /// 사라질 때 흐려지는 트랜지션.
    static func blur(radius: CGFloat) -> AnyTransition {
        .modifier(
            active: BlurModifier(radius: radius),
            identity: BlurModifier(radius: 0)
        )
    }

    /// 축별 스케일 트랜지션.
    static func axisScale(x: CGFloat = 1, y: CGFloat = 1, anchor: UnitPoint = .center) -> AnyTransition {
        .modifier(
            active: AxisScaleModifier(x: x, y: y, anchor: anchor),
            identity: AxisScaleModifier(x: 1, y: 1, anchor: anchor)
        )
    }

    /// 확장 콘텐츠용: 위쪽 기준으로 눌리면서 흐려진다.
    static var overlayExpanded: AnyTransition {
        .blur(radius: 10)
            .combined(with: .axisScale(y: 0.6, anchor: .top))
            .combined(with: .opacity)
    }

    /// compact 좌/우 콘텐츠용: 노치 쪽(anchor)으로 빨려 들어가며 사라진다.
    static func overlayCompact(anchor: UnitPoint) -> AnyTransition {
        .blur(radius: 10)
            .combined(with: .axisScale(x: 0, anchor: anchor))
            .combined(with: .opacity)
    }
}
