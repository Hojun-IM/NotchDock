//
//  ContentView.swift
//  NotchDock
//
//  Created by Hojun Im on 8/31/26.
//
//  오버레이 동작을 확인하고 설정을 바꾸는 컨트롤 패널.
//  실제 노치 UI 는 별도의 NSPanel 에 그려지므로, 이 창은 순수하게 제어용이다.
//

import SwiftUI

struct ContentView: View {
    @Environment(OverlayCoordinator.self) private var coordinator

    var body: some View {
        @Bindable var coordinator = coordinator
        @Bindable var model = coordinator.model

        Form {
            Section("표시 모드") {
                // 모드를 바꾸면 코디네이터가 프레젠터를 교체하고 현재 상태를 그대로 복원한다.
                Picker("모드", selection: $coordinator.mode) {
                    ForEach(PresentationMode.allCases) { mode in
                        Label(mode.displayName, systemImage: mode.systemImage).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("상태") {
                LabeledContent("현재 상태", value: stateDescription)
                LabeledContent("노치 크기", value: notchDescription)
                LabeledContent("오버레이 크기", value: overlayDescription)

                HStack {
                    Button("펼치기") { coordinator.expand() }
                    Button("최소화") { coordinator.compact() }
                    Button("숨기기") { coordinator.hide() }
                }
            }

            Section("동작") {
                Toggle("마우스를 올리면 자동으로 펼치기", isOn: $model.expandsOnHover)
                Toggle("햅틱 피드백 사용", isOn: $model.usesHapticFeedback)
            }

        }
        .formStyle(.grouped)
        .frame(width: 380)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var stateDescription: String {
        switch coordinator.state {
        case .hidden: "숨김"
        case .compact: "최소"
        case .expanded: "확장"
        }
    }

    private var overlayDescription: String {
        let size = OverlayMetrics.size(for: coordinator.state)
        return "\(Int(size.width)) × \(Int(size.height))"
    }

    private var notchDescription: String {
        let size = coordinator.model.notchSize
        let kind = coordinator.model.screenHasNotch ? "실제 노치" : "가상 노치"
        return "\(Int(size.width)) × \(Int(size.height)) (\(kind))"
    }
}

#Preview {
    ContentView()
        .environment(OverlayCoordinator())
}
