//
//  OverlayPresenting.swift
//  NotchDock
//
//  "노치"와 "독"이 공통으로 따르는 프레젠터 인터페이스.
//  코디네이터는 이 프로토콜만 알고 있으면 되므로,
//  나중에 Dock 모드(또는 또 다른 형태)를 추가해도 상위 코드는 바뀌지 않는다.
//

import AppKit

@MainActor
protocol OverlayPresenting: AnyObject {
    /// 프레젠터가 공유하는 상태 모델.
    var model: OverlayModel { get }

    /// 현재 상태.
    var state: OverlayState { get }

    /// 확장 상태로 표시한다.
    func expand(on screen: NSScreen)

    /// compact(최소) 상태로 표시한다.
    func compact(on screen: NSScreen)

    /// 숨긴다. 애니메이션 후 패널이 해제된다.
    func hide()

    /// 패널과 옵저버를 즉시 정리한다. (모드 전환/앱 종료 시)
    func tearDown()
}

extension OverlayPresenting {
    /// 화면을 지정하지 않으면 마우스가 있는 화면을 사용한다.
    func expand() { expand(on: .preferredForOverlay) }
    func compact() { compact(on: .preferredForOverlay) }

    /// 현재 상태에 따라 확장/축소를 토글한다.
    /// (기본 인자 대신 오버로드를 쓰는 이유: 기본 인자 식은 메인 액터 밖에서 평가되어 경고가 발생한다.)
    func toggleExpanded() {
        toggleExpanded(on: .preferredForOverlay)
    }

    func toggleExpanded(on screen: NSScreen) {
        if state == .expanded {
            compact(on: screen)
        } else {
            expand(on: screen)
        }
    }
}
