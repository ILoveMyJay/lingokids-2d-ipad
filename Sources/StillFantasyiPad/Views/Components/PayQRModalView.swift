import SwiftUI

public struct PayQRModalView: View {
    @EnvironmentObject private var appState: AppState
    @Binding var isPresented: Bool

    private let provider = PaymentService.activeProvider

    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }

    public var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }

            VStack(spacing: 18) {
                // Header
                HStack {
                    Spacer()
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color.textMuted)
                            .frame(width: 32, height: 32)
                            .background(Color.darkEmeraldSurface)
                            .clipShape(Circle())
                    }
                }

                // VIP Badge
                Text("尊享终身探索者计划")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color.goldLight)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.amberGold.opacity(0.2))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.amberGold.opacity(0.4), lineWidth: 1))

                Text(appState.isVip ? "VIP PRO 终身会员已激活" : provider.displayName)
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(Color.textLight)

                Text("开通后立即解锁全部 \(SpeciesDataStore.sampleSpecies.count) 种生物深度解剖与双语神经网络原声")
                    .font(.system(size: 12))
                    .foregroundColor(Color.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // WeChat QR Code Box (App Store submission will swap to StoreKit 2 via PaymentService)
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .frame(width: 176, height: 176)

                    if appState.isVip {
                        VStack(spacing: 10) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 64))
                                .foregroundColor(Color.biolumEmerald)
                            Text("终身权益生效中")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(hex: "#07130E"))
                        }
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "qrcode")
                                .font(.system(size: 96))
                                .foregroundColor(Color(hex: "#07130E"))

                            Text("微信扫一扫支付")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(Color(hex: "#07130E"))
                        }
                    }
                }

                // Price
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(provider.planPriceText)
                        .font(.system(size: 28, weight: .black))
                        .foregroundColor(Color.goldLight)
                    Text("/ 终身无限期畅玩")
                        .font(.system(size: 12))
                        .foregroundColor(Color.textMuted)
                }

                // Interactive confirmation button
                if appState.isVip {
                    Button(action: { isPresented = false }) {
                        Text("继续探索自然宇宙")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color.darkEmeraldBg)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.biolumMint)
                            .clipShape(Capsule())
                    }
                } else {
                    Button(action: {
                        provider.activateMembership(on: appState)
                    }) {
                        Text("我已完成微信扫码 · 激活 VIP 权益")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color.darkEmeraldBg)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    colors: [Color.goldLight, Color.amberGold],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                    }
                }

                // Trust Badges
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundColor(Color.biolumEmerald)
                        Text("官方安全支付")
                            .font(.system(size: 11))
                            .foregroundColor(Color.textMuted)
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(Color.biolumMint)
                        Text("即时开通")
                            .font(.system(size: 11))
                            .foregroundColor(Color.textMuted)
                    }
                }
                .padding(.top, 2)
            }
            .padding(28)
            .background(Color.darkEmeraldBg)
            .cornerRadius(28)
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.amberGold.opacity(0.4), lineWidth: 1.5)
            )
            .frame(maxWidth: 420)
            .shadow(color: Color.amberGold.opacity(0.2), radius: 30)
        }
    }
}
