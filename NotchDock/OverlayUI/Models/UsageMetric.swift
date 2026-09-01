//
//  UsageMetric.swift
//  NotchDock
//
//  Usage 영역에서 한 행을 표현하기 위한 화면 모델.
//  실제 에이전트 사용량 API가 연결되기 전까지는 샘플 데이터를 제공한다.
//

import Foundation

struct UsageMetric: Identifiable {
    let id: String
    let agent: AgentFilter
    let window: String
    let percentage: Int
    let resetsIn: String

    var percentageLabel: String {
        "\(percentage)%"
    }

}

extension UsageMetric {
    /// HTML 가이드의 레이아웃과 정보 밀도를 확인하기 위한 임시 표시 데이터.
    static let previewData: [UsageMetric] = [
        UsageMetric(
            id: "claude-5h",
            agent: .claude,
            window: "5H",
            percentage: 62,
            resetsIn: "1H 54M"
        ),
        UsageMetric(
            id: "claude-week",
            agent: .claude,
            window: "WEEK",
            percentage: 41,
            resetsIn: "2D 4H"
        ),
        UsageMetric(
            id: "codex-5h",
            agent: .codex,
            window: "5H",
            percentage: 88,
            resetsIn: "36M"
        ),
        UsageMetric(
            id: "codex-week",
            agent: .codex,
            window: "WEEK",
            percentage: 27,
            resetsIn: "4D 2H"
        )
    ]
}
