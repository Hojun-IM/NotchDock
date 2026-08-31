//
//  AgentFilterView.swift
//  NotchDock
//
//  헤더 왼쪽의 필터 버튼 그룹(전체 / Claude / Codex).
//  버튼 배열과 선택 상태 전달만 담당하고, 버튼 모양은 AgentFilterButton 이 책임진다.
//

import SwiftUI

struct AgentFilterView: View {
    /// 현재 선택된 필터. 상위 뷰가 소유하는 상태를 바인딩으로 받는다.
    @Binding var selection: AgentFilter

    var body: some View {
        // AgentFilter.allCases 의 선언 순서를 그대로 따른다. (전체가 가장 왼쪽)
        HStack(spacing: OverlayMetrics.Header.itemSpacing) {
            ForEach(AgentFilter.allCases) { filter in
                AgentFilterButton(filter: filter, isSelected: selection == filter) {
                    selection = filter
                }
            }
        }
        .accessibilityIdentifier("overlay-filter-group")
    }
}
