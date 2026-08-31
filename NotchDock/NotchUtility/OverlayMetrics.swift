//
//  OverlayMetrics.swift
//  NotchDock
//
//  오버레이의 고정 크기 값을 한 곳에서 관리한다.
//  노치/독 두 모드가 같은 값을 참조하므로, 여기만 바꾸면 양쪽 크기가 함께 변경된다.
//

import Foundation

enum OverlayMetrics {
    /// 펼쳐졌을 때 크기. (노치·독 공통)
    static let expandedSize = CGSize(width: 680, height: 420)

    /// 닫혔을(최소) 때 크기. = 노치 크기
    static let compactSize = CGSize(width: 160, height: 30)

    /// 확장 콘텐츠 영역의 안쪽 여백.
    static let contentInset: CGFloat = 16

    /// 상태에 맞는 크기를 돌려준다. 숨김 상태는 최소 크기로 수축시켜 자연스럽게 사라지게 한다.
    ///
    /// 이 값은 "화면에 그려지는 크기"인 동시에 "마우스 호버 판정 영역"으로도 쓰인다.
    /// (각 프레젠터의 hoverZone(on:) 참고) 따라서 여기 값만 바꾸면 그림과 반응 영역이 항상 일치한다.
    static func size(for state: OverlayState) -> CGSize {
        state == .expanded ? expandedSize : compactSize
    }
}
