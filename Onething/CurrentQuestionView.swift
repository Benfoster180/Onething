import SwiftUI

struct CurrentQuestionView: View {
    @State private var answer: String = ""
    @State private var question: String = QuestionLoader.loadTodaysQuestion()
    @State private var saveMessage: String = ""
    @State private var entries: [DailyEntry] = []
    @State private var showShareCard = false

    @State private var timeRemaining: TimeInterval = 0
    @State private var timer: Timer? = nil
    @State private var answeredToday: Bool = false

    @State private var showCountdownScreen: Bool = false // 👈 New toggle

    private let debugDisableTimer: Bool = false

    var body: some View {
        ZStack {
            Color.themePurple.ignoresSafeArea()

            VStack(spacing: 20) {
                ZStack {
                    Text(question)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                        .offset(x: 1, y: 1)
                    Text(question)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                }
                .multilineTextAlignment(.center)
                .padding()

                if !answeredToday || !showCountdownScreen {
                    TextField("Your answer...", text: $answer)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    Button("Save Answer") {
                        saveAnswer()
                    }
                    .padding()
                    .background(Color(red: 203/255, green: 195/255, blue: 227/255))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .disabled(answer.isEmpty)
                } else if showCountdownScreen {
                    VStack {
                        Text("Next question in:")
                            .font(.headline)
                        Text(timeString(timeRemaining))
                            .font(.largeTitle)
                            .monospacedDigit()
                            .padding(.top, 4)
                    }
                }

                if !saveMessage.isEmpty {
                    Text(saveMessage)
                        .foregroundColor(saveMessage.contains("Failed") ? .red : .green)
                }
            }
            .padding()

            if showShareCard {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .transition(.opacity)

                VStack(spacing: 16) {
                    Text("🎉 You answered today's question!")
                        .font(.headline)
                        .multilineTextAlignment(.center)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Q: \(question)")
                        Text("A: \(answer)")
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 5)

                    ShareLink(
                        item: "Today's question: \(question)\nMy answer: \(answer)",
                        message: Text("Sharing my daily reflection")
                    ) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)

                    Button("Close") {
                        withAnimation {
                            showShareCard = false
                        }
                    }
                    .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding(40)
                .transition(.scale)
                .zIndex(1)
            }
        }
        .animation(.easeInOut, value: showShareCard)
        .onAppear {
            entries = EntryStorage.shared.loadEntries()
            checkIfAnsweredToday()
            if showCountdownScreen && !debugDisableTimer {
                setupTimer()
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }

    func saveAnswer() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let todayKey = formatter.string(from: Date())

        entries.removeAll { $0.date == todayKey }

        let newEntry = DailyEntry(date: todayKey, question: question, answer: answer)
        entries.append(newEntry)

        do {
            try EntryStorage.shared.saveEntries(entries)
            saveMessage = "Answer saved successfully!"

            if showCountdownScreen {
                answeredToday = true
            }

            withAnimation {
                showShareCard = true
            }

            answer = ""

            if showCountdownScreen {
                setupTimer()
            } else {
                print("⏱ Timer skipped (countdown disabled)")
                answeredToday = false
            }

        } catch {
            saveMessage = "Failed to save answer: \(error.localizedDescription)"
        }
    }

    private func checkIfAnsweredToday() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let todayKey = formatter.string(from: Date())

        answeredToday = entries.contains { $0.date == todayKey && !$0.answer.isEmpty }

        if answeredToday && showCountdownScreen && !debugDisableTimer {
            setupTimer()
        }
    }

    private func setupTimer() {
        timer?.invalidate()

        let now = Date()
        let calendar = Calendar.current
        if let midnight = calendar.nextDate(after: now, matching: DateComponents(hour:0, minute:0, second:0), matchingPolicy: .strict, direction: .forward) {
            timeRemaining = midnight.timeIntervalSince(now)
        } else {
            timeRemaining = 0
        }

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            timeRemaining -= 1

            if timeRemaining <= 0 {
                timeRemaining = 0
                answeredToday = false
                question = QuestionLoader.loadTodaysQuestion()
                saveMessage = ""
                showShareCard = false
                answer = ""
                timer?.invalidate()
                timer = nil
            }
        }
    }

    private func timeString(_ time: TimeInterval) -> String {
        let totalSeconds = max(Int(time), 0)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

struct CurrentQuestionView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentQuestionView()
    }
}
