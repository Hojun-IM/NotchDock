//
//  OverlayState.swift
//  NotchDock
//
//  오버레이(노치/독)의 표시 상태와 공용 애니메이션 정의.
//

import SwiftUI

/// 오버레이의 3단계 상태. Dynamic Island 의 상태 모델을 그대로 따른다.
enum OverlayState: Equatable, CaseIterable {
    /// 완전히 숨김. 이 상태에서는 패널 자체를 제거한다.
    case hidden
    /// 최소 상태. 노치 모드에서는 노치 좌/우에 작은 콘텐츠만 노출한다.
    case compact
    /// 확장 상태. 본문 콘텐츠 전체를 노치 아래로 펼친다.
    case expanded

    var isVisible: Bool { self != .hidden }
}

/// 상태 전환에 사용하는 애니메이션 모음.
/// 값을 한 곳에서 관리해야 노치/독 두 모드의 느낌이 일관되게 유지된다.
enum OverlayAnimation {
    /// 숨김 → 표시. 살짝 튕기는 느낌으로 "펼쳐지는" 인상을 준다.
    static let opening: Animation = .bouncy(duration: 0.4)
    /// 표시 → 숨김. 튕김 없이 부드럽게 접힌다.
    static let closing: Animation = .smooth(duration: 0.4)
    /// compact ↔ expanded 전환.
    static let conversion: Animation = .snappy(duration: 0.4)
    /// 호버 등 미세한 상태 변화.
    static let hover: Animation = .snappy(duration: 0.25)

    /// 상태 변화가 화면에 반영되는 데 걸리는 대략적인 시간(초).
    static let duration: TimeInterval = 0.4
    /// 숨김 애니메이션 후 패널을 실제로 제거하기까지 기다리는 시간(초).
    static let teardownDelay: TimeInterval = 0.25
    /// 패널 페이드 인/아웃 시간(초).
    static let fadeDuration: TimeInterval = 0.15
}
