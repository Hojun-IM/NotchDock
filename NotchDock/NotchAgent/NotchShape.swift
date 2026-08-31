//
//  NotchShape.swift
//  NotchDock
//
//  노치 형태(위 두 모서리는 안쪽으로, 아래 두 모서리는 바깥쪽으로 둥근 모양)를 그리는 Shape.
//
//        ╭──────────────╮   ← topCornerRadius (바깥쪽으로 파고드는 곡선)
//        │              │
//        ╰──────────────╯   ← bottomCornerRadius (일반적인 둥근 모서리)
//

import SwiftUI

struct NotchShape: Shape {
    /// 상단 모서리 반경. 화면 가장자리와 자연스럽게 이어지는 역곡선.
    private var topCornerRadius: CGFloat
    /// 하단 모서리 반경.
    private var bottomCornerRadius: CGFloat

    init(topCornerRadius: CGFloat, bottomCornerRadius: CGFloat) {
        self.topCornerRadius = topCornerRadius
        self.bottomCornerRadius = bottomCornerRadius
    }

    /// 두 반경 모두 애니메이션 대상이다.
    /// compact ↔ expanded 전환 시 모서리가 부드럽게 변형되도록 해준다.
    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(topCornerRadius, bottomCornerRadius) }
        set {
            topCornerRadius = newValue.first
            bottomCornerRadius = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // 좌측 상단에서 시작해 시계 방향으로 그린다.
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))

        // 좌상단: 화면 가장자리에서 노치 안쪽으로 파고드는 역곡선
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + topCornerRadius, y: rect.minY + topCornerRadius),
            control: CGPoint(x: rect.minX + topCornerRadius, y: rect.minY)
        )

        // 좌측 수직선
        path.addLine(to: CGPoint(x: rect.minX + topCornerRadius, y: rect.maxY - bottomCornerRadius))

        // 좌하단 둥근 모서리
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + topCornerRadius + bottomCornerRadius, y: rect.maxY),
            control: CGPoint(x: rect.minX + topCornerRadius, y: rect.maxY)
        )

        // 하단 수평선
        path.addLine(to: CGPoint(x: rect.maxX - topCornerRadius - bottomCornerRadius, y: rect.maxY))

        // 우하단 둥근 모서리
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - topCornerRadius, y: rect.maxY - bottomCornerRadius),
            control: CGPoint(x: rect.maxX - topCornerRadius, y: rect.maxY)
        )

        // 우측 수직선
        path.addLine(to: CGPoint(x: rect.maxX - topCornerRadius, y: rect.minY + topCornerRadius))

        // 우상단 역곡선
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY),
            control: CGPoint(x: rect.maxX - topCornerRadius, y: rect.minY)
        )

        // 상단 닫기
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))

        return path
    }
}

#Preview {
    NotchShape(topCornerRadius: 6, bottomCornerRadius: 14)
        .frame(width: 220, height: 32)
        .padding(20)
}
