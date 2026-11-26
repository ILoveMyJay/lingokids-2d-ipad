# Still Fantasy · iPad 原生 Swift / SwiftUI 生物科学探索项目

本项目是专为 **Apple iPad (iPadOS 17+)** 量身打造的自然科学原生探索应用，代码完全采用 **Apple Swift 5.9+ / 6.0 与 SwiftUI** 编写，完整对齐《Still Fantasy 暮林幻境》视觉规范与 `lingokids-2d` 主站全量 **51 个物种**（含主站 50 种生物 + 旗舰标本大蓝闪蝶）、**五大生态王国**与 **Edge Neural 双语原声**。

---

## 📱 已实现功能界面

| 序号 | 界面名称 | 核心功能与技术实现 | 对应 Swift 视图源码 |
|---|---|---|---|
| **01** | **探索首页** | 今日推荐王者卡片、动态发光进度环、五大生态领域跳转图鉴筛选、微观视界入口 | [`DashboardView.swift`](Sources/StillFantasyiPad/Views/DashboardView.swift) |
| **02** | **物种档案** | 沉浸式物种巨幅 Banner、R2 预录 Edge Neural 双语原声 (`zh-CN-XiaoxiaoNeural` / `en-GB-RyanNeural`) + 离线降级、自适应 Bento 属性网格 | [`SpeciesDetailView.swift`](Sources/StillFantasyiPad/Views/SpeciesDetailView.swift) |
| **03** | **3D 解剖实验室** | 交互式解剖标本台、基于 `aspectFitRect` 精准锚定的安全热点（≥ 44pt 触控区）、右侧结构属性深度解析卡、冷知识面板 | [`AnatomyStageView.swift`](Sources/StillFantasyiPad/Views/AnatomyStageView.swift) |
| **04** | **微观视界** | 400× ~ 1000× 光学等效显微镜交互、独立手势缩放画布 (`MicroscopeCanvasView`)、显微十字标尺网格 (100 μm)、反色滤镜、可展开双语说明 | [`MicroWorldView.swift`](Sources/StillFantasyiPad/Views/MicroWorldView.swift) |
| **05** | **趣味挑战** | 双语互动问答 (`listen_find` / `identify_part`)、题目与解析 R2 原声朗读与预加载、触觉反馈、答题得 XP 并解锁图鉴 | [`QuizView.swift`](Sources/StillFantasyiPad/Views/QuizView.swift) |
| **06** | **我的图鉴** | 生物探索度进度条、五大生态与已解锁筛选胶囊、统一 `SpeciesCardView` 网格、一键解锁庆祝弹窗 (`UnlockCelebrationView`) | [`CodexView.swift`](Sources/StillFantasyiPad/Views/CodexView.swift) |
| **07** | **会员中心** | 动态等级与 VIP 状态卡、终身特权网格、微信扫码支付弹窗（已预留 `PaymentService` / StoreKit 2 上架替换接口） | [`MembershipCenterView.swift`](Sources/StillFantasyiPad/Views/MembershipCenterView.swift) |
| **08** | **个人中心** | 探索者身份卡、跨时区安全连续打卡奖励、4 项统计指标、可交互设置（探索足迹、真实磁盘缓存统计与清理、双语引擎切换、关于页面） | [`ProfileView.swift`](Sources/StillFantasyiPad/Views/ProfileView.swift) |

---

## 🛠️ 项目工程结构

```
StillFantasyiPad/
├── Package.swift                           # 现代 SPM 工程配置 (支持 iOS 17+, macOS 14+，打包 Data/species.json)
├── Resources/                              # 外部媒体资源目录 (images/ 与 audio/)
├── Sources/
│   └── StillFantasyiPad/
│       ├── StillFantasyiPadApp.swift        # @main 原生 SwiftUI 应用入口（注入 AppState 与 AppRouter）
│       ├── Data/
│       │   └── species.json                # 全量 51 物种（5 大生态、含解剖部位与问答挑战题库）
│       ├── Theme/
│       │   └── ThemeColors.swift           # Still Fantasy 暗夜翡翠 + 生物荧光色彩体系
│       ├── Utilities/
│       │   └── Collection+Safe.swift       # 安全集合下标扩展
│       ├── Models/
│       │   ├── AppRouter.swift             # 强类型 AppTab / CodexFilter 枚举与集中式导航路由器
│       │   ├── Species.swift               # Codable 物种/部位/测验实体、JSON 懒加载与 O(1) 查询
│       │   ├── Category.swift              # 五大生态领域模型 (昆虫/陆地/深海/鸟类/沙漠)
│       │   ├── MicroSpecimen.swift         # 显微镜微观标本模型 (400x~800x)
│       │   └── UserProfile.swift           # 探索者等级、XP、VIP、足迹、测验通关与打卡持久化
│       ├── Services/
│       │   ├── AudioService.swift          # @MainActor R2 神经网络原声引擎 + AudioCacheStore (200MB LRU) + en-GB/zh-CN 降级
│       │   ├── ImageCacheService.swift     # 内存警告释放 + 300MB LRU 磁盘缓存 + R2 安全 URL 构造与重试加载
│       │   └── PaymentService.swift        # 支付抽象层（当前为微信扫码演示，已预留 App Store StoreKit 2 TODO）
│       └── Views/
│           ├── MainLayoutView.swift        # iPad 分栏导航侧边栏与强类型视图路由器
│           ├── DashboardView.swift         # 探索首页
│           ├── SpeciesDetailView.swift     # 物种档案
│           ├── AnatomyStageView.swift      # 3D 解剖实验室
│           ├── MicroWorldView.swift        # 微观视界显微镜
│           ├── QuizView.swift              # 双语趣味问答挑战
│           ├── CodexView.swift             # 我的图鉴
│           ├── UnlockCelebrationView.swift # 图鉴解锁弹窗
│           ├── MembershipCenterView.swift  # 会员中心
│           ├── ProfileView.swift           # 个人中心与真实交互设置
│           └── Components/
│               ├── BentoCard.swift         # 自适应生物学属性卡片与子信息面板
│               ├── FilterPill.swift        # 泛型胶囊筛选按钮组件
│               ├── MicroscopeCanvasView.swift # 显微镜缩放/平移/标尺独立画布组件
│               ├── SpeciesCardView.swift   # 统一物种图鉴卡片（已解锁/待解锁）
│               ├── SpecimenImageView.swift # 跨平台高性能图片视图 (UIKit/AppKit)
│               ├── TopHeaderBar.swift      # 顶部双语模糊搜索栏与用户头像徽章
│               └── PayQRModalView.swift    # 微信扫码安全支付模态弹窗
└── Tests/
    └── StillFantasyiPadTests/
        ├── AppStateTests.swift             # 打卡/升级/解锁/VIP/足迹/测验单元测试
        └── ArchitectureAndDataTests.swift  # 51物种完整性/音频路径/路由/热点几何/LRU缓存单元测试
```

---

## 🚀 如何在 Xcode 中运行

### 方法一：直接打开 Xcode 工程（推荐）
在 Finder 中双击项目根目录下的 **`StillFantasyiPad.xcodeproj`**，或者在仓库根目录的终端运行：
```bash
open StillFantasyiPad.xcodeproj
```

### 方法二：命令行构建与单元测试（macOS）
```bash
# 1. 编译 iPad 模拟器应用包（产物输出到 ./build）
xcodebuild -project StillFantasyiPad.xcodeproj -scheme StillFantasyiPad \
  -destination "platform=iOS Simulator,name=iPad (A16)" -derivedDataPath build

# 2. 运行全部单元测试（macOS）
swift test
```

---

## 🖼️ 数据、脚本与 App Store 待办

- **结构化物种数据同步**：运行 `python3 build_full_species_data.py` 直接读取 `../lingokids-2d/scripts/species_data.json` 生成 `Sources/StillFantasyiPad/Data/species.json`（保留 `blue-morpho` 旗舰物种，共 51 个物种；支持 `LINGOKIDS_SPECIES_JSON` 环境变量指定路径）。
- **Xcode 工程生成**：运行 `python3 generate_xcodeproj.py` 重新生成 `StillFantasyiPad.xcodeproj`（默认配置真机团队 `DEVELOPMENT_TEAM = 2M24UZ8ZRQ`，支持 `STILLFANTASY_DEVELOPMENT_TEAM` 环境变量覆盖）。
- **App Store 上架待办 (StoreKit 2)**：当前版本保留微信扫码支付演示流；正式上架 App Store 前需按 [PaymentService.swift](Sources/StillFantasyiPad/Services/PaymentService.swift) 中的 `TODO(AppStore)` 将 `WeChatQRPaymentProvider` 替换为基于 StoreKit 2 的应用内购买实现（遵守 App Store 审核规范 3.1.1）。
