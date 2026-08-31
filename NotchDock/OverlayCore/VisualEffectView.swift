//
//  VisualEffectView.swift
//  NotchDock
//
//  NSVisualEffectView(블러 배경)를 SwiftUI 에서 쓰기 위한 래퍼.
//  주로 Dock 모드처럼 반투명 배경이 필요한 곳에서 사용한다.
//

import SwiftUI

struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material = .popover
    var blendingMode: NSVisualEffectView.BlendingMode = .behindWindow

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        // 창이 비활성 상태여도 항상 블러가 보이도록 active 로 고정한다.
        view.state = .active
        view.isEmphasized = true
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
