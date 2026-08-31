//
//  AgentFilterButton.swift
//  NotchDock
//
//  헤더 왼쪽 필터 그룹을 구성하는 아이콘 버튼 하나.
//  선택 상태와 호버 상태에 따라 배경만 바뀌고, 아이콘 자체는 항상 같은 자리에 있다.
//

import SwiftUI

struct AgentFilterButton: View {
    /// 이 버튼이 나타내는 필터 값.
    let filter: AgentFilter
    /// 현재 이 필터가 선택되어 있는지 여부.
    let isSelected: Bool
    /// 클릭 시 실행할 동작. (선택 값 변경은 부모가 담당한다)
    let action: () -> Void

    /// 마우스 호버 상태. 버튼 하나하나가 각자 관리하므로 @State 로 충분하다.
    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            Image(filter.assetName)
                // SVG 원본 색을 무시하고 단색으로 칠한다.
                // 에셋을 흑백/컬러 중 무엇으로 만들든 UI 색을 코드에서 통제할 수 있다.
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(iconColor)
                // 아이콘은 14pt, 히트 영역과 배경은 28pt.
                // frame 을 두 번 겹쳐, 아이콘은 작게 유지하면서 클릭 영역만 넓힌다.
                .frame(width: OverlayMetrics.Header.iconSize,
                       height: OverlayMetrics.Header.iconSize)
                .frame(width: OverlayMetrics.Header.controlSize,
                       height: OverlayMetrics.Header.controlSize)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: OverlayMetrics.controlRadius,
                                            style: .continuous))
        }
        // 기본 버튼 스타일의 파란 강조/테두리를 없애고 아이콘만 남긴다.
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
        .animation(OverlayAnimation.hover, value: isHovering)
        .animation(OverlayAnimation.hover, value: isSelected)
        .accessibilityLabel(filter.displayName)
        .accessibilityIdentifier("overlay-filter-\(filter.rawValue)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    /// 선택 > 호버 > 기본 순서로 배경을 정한다.
    /// 선택을 호버보다 우선해야, 이미 선택된 버튼 위에 마우스를 올려도 밝기가 떨어지지 않는다.
    private var backgroundColor: Color {
        if isSelected { return OverlayColors.controlSelectedBackground }
        if isHovering { return OverlayColors.controlHoverBackground }
        return .clear
    }

    /// 선택된 버튼만 완전한 흰색으로, 나머지는 한 톤 눌러 표시한다.
    private var iconColor: Color {
        isSelected ? OverlayColors.primaryText : OverlayColors.controlIcon
    }
}
