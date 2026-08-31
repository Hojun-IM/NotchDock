//
//  AgentFilter.swift
//  NotchDock
//
//  헤더 왼쪽의 에이전트 필터 탭이 가질 수 있는 값.
//
//  지금은 "어떤 아이콘을 어떤 순서로 보여줄지"를 결정하는 화면 전용 모델이다.
//  (실제 세션/사용량 데이터를 걸러내는 기능은 아직 붙어 있지 않다.)
//  allCases 의 선언 순서가 그대로 화면상의 버튼 순서가 되므로 순서를 바꾸지 않는다.
//

import Foundation

enum AgentFilter: String, CaseIterable, Identifiable, Equatable {
    /// 전체 보기. 항상 가장 왼쪽에 둔다.
    case all
    case claude
    case codex

    var id: String { rawValue }

    /// 접근성(VoiceOver) 라벨로만 쓰는 이름.
    /// 헤더에는 아이콘만 보이므로 화면에 직접 그려지지는 않는다.
    var displayName: String {
        switch self {
        case .all: "전체"
        case .claude: "클로드 코드"
        case .codex: "코덱스"
        }
    }

    /// Assets.xcassets 에 등록된 아이콘 이름.
    ///
    /// 에셋 이름을 뷰가 아니라 모델에서 관리해야, 에셋 이름이 바뀌어도
    /// 이 한 곳만 고치면 된다. (모두 template 렌더링용 단색 SVG)
    var assetName: String {
        switch self {
        case .all: "All Icon"
        case .claude: "Claude Icon"
        case .codex: "Codex Icon"
        }
    }
}
