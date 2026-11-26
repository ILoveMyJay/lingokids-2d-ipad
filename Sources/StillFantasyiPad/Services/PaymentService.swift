import Foundation

public enum MembershipPaymentMethod: String, CaseIterable {
    case wechatQR
    case storeKit2
}

public protocol MembershipPaymentProviding {
    var method: MembershipPaymentMethod { get }
    var displayName: String { get }
    var planPriceText: String { get }
    var isStoreKitReady: Bool { get }
    @MainActor func activateMembership(on appState: AppState)
}

/// Active payment provider for personal/sideload distribution using WeChat Pay QR.
public struct WeChatQRPaymentProvider: MembershipPaymentProviding {
    public let method: MembershipPaymentMethod = .wechatQR
    public let displayName: String = "微信扫码安全支付"
    public let planPriceText: String = "¥ 98"
    public let isStoreKitReady: Bool = false

    public init() {}

    @MainActor
    public func activateMembership(on appState: AppState) {
        appState.activateVip()
    }
}

// TODO(AppStore): Replace `WeChatQRPaymentProvider` with `StoreKit2PaymentProvider`
// using `Product.products(for:)` and `Transaction.updates` before App Store submission
// to comply with App Store Review Guideline 3.1.1 (In-App Purchase).
public struct StoreKit2PaymentPlaceholder: MembershipPaymentProviding {
    public let method: MembershipPaymentMethod = .storeKit2
    public let displayName: String = "App Store 内购 (StoreKit 2 待接入)"
    public let planPriceText: String = "¥ 98"
    public let isStoreKitReady: Bool = false

    public init() {}

    @MainActor
    public func activateMembership(on appState: AppState) {
        // Placeholder until App Store Connect product IDs and StoreKit 2 entitlements are configured.
        appState.activateVip()
    }
}

public enum PaymentService {
    public static let activeProvider: MembershipPaymentProviding = WeChatQRPaymentProvider()
}
