//
//  OverlayContentView.swift
//  NotchDock
//
//  노치 모드와 독 모드가 공유하는 콘텐츠 영역.
//  여기에 한 번 구현하면 두 모드 모두에 그대로 반영된다.
//
//  레이아웃 규칙
//   - 헤더는 좌우 끝까지 꽉 차야 하므로 이 뷰는 바깥 여백 없이 배치된다.
//     (NotchRootView / DockRootView 는 상단 노치 여백만 책임진다)
//   - 좌우 여백이 필요한 본문 영역만 OverlayMetrics.contentInset 을 적용한다.
//

import SwiftUI

/// 오버레이가 펼쳐졌을 때 보이는 본문 영역.
/// 전체 크기는 OverlayMetrics.expandedSize 에서 결정되며, 이 뷰는 그 안을 채우기만 한다.
struct OverlayExpandedView: View {
    let model: OverlayModel

    /// 헤더의 필터 선택 상태.
    ///
    /// 아직 실제 데이터와 연결되지 않은 "화면 전용" 상태라 여기서 로컬로 들고 있다.
    /// 나중에 필터가 본문 데이터를 실제로 걸러내게 되면 OverlayModel 로 옮겨서
    /// 프레젠터/설정 창과도 공유해야 한다.
    @State private var selectedFilter: AgentFilter = .all

    var body: some View {
        VStack(spacing: 0) {
            OverlayHeaderView(selection: $selectedFilter) {
                // TODO: 설정 창 열기 연결.
            }

            // TODO: 실제 본문 콘텐츠 구현 위치.
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, OverlayMetrics.contentInset)
                .padding(.bottom, OverlayMetrics.contentInset)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// 최소(compact) 상태의 콘텐츠 영역.
/// 노치 모드에서는 노치 자체가 UI 이므로 기본적으로 비워 둔다.
struct OverlayCompactView: View {
    let model: OverlayModel

    var body: some View {
        Color.clear
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
