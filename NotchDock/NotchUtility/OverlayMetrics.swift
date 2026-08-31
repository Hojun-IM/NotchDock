//
//  OverlayMetrics.swift
//  NotchDock
//
//  오버레이의 고정 크기 값을 한 곳에서 관리한다.
//
//  닫힘(compact) 크기는 모드마다 기준이 다르다.
//   - 노치 모드: 화면의 "실제 노치 크기"(NSScreen.effectiveNotchFrame)를 따른다.
//               노치가 없는 화면에서만 아래 fallbackNotchSize 를 쓴다.
//   - 독 모드:   화면과 무관한 고정 크기(dockCompactSize)를 쓴다.
//

import Foundation

enum OverlayMetrics {
    /// 펼쳐졌을 때 크기. (노치·독 공통)
    static let expandedSize = CGSize(width: 680, height: 420)

    /// 노치가 없는 화면에서 사용할 가상 노치 크기.
    /// NSScreen.effectiveNotchFrame 의 폴백 값으로도 쓰인다.
    static let fallbackNotchSize = CGSize(width: 160, height: 30)

    /// 독 모드에서 닫혀 있을 때의 알약 크기.
    static let dockCompactSize = CGSize(width: 160, height: 30)

    /// 확장 콘텐츠 영역의 안쪽 여백.
    static let contentInset: CGFloat = 16

    /// 상태에 맞는 크기를 돌려준다. 숨김 상태는 닫힘 크기로 수축시켜 자연스럽게 사라지게 한다.
    ///
    /// 이 값은 "화면에 그려지는 크기"인 동시에 "마우스 호버 판정 영역"으로도 쓰인다.
    /// (각 프레젠터의 hoverZone(on:) 참고) 따라서 같은 compact 값을 넘기는 한
    /// 그림과 반응 영역은 항상 일치한다.
    ///
    /// - Parameter compact: 해당 모드의 닫힘 크기. 노치 모드는 실제 노치 크기를 넘긴다.
    static func size(for state: OverlayState, compact: CGSize) -> CGSize {
        state == .expanded ? expandedSize : compact
    }
}
