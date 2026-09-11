import SwiftUI
import SwiftData

struct OnboardingView: View {
    @State private var vm: OnboardingViewModel
    @FocusState private var inputFocused: Bool

    init(context: ModelContext) {
        _vm = State(wrappedValue: OnboardingViewModel(context: context))
    }

    var body: some View {
        Group {
            switch vm.phase {
            case .intro:
                IntroStepView { Task { await vm.begin() } }
            case .chat:
                chatBody
            case .building, .done:
                BuildingStepView(line: vm.buildingLine)
            }
        }
    }

    private var chatBody: some View {
        ZStack {
            Palette.canvas.ignoresSafeArea()
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(vm.bubbles) { bubble in
                                ChatBubbleView(bubble: bubble).id(bubble.id)
                            }
                            if vm.coachTyping {
                                TypingIndicatorView().id("typing")
                            }
                        }
                        .padding(16)
                    }
                    .onChange(of: vm.bubbles.count) {
                        withAnimation { proxy.scrollTo(vm.bubbles.last?.id, anchor: .bottom) }
                    }
                    .onChange(of: vm.coachTyping) {
                        if vm.coachTyping {
                            withAnimation { proxy.scrollTo("typing", anchor: .bottom) }
                        }
                    }
                }

                composer
            }
        }
    }

    private var composer: some View {
        VStack(spacing: 10) {
            if !vm.quickReplies.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(vm.quickReplies, id: \.self) { option in
                        Button(option) { Task { await vm.send(option) } }
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Palette.accent)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .glassEffect(.regular.interactive(), in: Capsule())
                    }
                }
                .padding(.horizontal, 16)
            }

            HStack(alignment: .bottom, spacing: 10) {
                TextField("Ответ", text: $vm.input, axis: .vertical)
                    .focused($inputFocused)
                    .font(.system(size: 15))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .glassCard(cornerRadius: 20)
                    .lineLimit(1...4)
                    .onSubmit(submit)

                Button(action: submit) {
                    Image(systemName: "arrow.up")
                }
                .buttonStyle(GlassIconButtonStyle())
                .disabled(vm.input.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
    }

    private func submit() {
        let text = vm.input
        Task { await vm.send(text) }
    }
}

private struct ChatBubbleView: View {
    let bubble: OnboardingViewModel.Bubble

    var body: some View {
        HStack {
            if bubble.role == .user { Spacer(minLength: 40) }
            Text(bubble.text)
                .font(.system(size: 15))
                .foregroundStyle(bubble.role == .user ? Color.white : Palette.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .glassEffect(
                    bubble.role == .user ? .regular.tint(Palette.accent) : .regular,
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                )
                .frame(maxWidth: 280, alignment: bubble.role == .user ? .trailing : .leading)
            if bubble.role == .coach { Spacer(minLength: 40) }
        }
    }
}

private struct TypingIndicatorView: View {
    @State private var phase = 0

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Palette.textSecondary)
                    .frame(width: 6, height: 6)
                    .opacity(phase == index ? 1 : 0.3)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .glassCard(cornerRadius: 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .task {
            while !Task.isCancelled {
                for index in 0..<3 {
                    phase = index
                    try? await Task.sleep(for: .milliseconds(320))
                }
            }
        }
    }
}

private struct IntroStepView: View {
    let onStart: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            PhotoBackdrop(name: Photo.heroOnboarding, darkening: 0.62).ignoresSafeArea()

            VStack(alignment: .leading, spacing: 14) {
                Text("Сессия")
                    .font(.display(42))
                    .foregroundStyle(.white)
                Text("Домашняя калистеника до контрольного теста. Тренер собирает план под тебя и держит в графике до самого экзамена.")
                    .font(.system(size: 16))
                    .foregroundStyle(.white.opacity(0.85))
                Button("Начать", action: onStart)
                    .buttonStyle(.glassAction(tint: Palette.accent))
                    .padding(.top, 6)
            }
            .padding(24)
            .padding(.bottom, 28)
        }
    }
}

private struct BuildingStepView: View {
    let line: String

    var body: some View {
        ZStack {
            PhotoBackdrop(name: Photo.heroOnboarding, darkening: 0.58).ignoresSafeArea()
            VStack(spacing: 18) {
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.3)
                Text(line)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.opacity)
                    .animation(.easeInOut, value: line)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
    }
}
