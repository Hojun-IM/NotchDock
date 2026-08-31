//
//  DockRootView.swift
//  NotchDock
//
//  독(Dock) 모드의 최상위 뷰.
//  화면 하단에서 떠오르는 반투명 카드.
//   - 닫힘: OverlayMetrics.dockCompactSize (독은 화면 노치와 무관하므로 고정 크기)
//   - 열림: OverlayMetrics.expandedSize (노치 모드와 동일)
//

import SwiftUI

struct DockRootView: View {
    let model: OverlayModel
    let onHoverChange: (Bool) -> Void

    private var size: CGSize {
        OverlayMetrics.size(for: model.state, compact: OverlayMetrics.dockCompactSize)
    }

    private var cornerRadius: CGFloat {
        model.state == .expanded ? 22 : 14
    }

    /// 숨김 상태에서는 카드 높이만큼 아래로 밀어 화면 밖으로 내린다.
    private var yOffset: CGFloat {
        model.state == .hidden ? size.height + 40 : 0
    }

    var body: some View {
        card
            .offset(y: yOffset)
            // 마우스 반응 영역은 패널 전체가 아니라 카드로 한정한다.
            .onHover(perform: onHoverChange)
            // 다른 앱이 활성일 때의 호버 판정은 DockPresenter.hoverZone(on:) 이 담당한다.
            // 패널은 화면 하단에 붙어 있으므로 카드를 아래쪽 중앙에 정렬한다.
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, DockPresenter.bottomPadding)
            .animation(OverlayAnimation.hover, value: model.isHovering)
    }

    private var card: some View {
        content
            .frame(width: size.width, height: size.height)
            .background {
                VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(.white.opacity(0.15), lineWidth: 1)
                    }
            }
            .clipShape(.rect(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(model.state == .hidden ? 0 : 0.35), radius: 24, y: 8)
    }

    @ViewBuilder
    private var content: some View {
        if model.state == .expanded {
            OverlayExpandedView(model: model)
                // 헤더가 카드 좌우 끝까지 닿아야 하므로 바깥 여백을 주지 않는다.
                // (여백이 필요한 본문 영역은 OverlayExpandedView 안에서 처리한다)
                .transition(.overlayExpanded)
        } else {
            OverlayCompactView(model: model)
                .transition(.opacity)
        }
    }
}
