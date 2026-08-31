//
//  OverlayModel.swift
//  NotchDock
//
//  노치/독 프레젠터와 SwiftUI 뷰가 공유하는 상태 모델.
//  프레젠터(AppKit 쪽)가 값을 바꾸면 @Observable 을 통해 뷰가 자동으로 갱신된다.
//

import SwiftUI

@MainActor
@Observable
final class OverlayModel {
    // MARK: - 상태

    /// 현재 오버레이 상태. 프레젠터만 변경한다.
    var state: OverlayState = .hidden

    /// 마우스가 오버레이 콘텐츠 위에 있는지 여부.
    var isHovering: Bool = false

    // MARK: - 화면 기하 정보 (프레젠터가 화면에 맞춰 갱신)

    /// 현재 화면의 노치 크기. 노치가 없으면 가상 노치 크기가 들어온다.
    var notchSize: CGSize = CGSize(width: 220, height: 32)

    /// 현재 화면의 메뉴바 높이. compact 상태에서 호버 시 높이를 늘리는 데 사용한다.
    var menubarHeight: CGFloat = 24

    /// 현재 화면에 실제 물리 노치가 있는지 여부. (UI 미세 조정용)
    var screenHasNotch: Bool = false

    // MARK: - 사용자 설정

    /// 노치에 마우스를 올리면 자동으로 펼칠지 여부.
    var expandsOnHover: Bool = true

    /// 호버 시 햅틱 피드백(트랙패드 진동) 사용 여부.
    var usesHapticFeedback: Bool = true

    // MARK: - 헬퍼

    /// 지정한 화면 기준으로 기하 정보를 갱신한다.
    func updateGeometry(for screen: NSScreen) {
        let notchFrame = screen.effectiveNotchFrame
        notchSize = notchFrame.size
        menubarHeight = max(screen.menubarHeight, notchFrame.height)
        screenHasNotch = screen.hasNotch
    }
}
