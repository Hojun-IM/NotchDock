//
//  OverlaySettingsButton.swift
//  NotchDock
//
//  헤더 오른쪽 끝의 설정 버튼.
//  필터 버튼과 같은 28pt 컨트롤 규격을 쓰되, 아이콘만 SF Symbol 로 대체한 형태다.
//

import SwiftUI

struct OverlaySettingsButton: View {
    /// 클릭 시 실행할 동작. 아직 설정 화면이 없으므로 기본값은 아무것도 하지 않는다.
    let action: () -> Void

    @State private var isHovering = false

    init(action: @escaping () -> Void = {}) {
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: "gearshape.fill")
                .font(.system(size: OverlayMetrics.Header.settingsIconSize, weight: .regular))
                .foregroundStyle(OverlayColors.controlIcon)
                // 필터 버튼과 동일한 28pt 배경을 써서 헤더 오른쪽 끝 정렬을 맞춘다.
                .frame(width: OverlayMetrics.Header.controlSize,
                       height: OverlayMetrics.Header.controlSize)
                .background(isHovering ? OverlayColors.controlHoverBackground : .clear)
                .clipShape(RoundedRectangle(cornerRadius: OverlayMetrics.controlRadius,
                                            style: .continuous))
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
        .animation(OverlayAnimation.hover, value: isHovering)
        .accessibilityLabel("설정")
        .accessibilityIdentifier("overlay-settings-button")
    }
}
