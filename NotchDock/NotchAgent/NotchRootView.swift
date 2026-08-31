//
//  NotchRootView.swift
//  NotchDock
//
//  노치 패널의 최상위 SwiftUI 뷰.
//  검은 배경 위에 NotchShape 마스크를 씌워, 화면 상단에서 노치가 자라나는 것처럼 보이게 한다.
//
//  크기는 OverlayMetrics 의 고정값을 따른다.
//   - 닫힘: 140 × 30
//   - 열림: 680 × 420
//

import SwiftUI

struct NotchRootView: View {
    let model: OverlayModel
    /// 마우스 진입/이탈을 프레젠터에 알리는 콜백.
    let onHoverChange: (Bool) -> Void

    // MARK: - 크기 / 모서리

    /// 현재 상태에 대응하는 크기. 상태 변경이 애니메이션되면 이 값도 함께 보간된다.
    private var size: CGSize {
        OverlayMetrics.size(for: model.state)
    }

    /// 확장 상태의 모서리 반경. 넓게 펼쳐지므로 더 둥글게 잡는다.
    private var expandedRadii: (top: CGFloat, bottom: CGFloat) { (15, 20) }
    /// 최소 상태의 모서리 반경. 실제 노치 곡률에 가깝게 맞춘 값.
    private var compactRadii: (top: CGFloat, bottom: CGFloat) { (6, 14) }

    private var topCornerRadius: CGFloat {
        model.state == .expanded ? expandedRadii.top : compactRadii.top
    }

    private var bottomCornerRadius: CGFloat {
        model.state == .expanded ? expandedRadii.bottom : compactRadii.bottom
    }

    // MARK: - 그림자

    private var shadowOpacity: CGFloat {
        guard model.state == .expanded else { return 0 }
        return model.isHovering ? 0.8 : 0.5
    }

    private var shadowRadius: CGFloat {
        switch model.state {
        case .hidden: 0
        case .compact: 6
        case .expanded: model.isHovering ? 20 : 10
        }
    }

    // MARK: - Body

    var body: some View {
        notchBody
            // 패널은 화면 상단 중앙을 덮고 있으므로, 노치는 그 위쪽에 붙인다.
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .foregroundStyle(.white)
            .tint(.white)
            .animation(OverlayAnimation.hover, value: model.isHovering)
    }

    private var notchBody: some View {
        content
            .frame(width: size.width, height: size.height)
            .background {
                // 노치 본체. 애니메이션이 오버슈트해도 검정이 끊기지 않도록 넉넉히 확장한다.
                Rectangle()
                    .fill(.black)
                    .padding(-60)
            }
            .mask {
                NotchShape(
                    topCornerRadius: topCornerRadius,
                    bottomCornerRadius: bottomCornerRadius
                )
                .frame(width: size.width, height: size.height)
            }
            .shadow(color: .black.opacity(shadowOpacity), radius: shadowRadius)
            // 마우스 반응 영역은 노치 본체로 한정된다. (패널의 나머지 투명 영역은 무시)
            .onHover(perform: onHoverChange)
            // 참고: 다른 앱이 활성일 때는 .onHover 가 동작하지 않는다.
            // 그 경우의 호버 판정은 NotchPresenter.hoverZone(on:) + 좌표 폴링이 담당한다.
    }

    // MARK: - 콘텐츠

    @ViewBuilder
    private var content: some View {
        if model.state == .expanded {
            OverlayExpandedView(model: model)
                // 상단에는 실제 노치 높이만큼 여백을 두어 콘텐츠가 노치에 가리지 않게 한다.
                .padding(.top, model.notchSize.height)
                .padding(.horizontal, OverlayMetrics.contentInset)
                .padding(.bottom, OverlayMetrics.contentInset)
                .transition(.overlayExpanded)
        } else {
            OverlayCompactView(model: model)
                .transition(.opacity)
        }
    }
}
