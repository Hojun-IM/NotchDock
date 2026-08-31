//
//  PresentationMode.swift
//  NotchDock
//
//  오버레이를 어떤 형태로 보여줄지 결정하는 모드.
//  설정에서 노치 ↔ 독을 전환할 수 있도록 하기 위한 확장 포인트다.
//

import Foundation

enum PresentationMode: String, CaseIterable, Identifiable, Codable {
    /// 화면 상단 노치(또는 가상 노치)에 붙는 형태.
    case notch
    /// 화면 하단에서 올라오는 독 형태. (NotchAgent 와 동일한 콘텐츠를 재사용)
    case dock

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .notch: "노치"
        case .dock: "독"
        }
    }

    var systemImage: String {
        switch self {
        case .notch: "macbook"
        case .dock: "dock.rectangle"
        }
    }
}
