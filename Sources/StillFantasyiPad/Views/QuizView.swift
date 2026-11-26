import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public struct QuizView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var router: AppRouter
    @ObservedObject private var audioService = AudioService.shared

    @State private var currentQuestionIndex: Int = 0
    @State private var selectedOptionPartId: String? = nil
    @State private var correctCount: Int = 0
    @State private var isQuizFinished: Bool = false
    @State private var lastEarnedXp: Int = 0
    @State private var didUnlockSpecies: Bool = false

    private let optionColumns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    public init() {}

    private var availableSpecies: [Species] {
        SpeciesDataStore.sampleSpecies.filter { !$0.quizQuestions.isEmpty }
    }

    private var currentSpecies: Species {
        let selected = SpeciesDataStore.getSpecies(by: router.selectedSpeciesId)
        if !selected.quizQuestions.isEmpty {
            return selected
        }
        return availableSpecies.first ?? selected
    }

    private var questions: [QuizQuestion] {
        currentSpecies.quizQuestions
    }

    private var currentQuestion: QuizQuestion? {
        questions[safe: currentQuestionIndex]
    }

    public var body: some View {
        VStack(spacing: 0) {
            topHeaderBar
            speciesSwitcherBar
            Divider().background(Color.darkEmeraldBorder)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    if questions.isEmpty {
                        emptyStateView
                    } else if isQuizFinished {
                        completionSummaryView
                    } else if let q = currentQuestion {
                        questionStageView(for: q)
                    }
                }
                .padding(24)
            }
        }
        .background(Color.darkEmeraldBg)
        .onAppear {
            preloadQuestionAudio()
        }
        .onChange(of: router.selectedSpeciesId) { _, _ in
            resetQuiz()
        }
        .onChange(of: currentQuestionIndex) { _, _ in
            audioService.stop()
            preloadQuestionAudio()
        }
    }

    // MARK: - Top Navigation

    private var topHeaderBar: some View {
        HStack {
            Button(action: { router.openSpecies(currentSpecies.id) }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .bold))
                    Text("返回「\(currentSpecies.nameZh)」档案")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(Color.biolumMint)
            }

            Spacer()

            HStack(spacing: 8) {
                Image(systemName: "questionmark.circle.fill")
                    .foregroundColor(Color.amberGold)
                Text("\(currentSpecies.nameZh) · 双语科普趣味挑战")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color.textLight)
            }

            Spacer()

            if appState.isQuizCompleted(currentSpecies.id) {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 11))
                    Text("已通关")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundColor(Color.darkEmeraldBg)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.biolumMint)
                .clipShape(Capsule())
            } else {
                Text("答对半数即可收录图鉴")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color.goldLight)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(Color.darkEmeraldBg)
    }

    private var speciesSwitcherBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                Text("选择挑战物种:")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color.textMuted)

                ForEach(availableSpecies) { sp in
                    let isSelected = sp.id == currentSpecies.id
                    let completed = appState.isQuizCompleted(sp.id)
                    Button(action: {
                        withAnimation(.spring()) {
                            router.selectedSpeciesId = sp.id
                            resetQuiz()
                        }
                    }) {
                        HStack(spacing: 6) {
                            SpecimenImageView(sp.coverImage)
                                .frame(width: 22, height: 22)
                                .clipShape(Circle())

                            Text(sp.nameZh)
                                .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? Color.darkEmeraldBg : Color.textLight)

                            if completed {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(isSelected ? Color.darkEmeraldBg : Color.biolumMint)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(isSelected ? Color.biolumMint : Color.darkEmeraldCard)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(isSelected ? Color.biolumMint : Color.darkEmeraldBorder, lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
        }
        .background(Color.darkEmeraldSurface)
    }

    // MARK: - Question Stage

    private func questionStageView(for q: QuizQuestion) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Progress & Type Header
            HStack(spacing: 16) {
                Text("第 \(currentQuestionIndex + 1) / \(questions.count) 题")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color.textLight)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.darkEmeraldBorderSubtle)
                            .frame(height: 8)
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color.biolumMint, Color.biolumLime],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geo.size.width * CGFloat(currentQuestionIndex + 1) / CGFloat(max(questions.count, 1)),
                                height: 8
                            )
                    }
                }
                .frame(height: 8)

                Text(q.type == "listen_find" ? "听音辨位" : "结构识图")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color.goldLight)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.amberGold.opacity(0.18))
                    .clipShape(Capsule())
            }

            // Prompt Card + Specimen Thumbnail
            HStack(spacing: 20) {
                SpecimenImageView(currentSpecies.coverImage)
                    .frame(width: 140, height: 140)
                    .clipped()
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.darkEmeraldBorder, lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 10) {
                    Text(q.promptZh)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.textLight)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(q.promptEn)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.biolumMint.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 10) {
                        let zhToken = "quiz-prompt-zh-\(currentSpecies.id)-\(q.id)"
                        let enToken = "quiz-prompt-en-\(currentSpecies.id)-\(q.id)"

                        Button(action: {
                            if audioService.isActive(token: zhToken) {
                                audioService.stop()
                            } else {
                                audioService.play(
                                    remotePath: AudioPathBuilder.quiz(speciesId: currentSpecies.id, questionId: q.id, field: "prompt", lang: .zh),
                                    fallbackText: q.promptZh,
                                    language: .zh,
                                    token: zhToken
                                )
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: audioService.isActive(token: zhToken) ? "waveform" : "speaker.wave.2.fill")
                                    .font(.system(size: 12))
                                Text(audioService.isActive(token: zhToken) ? "正在播报..." : "中文读题")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .foregroundColor(Color.darkEmeraldBg)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.biolumMint)
                            .clipShape(Capsule())
                        }

                        Button(action: {
                            if audioService.isActive(token: enToken) {
                                audioService.stop()
                            } else {
                                audioService.play(
                                    remotePath: AudioPathBuilder.quiz(speciesId: currentSpecies.id, questionId: q.id, field: "prompt", lang: .en),
                                    fallbackText: q.promptEn,
                                    language: .en,
                                    token: enToken
                                )
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: audioService.isActive(token: enToken) ? "waveform" : "globe")
                                    .font(.system(size: 12))
                                Text(audioService.isActive(token: enToken) ? "Playing..." : "English Prompt")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(Color.textLight)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.darkEmeraldSurface)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.darkEmeraldBorder, lineWidth: 1))
                        }
                    }
                    .padding(.top, 4)
                }

                Spacer(minLength: 0)
            }
            .padding(20)
            .background(Color.darkEmeraldCard)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.darkEmeraldBorder, lineWidth: 1)
            )

            // 2x2 Interactive Options
            LazyVGrid(columns: optionColumns, spacing: 14) {
                ForEach(q.options) { opt in
                    optionCard(for: opt, question: q)
                }
            }

            // Explanation Banner after selection
            if let chosen = selectedOptionPartId {
                let isCorrect = chosen == q.targetPartId
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "lightbulb.fill")
                            .font(.system(size: 18))
                            .foregroundColor(isCorrect ? Color.biolumMint : Color.amberGold)
                        Text(isCorrect ? "回答正确！+\(AppState.quizQuestionReward) XP" : "再仔细想想看 · 科普小贴士")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(isCorrect ? Color.biolumMint : Color.goldLight)
                        Spacer()

                        let expZhToken = "quiz-exp-zh-\(currentSpecies.id)-\(q.id)"
                        let expEnToken = "quiz-exp-en-\(currentSpecies.id)-\(q.id)"
                        Button(action: {
                            if audioService.isActive(token: expZhToken) {
                                audioService.stop()
                            } else {
                                audioService.play(
                                    remotePath: AudioPathBuilder.quiz(speciesId: currentSpecies.id, questionId: q.id, field: "explanation", lang: .zh),
                                    fallbackText: q.explanationZh,
                                    language: .zh,
                                    token: expZhToken
                                )
                            }
                        }) {
                            Label(audioService.isActive(token: expZhToken) ? "播报中" : "听解析", systemImage: "speaker.wave.2")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color.darkEmeraldBg)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.biolumMint)
                                .clipShape(Capsule())
                        }

                        Button(action: {
                            if audioService.isActive(token: expEnToken) {
                                audioService.stop()
                            } else {
                                audioService.play(
                                    remotePath: AudioPathBuilder.quiz(speciesId: currentSpecies.id, questionId: q.id, field: "explanation", lang: .en),
                                    fallbackText: q.explanationEn,
                                    language: .en,
                                    token: expEnToken
                                )
                            }
                        }) {
                            Label(audioService.isActive(token: expEnToken) ? "Playing" : "EN", systemImage: "globe")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Color.textLight)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.darkEmeraldSurface)
                                .clipShape(Capsule())
                        }
                    }

                    Text(q.explanationZh)
                        .font(.system(size: 14))
                        .foregroundColor(Color.textLight)
                        .lineSpacing(4)

                    Text(q.explanationEn)
                        .font(.system(size: 12))
                        .foregroundColor(Color.textMuted)

                    HStack {
                        Spacer()
                        Button(action: advanceOrFinish) {
                            HStack(spacing: 6) {
                                Text(currentQuestionIndex + 1 < questions.count ? "下一题" : "查看挑战结果")
                                    .font(.system(size: 14, weight: .bold))
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 13, weight: .bold))
                            }
                            .foregroundColor(Color.darkEmeraldBg)
                            .padding(.horizontal, 22)
                            .padding(.vertical, 11)
                            .background(
                                LinearGradient(
                                    colors: [Color.biolumMint, Color.biolumEmerald],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                        }
                    }
                }
                .padding(20)
                .background(isCorrect ? Color.biolumMint.opacity(0.1) : Color.amberGold.opacity(0.1))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isCorrect ? Color.biolumMint.opacity(0.4) : Color.amberGold.opacity(0.4), lineWidth: 1)
                )
            }
        }
    }

    private func optionCard(for option: QuizOption, question: QuizQuestion) -> some View {
        let hasAnswered = selectedOptionPartId != nil
        let isChosen = selectedOptionPartId == option.partId
        let isTarget = option.partId == question.targetPartId

        let borderColor: Color = {
            guard hasAnswered else { return Color.darkEmeraldBorder }
            if isTarget { return Color.biolumMint }
            if isChosen { return Color.red.opacity(0.85) }
            return Color.darkEmeraldBorderSubtle
        }()

        let bgColor: Color = {
            guard hasAnswered else { return Color.darkEmeraldCard }
            if isTarget { return Color.biolumMint.opacity(0.16) }
            if isChosen { return Color.red.opacity(0.14) }
            return Color.darkEmeraldCard.opacity(0.55)
        }()

        return Button(action: {
            selectOption(option, for: question)
        }) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(option.textZh)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.textLight)
                    Text(option.textEn)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.textMuted)
                }

                Spacer()

                if hasAnswered {
                    if isTarget {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color.biolumMint)
                    } else if isChosen {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color.red.opacity(0.9))
                    }
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, minHeight: 76, alignment: .leading)
            .background(bgColor)
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(borderColor, lineWidth: hasAnswered && (isTarget || isChosen) ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(hasAnswered)
    }

    // MARK: - Completion & Empty Views

    private var completionSummaryView: some View {
        let passed = correctCount * 2 >= max(questions.count, 1)
        return VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(passed ? Color.biolumMint.opacity(0.18) : Color.amberGold.opacity(0.18))
                    .frame(width: 88, height: 88)
                Image(systemName: passed ? "rosette" : "arrow.counterclockwise.circle.fill")
                    .font(.system(size: 42))
                    .foregroundColor(passed ? Color.goldLight : Color.amberGold)
            }

            Text(passed ? "「\(currentSpecies.nameZh)」挑战通关！" : "差一点就通关啦，再来一次！")
                .font(.system(size: 24, weight: .black))
                .foregroundColor(Color.textLight)

            Text("答对 \(correctCount) / \(questions.count) 题 · 本轮获得 +\(lastEarnedXp) XP")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color.biolumMint)

            if didUnlockSpecies {
                Text("已为你新解锁「\(currentSpecies.nameZh)」图鉴卡片！")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.goldLight)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color.amberGold.opacity(0.18))
                    .clipShape(Capsule())
            }

            HStack(spacing: 14) {
                Button(action: resetQuiz) {
                    Text("再挑战一次")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color.textLight)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.darkEmeraldSurface)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.darkEmeraldBorder, lineWidth: 1))
                }

                Button(action: { router.openAnatomy(for: currentSpecies.id) }) {
                    Text("进入 3D 解剖实验室")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color.darkEmeraldBg)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 12)
                        .background(Color.biolumMint)
                        .clipShape(Capsule())
                }

                Button(action: jumpToNextSpecies) {
                    Text("挑战下一个物种")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color.darkEmeraldBg)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 12)
                        .background(Color.goldLight)
                        .clipShape(Capsule())
                }
            }
            .padding(.top, 6)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(Color.darkEmeraldCard)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.darkEmeraldBorder, lineWidth: 1)
        )
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 36))
                .foregroundColor(Color.biolumMint)
            Text("该物种挑战题库正在整理中")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color.textLight)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color.darkEmeraldCard)
        .cornerRadius(24)
    }

    // MARK: - Actions & Audio Preloading

    private func selectOption(_ option: QuizOption, for question: QuizQuestion) {
        guard selectedOptionPartId == nil else { return }
        selectedOptionPartId = option.partId
        let isCorrect = option.partId == question.targetPartId
        if isCorrect {
            correctCount += 1
        }
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(isCorrect ? .success : .error)
        #endif
    }

    private func advanceOrFinish() {
        audioService.stop()
        if currentQuestionIndex + 1 < questions.count {
            withAnimation(.easeInOut(duration: 0.2)) {
                currentQuestionIndex += 1
                selectedOptionPartId = nil
            }
        } else {
            let result = appState.recordQuizCompletion(
                speciesId: currentSpecies.id,
                correctCount: correctCount,
                totalCount: questions.count
            )
            lastEarnedXp = result.xpEarned
            didUnlockSpecies = result.newlyUnlocked
            withAnimation(.spring()) {
                isQuizFinished = true
            }
            if result.newlyUnlocked {
                router.presentUnlockCelebration(for: currentSpecies.id)
            }
        }
    }

    private func resetQuiz() {
        audioService.stop()
        currentQuestionIndex = 0
        selectedOptionPartId = nil
        correctCount = 0
        isQuizFinished = false
        lastEarnedXp = 0
        didUnlockSpecies = false
        preloadQuestionAudio()
    }

    private func jumpToNextSpecies() {
        guard !availableSpecies.isEmpty else { return }
        if let idx = availableSpecies.firstIndex(where: { $0.id == currentSpecies.id }) {
            let next = availableSpecies[(idx + 1) % availableSpecies.count]
            router.selectedSpeciesId = next.id
            resetQuiz()
        }
    }

    private func preloadQuestionAudio() {
        var paths: [String] = []
        if let q = currentQuestion {
            paths.append(AudioPathBuilder.quiz(speciesId: currentSpecies.id, questionId: q.id, field: "prompt", lang: .zh))
            paths.append(AudioPathBuilder.quiz(speciesId: currentSpecies.id, questionId: q.id, field: "prompt", lang: .en))
            paths.append(AudioPathBuilder.quiz(speciesId: currentSpecies.id, questionId: q.id, field: "explanation", lang: .zh))
            paths.append(AudioPathBuilder.quiz(speciesId: currentSpecies.id, questionId: q.id, field: "explanation", lang: .en))
        }
        if let nextQ = questions[safe: currentQuestionIndex + 1] {
            paths.append(AudioPathBuilder.quiz(speciesId: currentSpecies.id, questionId: nextQ.id, field: "prompt", lang: .zh))
            paths.append(AudioPathBuilder.quiz(speciesId: currentSpecies.id, questionId: nextQ.id, field: "prompt", lang: .en))
        }
        audioService.preload(remotePaths: paths)
    }
}
