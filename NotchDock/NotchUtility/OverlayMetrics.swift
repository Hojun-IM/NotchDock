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

    /// 아이콘 버튼 같은 작은 컨트롤의 모서리 반경.
    static let controlRadius: CGFloat = 8

    /// 확장 오버레이 상단 헤더의 치수.
    ///
    /// 헤더는 좌우 끝까지 꽉 차게 배치하고(= contentInset 을 적용하지 않고)
    /// 자기 여백을 스스로 관리한다. 왼쪽(필터)과 오른쪽(설정)의 여백이 다른 이유는
    /// 필터 아이콘은 버튼 배경이 아이콘보다 크게 잡혀 있어 시각적으로 이미 여백을
    /// 갖고 있기 때문이다. 숫자를 같게 맞추면 오히려 왼쪽이 더 떠 보인다.
    enum Header {
        /// 헤더 줄의 높이.
        static let height: CGFloat = 52
        /// 노치 모드에서 헤더 줄을 화면 최상단에서 얼마나 내릴지.
        ///
        /// 물리 노치(카메라 하우징)는 화면 "가운데"에만 있고 헤더 항목은 좌우 끝에 있으므로,
        /// 콘텐츠 전체를 노치 높이(약 30~38pt)만큼 내릴 필요가 없다. 그렇게 하면 헤더가
        /// 필요 이상으로 아래로 밀려 본문이 좁아진다. 최상단에 딱 붙지만 않을 만큼만 띄운다.
        static let notchTopInset: CGFloat = 0
        /// 왼쪽(필터 그룹) 바깥 여백.
        static let leadingPadding: CGFloat = 14
        /// 오른쪽(설정 버튼) 바깥 여백.
        static let trailingPadding: CGFloat = 18
        /// 필터 버튼 사이 간격.
        static let itemSpacing: CGFloat = 4
        /// 아이콘 버튼의 히트 영역 겸 배경 크기.
        static let controlSize: CGFloat = 28
        /// 필터 아이콘(SVG) 자체의 크기.
        static let iconSize: CGFloat = 14
        /// 설정 톱니 아이콘(SF Symbol)의 폰트 크기.
        static let settingsIconSize: CGFloat = 17
    }

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
