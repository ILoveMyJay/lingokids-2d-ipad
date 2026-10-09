# Still Fantasy · iPad 原生 Swift / SwiftUI 生物科学探索项目

本项目是专为 **Apple iPad (iPadOS 17+)** 量身打造的自然科学原生探索应用，代码完全采用 **Apple Swift 5.9+ / 6.0 与 SwiftUI** 编写，严格对照 8 屏高保真原型设计图与《Still Fantasy 暮林幻境》视觉规范，结合了 `lingokids-2d` 项目中的 361MB 高清物种摄影与自然原声音频。

---

## 📱 原型对照与已实现界面 (100% 对齐)

| 原型序号 | 界面名称 | 核心功能与技术实现 | 对应 Swift 视图源码 |
|---|---|---|---|
| **01** | **首页 · 独角仙** | 今日推荐王者卡片、27% 动态发光进度环、四大生态领域 (昆虫/陆地/深海/鸟类)、微观视界入口 | [`DashboardView.swift`](Sources/StillFantasyiPad/Views/DashboardView.swift) |
| **02** | **生态主题 · 大蓝闪蝶** | 沉浸式闪蝶巨幅 Banner、中英双语语音发音与原声朗读 (`AVSpeechSynthesizer` / `AVAudioPlayer`)、8 格 Bento 属性网格、进入 3D 解剖/微观视界操作栏 | [`SpeciesDetailView.swift`](Sources/StillFantasyiPad/Views/SpeciesDetailView.swift) |
| **03** | **解剖结构 · 大蓝闪蝶** | 交互式解剖标本台、4 个动态脉冲热点 (翅膀/复眼/触角/足)、右侧结构属性深度解析卡、冷知识面板、底部 400× 显微镜悬浮条 | [`AnatomyStageView.swift`](Sources/StillFantasyiPad/Views/AnatomyStageView.swift) |
| **04** | **微观世界 · 昆虫复眼** | 400× ~ 1000× 光学等效显微镜交互、显微十字标尺网格 (100 μm)、反色/滤镜模式、底部 4 种微观切片轮播 (复眼/鳞片/花粉/气孔) | [`MicroWorldView.swift`](Sources/StillFantasyiPad/Views/MicroWorldView.swift) |
| **05** | **我的图鉴** | 32/120 种生物探索度进度条、领域筛选胶囊 (全部/昆虫/陆地/海洋/鸟类/已解锁)、已解锁物种卡与未解锁暗黑轮廓卡 | [`CodexView.swift`](Sources/StillFantasyiPad/Views/CodexView.swift) |
| **06** | **图鉴解锁** | 胜利金桂勋章 (`NEW DISCOVERY UNLOCKED`)、大蓝闪蝶星光展示、+50 XP 奖励徽章、一键直达解剖实验室动效弹窗 | [`UnlockCelebrationView.swift`](Sources/StillFantasyiPad/Views/UnlockCelebrationView.swift) |
| **07** | **会员中心** | Lv.8 见习学者个人勋章、VIP PRO 终身特权卡 (全景 3D/1,600+ 原声/800× 显微/全量离线)、全景生态横幅、微信扫码支付弹窗 | [`MembershipCenterView.swift`](Sources/StillFantasyiPad/Views/MembershipCenterView.swift) |
| **08** | **个人中心** | 探索者身份卡、连续打卡奖励、4 项统计指标 (物种/勋章/收藏/天数)、设置菜单列表、暮林峡谷蓝蝶艺术标语 | [`ProfileView.swift`](Sources/StillFantasyiPad/Views/ProfileView.swift) |

---

## 🛠️ 项目工程结构

```
StillFantasyiPad/
├── Package.swift                    # 现代 SPM 工程配置 (支持 iOS 17+, macOS 14+)
├── Resources/                       # 资源软链接 (复用 lingokids-2d 的 361MB 高清多模态媒体库)
│   ├── images/                      # 35+ 种动物微距高精图片
│   └── audio/                       # 物种生态原声与发音音频
└── Sources/
    └── StillFantasyiPad/
        ├── StillFantasyiPadApp.swift # @main 原生 SwiftUI 应用入口
        ├── Theme/
        │   └── ThemeColors.swift    # Still Fantasy 暗夜翡翠 + 生物荧光色彩体系
        ├── Models/
        │   ├── Species.swift        # 物种实体与 8 大核心生物学属性数据
        │   ├── Category.swift       # 四大生态领域模型 (昆虫/陆地/深海/天空)
        │   ├── MicroSpecimen.swift  # 显微镜微观标本模型 (400x~800x)
        │   └── UserProfile.swift    # 探索者等级、XP、VIP 订阅与成就模型
        ├── Services/
        │   └── AudioService.swift   # 原生双语语音朗读与音频播放引擎 (AVFoundation)
        └── Views/
            ├── MainLayoutView.swift # iPad 分栏导航侧边栏与动态视图路由器
            ├── DashboardView.swift   # 01 首页独角仙
            ├── SpeciesDetailView.swift # 02 生态主题大蓝闪蝶
            ├── AnatomyStageView.swift  # 03 3D 解剖实验室
            ├── MicroWorldView.swift    # 04 微观视界显微镜
            ├── CodexView.swift         # 05 物种图鉴
            ├── UnlockCelebrationView.swift # 06 图鉴解锁弹窗
            ├── MembershipCenterView.swift  # 07 会员中心
            ├── ProfileView.swift       # 08 个人中心
            └── Components/
                ├── SpecimenImageView.swift # 跨平台高性能图片加载器 (UIKit/AppKit)
                ├── TopHeaderBar.swift      # 顶部搜索栏、AR 按钮与用户头像徽章
                └── PayQRModalView.swift    # 微信扫码安全支付模态弹窗
```

---

## 🚀 如何在 Xcode 中运行

### 方法一：直接打开 Xcode 工程（推荐）
在 Finder 中双击项目根目录下的 **`StillFantasyiPad.xcodeproj`**，或者在仓库根目录的终端运行：
```bash
open StillFantasyiPad.xcodeproj
```

### 方法二：在 Xcode 中选择运行目标
1. 顶部的运行设备列表中选择 **iPad Pro (13-inch) (M4)** 或 **iPad (A16)** 等任意 iPad 模拟器。
2. 点击 **▶ (Run)** 或按下键盘快捷键 **`⌘ + R`**。
3. 应用即在 iPad 模拟器中以全屏 iPad 比例（横屏分栏布局）完美启动运行。

> [!NOTE]
> 为什么推荐打开 `StillFantasyiPad.xcodeproj` 而非纯 `Package.swift`：
> iOS / iPadOS 模拟器环境运行 GUI 应用时，必须具备包含 `CFBundleIdentifier` 的原生 `.app` Application Bundle 包结构。`StillFantasyiPad.xcodeproj` 已经预设好了完整的 iOS Application Target 配置与 Bundle ID（`com.stillfantasy.ipad`）。

### 方法三：命令行一键构建并安装运行
```bash
# 在仓库根目录执行
# 1. 编译 iPad 模拟器应用包（产物输出到 ./build）
xcodebuild -project StillFantasyiPad.xcodeproj -scheme StillFantasyiPad \
  -destination "platform=iOS Simulator,name=iPad (A16)" -derivedDataPath build

# 2. 安装并启动到当前开机的 iPad 模拟器
xcrun simctl install booted build/Build/Products/Debug-iphonesimulator/StillFantasyiPad.app
xcrun simctl launch booted com.stillfantasy.ipad
```

---

## 🖼️ 图片与音频资源

- 图片按 `images/<物种>/<文件>.jpg` 的相对路径引用。加载顺序：App 包内 `Resources/` → 内存/磁盘缓存 → Cloudflare R2 远程拉取（自动重试并写入磁盘缓存）。
- 本地开发可设置环境变量 `STILLFANTASY_RESOURCES_DIR` 指向本机的资源目录，无需修改代码。
- 数据脚本不再依赖固定的本机路径：
  - `python3 generate_xcodeproj.py`：重新生成 Xcode 工程（新增 Swift 文件后运行）。
  - `python3 build_full_species_data.py <lingokids-2d/src/data/species 目录>`：重新生成 `Species.swift`（也可用环境变量 `LINGOKIDS_SPECIES_DIR`）。

## 💾 用户状态

收藏、图鉴解锁、每日打卡、XP 与等级统一由 `AppState`（`Models/UserProfile.swift`）管理，并保存在 `UserDefaults` 中，重启后不会丢失。
