//
//  UsageView.swift
//  NotchDock
//
//  확장 오버레이 본문의 Usage 영역.
//
//  HTML 가이드 레이아웃
//   USAGE                              RESETS IN
//   [아이콘] 5H   [진행률] 62%            1H 54M
//

import SwiftUI

/// 선택된 에이전트의 사용량을 행 목록으로 보여주는 영역.
struct UsageView: View {
    fileprivate static let resetColumnWidth: CGFloat = 88

    let selectedFilter: AgentFilter
    let metrics: [UsageMetric]

    init(
        selectedFilter: AgentFilter,
        metrics: [UsageMetric] = UsageMetric.previewData
    ) {
        self.selectedFilter = selectedFilter
        self.metrics = metrics
    }

    private var visibleMetrics: [UsageMetric] {
        metrics.filter { metric in
            selectedFilter == .all || metric.agent == selectedFilter
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text("USAGE")
                    .font(.system(size: 10, weight: .semibold, design: .default))
                    .tracking(1.6)
                    .foregroundStyle(OverlayColors.sectionLabel)

                Spacer(minLength: 0)

                Text("RESETS IN")
                    .font(.system(size: 10, weight: .regular, design: .monospaced))
                    .tracking(0.8)
                    .foregroundStyle(OverlayColors.sectionHint)
                    .frame(width: Self.resetColumnWidth, alignment: .trailing)
            }
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("usage-section-header")
            .padding(.bottom, 8)

            VStack(spacing: 5) {
                ForEach(visibleMetrics) { metric in
                    UsageRow(metric: metric)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("usage-section")
    }
}

private struct UsageRow: View {
    let metric: UsageMetric

    var body: some View {
        HStack(spacing: 10) {
            Image(metric.agent.assetName)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(OverlayColors.primaryText)
                .frame(width: 15, height: 15)
                .frame(width: 16, height: 16)

            Text(metric.window)
                .font(.system(size: 10, weight: .regular, design: .monospaced))
                .tracking(0.8)
                .foregroundStyle(OverlayColors.secondaryText)
                .frame(width: 66, alignment: .leading)

            UsageProgressBar(value: metric.percentage)

            Text(metric.percentageLabel)
                .font(.system(size: 11, weight: .regular, design: .monospaced))
                .foregroundStyle(OverlayColors.primaryText)
                .monospacedDigit()
                .frame(width: 40, alignment: .trailing)

            Text(metric.resetsIn)
                .font(.system(size: 10, weight: .regular, design: .monospaced))
                .foregroundStyle(OverlayColors.secondaryText)
                .monospacedDigit()
                .lineLimit(1)
                .frame(width: UsageView.resetColumnWidth, alignment: .trailing)
        }
        .frame(height: 22)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("usage-row-\(metric.id)")
    }
}

private struct UsageProgressBar: View {
    let value: Int

    private var normalizedValue: CGFloat {
        CGFloat(min(max(value, 0), 100)) / 100
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(OverlayColors.usageTrack)

                Capsule()
                    .fill(value >= 85 ? OverlayColors.usageWarning : OverlayColors.usageBar)
                    .frame(width: proxy.size.width * normalizedValue)
            }
        }
        .frame(height: 5)
        .accessibilityElement()
        .accessibilityLabel("사용량")
        .accessibilityValue("\(value)%")
        .accessibilityIdentifier("usage-progress-\(value)")
    }
}
