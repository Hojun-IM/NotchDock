//
//  NotchDockApp.swift
//  NotchDock
//
//  Created by Hojun Im on 8/31/26.
//

import SwiftUI

@main
struct NotchDockApp: App {
    /// 오버레이는 SwiftUI Scene 이 아니라 직접 만든 NSPanel 위에서 동작하므로,
    /// 생명주기를 다루기 좋은 AppDelegate 에서 코디네이터를 소유한다.
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        // 설정/디버그용 창. 오버레이 동작을 직접 제어해 볼 수 있다.
        Window("NotchDock", id: "control") {
            ContentView()
                .environment(appDelegate.coordinator)
        }
        .windowResizability(.contentSize)

        // 메뉴바에서 언제든 오버레이를 조작할 수 있는 진입점.
        MenuBarExtra("NotchDock", systemImage: "rectangle.topthird.inset.filled") {
            MenuBarCommands()
                .environment(appDelegate.coordinator)
        }
    }
}

// MARK: - AppDelegate

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let coordinator = OverlayCoordinator()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 앱이 뜨면 곧바로 최소 상태의 노치를 띄워 대기시킨다.
        coordinator.start()
    }

    func applicationWillTerminate(_ notification: Notification) {
        coordinator.shutDown()
    }
}

// MARK: - 메뉴바 메뉴

private struct MenuBarCommands: View {
    @Environment(OverlayCoordinator.self) private var coordinator
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        @Bindable var coordinator = coordinator

        Button("펼치기") { coordinator.expand() }
        Button("최소화") { coordinator.compact() }
        Button("숨기기") { coordinator.hide() }

        Divider()

        Picker("표시 모드", selection: $coordinator.mode) {
            ForEach(PresentationMode.allCases) { mode in
                Text(mode.displayName).tag(mode)
            }
        }

        Divider()

        Button("설정 창 열기") { openWindow(id: "control") }
        Button("종료") { NSApp.terminate(nil) }
            .keyboardShortcut("q")
    }
}
