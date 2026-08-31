//
//  NSScreen+Notch.swift
//  NotchDock
//
//  화면(NSScreen)에서 노치 / 메뉴바 관련 기하 정보를 계산하는 확장.
//  노치가 없는 맥에서도 동일한 인터페이스로 동작하도록 "가상 노치" 폴백을 제공한다.
//

import AppKit

extension NSScreen {
    /// 현재 마우스 커서가 올라가 있는 화면.
    /// 멀티 디스플레이 환경에서 "사용자가 보고 있는 화면"에 노치를 띄울 때 사용한다.
    static var withMouse: NSScreen? {
        let mouseLocation = NSEvent.mouseLocation
        return NSScreen.screens.first { NSMouseInRect(mouseLocation, $0.frame, false) }
    }

    /// 오버레이를 띄울 기본 화면.
    /// 마우스가 있는 화면 → 주 화면 → 첫 번째 화면 순으로 폴백한다.
    static var preferredForOverlay: NSScreen {
        withMouse ?? NSScreen.main ?? NSScreen.screens[0]
    }

    /// 이 화면에 물리적인 노치(카메라 하우징)가 존재하는지 여부.
    /// macOS 는 노치 좌/우의 사용 가능 영역을 auxiliaryTop*Area 로 알려주는데,
    /// 이 값이 존재한다는 것 자체가 노치가 있다는 뜻이다.
    var hasNotch: Bool {
        auxiliaryTopLeftArea != nil && auxiliaryTopRightArea != nil
    }

    /// 물리 노치의 크기. 노치가 없으면 nil.
    /// - 너비: 전체 화면 너비에서 좌/우 여백(auxiliary area)을 뺀 값
    /// - 높이: 상단 safe area inset (= 노치 높이)
    var notchSize: CGSize? {
        guard
            let leftPadding = auxiliaryTopLeftArea?.width,
            let rightPadding = auxiliaryTopRightArea?.width
        else {
            return nil
        }
        return CGSize(
            width: frame.width - leftPadding - rightPadding,
            height: safeAreaInsets.top
        )
    }

    /// 메뉴바 높이. (전체 프레임 상단 - 사용 가능한 영역 상단)
    var menubarHeight: CGFloat {
        frame.maxY - visibleFrame.maxY
    }

    /// 실제로 UI 를 붙일 노치 영역.
    /// 노치가 없는 화면에서는 메뉴바 높이를 가진 "가상 노치"를 화면 상단 중앙에 만들어 반환한다.
    /// 덕분에 노치 유무와 관계없이 동일한 레이아웃 코드를 사용할 수 있다.
    var effectiveNotchFrame: CGRect {
        if let notchSize {
            return CGRect(
                x: frame.midX - (notchSize.width / 2),
                y: frame.maxY - notchSize.height,
                width: notchSize.width,
                height: notchSize.height
            )
        }

        // 노치가 없는 경우: OverlayMetrics 의 폴백 크기로 가상 노치를 만든다.
        // (메뉴바가 더 두꺼우면 메뉴바 높이를 따라가 화면 상단에 자연스럽게 붙게 한다.)
        let fallbackWidth = OverlayMetrics.fallbackNotchSize.width
        let fallbackHeight = max(menubarHeight, OverlayMetrics.fallbackNotchSize.height)
        return CGRect(
            x: frame.midX - (fallbackWidth / 2),
            y: frame.maxY - fallbackHeight,
            width: fallbackWidth,
            height: fallbackHeight
        )
    }
}
