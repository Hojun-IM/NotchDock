//
//  OverlayContentView.swift
//  NotchDock
//
//  노치 모드와 독 모드가 공유하는 콘텐츠 영역.
//  현재는 비어 있는 껍데기이며, 앞으로 들어갈 UI 를 여기에 한 번만 구현하면
//  두 모드 모두에 그대로 반영된다.
//

import SwiftUI

/// 오버레이가 펼쳐졌을 때 보이는 본문 영역.
/// 크기는 OverlayMetrics.expandedSize 에서 결정되며, 이 뷰는 그 안을 채우기만 한다.
struct OverlayExpandedView: View {
    let model: OverlayModel

    var body: some View {
        // TODO: 실제 콘텐츠 구현 위치.
        Color.clear
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
