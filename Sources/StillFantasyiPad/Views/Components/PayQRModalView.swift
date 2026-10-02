import SwiftUI

public struct PayQRModalView: View {
    @Binding var isPresented: Bool

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

            VStack(spacing: 20) {
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

                Text("微信扫码安全支付")
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(Color.textLight)

                Text("开通后立即解锁全部 23+ 种生物深度解剖与 1,600+ 高清原声")
                    .font(.system(size: 12))
                    .foregroundColor(Color.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Mock QR Code Box
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .frame(width: 180, height: 180)

                    VStack(spacing: 8) {
                        Image(systemName: "qrcode")
                            .font(.system(size: 100))
                            .foregroundColor(Color(hex: "#07130E"))

                        Text("微信扫一扫支付")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(hex: "#07130E"))
                    }
                }

                // Price
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("¥ 98")
                        .font(.system(size: 28, weight: .black))
                        .foregroundColor(Color.goldLight)
                    Text("/ 终身无限期畅玩")
                        .font(.system(size: 12))
                        .foregroundColor(Color.textMuted)
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
                .padding(.top, 4)
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
