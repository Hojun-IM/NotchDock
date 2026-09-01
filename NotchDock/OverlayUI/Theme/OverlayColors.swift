//
//  OverlayColors.swift
//  NotchDock
//
//  오버레이(노치/독) 내부 UI 가 공유하는 색상 토큰.
//
//  오버레이 배경은 항상 어두운 색(노치는 검정, 독은 어두운 블러)이므로
//  팔레트는 "흰색 + 불투명도" 조합으로만 구성한다.
//  이렇게 해 두면 배경이 검정이든 블러든 같은 코드로 동일한 대비를 얻을 수 있다.
//
//  색상값을 뷰에 직접 적지 않고 여기 모아 두는 이유:
//   - 호버/선택 같은 상태 색이 여러 컴포넌트에 흩어지면 톤이 금방 어긋난다.
//   - 나중에 "컬러 모드"(에이전트별 액센트 색) 를 추가할 때 이 파일만 바꾸면 된다.
//

import SwiftUI

enum OverlayColors {
    // MARK: - 텍스트 / 아이콘

    /// 기본 전경색. 아이콘과 주요 텍스트에 사용한다.
    static let primaryText = Color.white

    /// 보조 텍스트. 설명이나 비활성 정보에 사용한다.
    static let secondaryText = Color.white.opacity(0.40)

    /// 섹션 제목처럼 정보 위계를 낮춰 표시하는 텍스트.
    static let sectionLabel = Color.white.opacity(0.38)

    /// 리셋 시점처럼 보조적인 상태 정보를 표시하는 텍스트.
    static let sectionHint = Color.white.opacity(0.28)

    /// 아이콘 버튼의 기본 아이콘 색. 완전한 흰색보다 살짝 눌러 두어야
    /// 선택된 항목(primaryText)과 시각적으로 구분된다.
    static let controlIcon = Color.white.opacity(0.70)

    // MARK: - 컨트롤 배경

    /// 마우스를 올렸을 때의 버튼 배경.
    static let controlHoverBackground = Color.white.opacity(0.11)

    /// 선택된 상태의 버튼 배경. 호버보다 한 단계 밝게 잡아
    /// "호버 중인 버튼"과 "현재 선택된 버튼"이 동시에 있어도 구분된다.
    static let controlSelectedBackground = Color.white.opacity(0.14)

    // MARK: - Usage 진행률

    /// 사용량 진행률 바의 바탕.
    static let usageTrack = Color.white.opacity(0.11)

    /// 일반 사용량 진행률.
    static let usageBar = Color.white

    /// 사용량이 높은 구간을 구분하기 위한 진행률.
    static let usageWarning = Color.white.opacity(0.55)

    // MARK: - 구분선

    /// 헤더/푸터와 본문을 나누는 얇은 구분선.
    static let divider = Color.white.opacity(0.07)
}
