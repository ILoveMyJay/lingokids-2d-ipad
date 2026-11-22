import Foundation
import SwiftUI

/// Type-safe primary navigation destinations across the iPad sidebar and detail screens.
public enum AppTab: String, CaseIterable, Identifiable, Hashable {
    case dashboard
    case species
    case anatomy
    case micro
    case codex
    case membership
    case profile

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .dashboard: return "探索首页"
        case .species: return "物种档案"
        case .anatomy: return "3D 解剖实验室"
        case .micro: return "微观视界"
        case .codex: return "我的图鉴"
        case .membership: return "会员中心"
        case .profile: return "个人中心"
        }
    }

    public var icon: String {
        switch self {
        case .dashboard: return "house.fill"
        case .species: return "square.grid.2x2.fill"
        case .anatomy: return "viewfinder"
        case .micro: return "scope"
        case .codex: return "book.closed.fill"
        case .membership: return "crown.fill"
        case .profile: return "person.crop.circle.fill"
        }
    }
}

/// Centralized navigation and modal coordinator replacing raw String tabs and multi-layer @Binding chains.
public final class AppRouter: ObservableObject {
    @Published public var activeTab: AppTab
    @Published public var selectedSpeciesId: String
    @Published public var selectedBodyPartId: String?
    @Published public var searchText: String
    @Published public var showPayModal: Bool
    @Published public var showUnlockModal: Bool
    @Published public var unlockedSpeciesId: String

    public init(
        activeTab: AppTab = .dashboard,
        selectedSpeciesId: String = "blue-morpho",
        selectedBodyPartId: String? = nil,
        searchText: String = "",
        showPayModal: Bool = false,
        showUnlockModal: Bool = false,
        unlockedSpeciesId: String = "blue-morpho"
    ) {
        self.activeTab = activeTab
        self.selectedSpeciesId = selectedSpeciesId
        self.selectedBodyPartId = selectedBodyPartId
        self.searchText = searchText
        self.showPayModal = showPayModal
        self.showUnlockModal = showUnlockModal
        self.unlockedSpeciesId = unlockedSpeciesId
    }

    public func selectTab(_ tab: AppTab) {
        activeTab = tab
    }

    public func openSpecies(_ speciesId: String) {
        selectedSpeciesId = speciesId
        activeTab = .species
        searchText = ""
    }

    public func openAnatomy(for speciesId: String? = nil, partId: String? = nil) {
        if let speciesId {
            selectedSpeciesId = speciesId
        }
        if let partId {
            selectedBodyPartId = partId
        }
        activeTab = .anatomy
    }

    public func openMicro(for speciesId: String? = nil, partId: String? = nil) {
        if let speciesId {
            selectedSpeciesId = speciesId
        }
        if let partId {
            selectedBodyPartId = partId
        }
        activeTab = .micro
    }

    public func openPayModal() {
        showPayModal = true
    }

    public func presentUnlockCelebration(for speciesId: String) {
        unlockedSpeciesId = speciesId
        showUnlockModal = true
    }
}
