//
//  OverlayHeaderView.swift
//  NotchDock
//
//  확장된 오버레이(노치/독 공통) 최상단의 헤더 줄.
//
//   [전체][Claude][Codex] ················· [설정]
//
//  왼쪽에 에이전트 필터 그룹, 오른쪽에 설정 버튼을 두고 그 사이는 Spacer 로 밀어 둔다.
//  헤더는 좌우 끝까지 꽉 차야 하므로 바깥에서 여백을 주지 않고
//  자기 여백(OverlayMetrics.Header)을 스스로 관리한다.
//
//  현재는 화면(레이아웃·상태 표현)만 구현되어 있고,
//  필터 선택이 실제 콘텐츠를 걸러내거나 설정 창을 여는 동작은 아직 연결되지 않았다.
//

import SwiftUI

struct OverlayHeaderView: View {
    /// 선택된 필터. 헤더는 상태를 소유하지 않고 상위 뷰의 값을 바인딩으로 받는다.
    @Binding var selection: AgentFilter
    /// 설정 버튼 동작.
    let onSettings: () -> Void

    init(selection: Binding<AgentFilter>, onSettings: @escaping () -> Void = {}) {
        self._selection = selection
        self.onSettings = onSettings
    }

    var body: some View {
        HStack(spacing: 0) {
            AgentFilterView(selection: $selection)

            // minLength: 0 을 줘야 오버레이 폭이 줄어드는 애니메이션 중에도
            // Spacer 가 최소 폭을 요구하며 양쪽 버튼을 밀어내지 않는다.
            Spacer(minLength: 0)

            OverlaySettingsButton(action: onSettings)
        }
        .frame(maxWidth: .infinity)
        .frame(height: OverlayMetrics.Header.height)
        .padding(.leading, OverlayMetrics.Header.leadingPadding)
        .padding(.trailing, OverlayMetrics.Header.trailingPadding)
        .accessibilityIdentifier("overlay-header")
    }
}
