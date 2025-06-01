import SwiftUI

struct CurrentQuestionView: View {
    @Environment(\.colorScheme) private var colorScheme

    @State private var answer: String = ""
    @State private var question: String = QuestionManager.loadTodaysQuestion()
    @State private var saveMessage: String = ""
    @State private var entries: [DailyEntry] = []
    @State private var showShareCard = false

    @State private var timeRemaining: TimeInterval = 0
    @State private var answeredToday: Bool = false
    @State private var showCountdownScreen: Bool = false

    private var debugDisableTimer: Bool = false
    private var timerInterval: TimeInterval = 1
    @State private var timer: Timer? = nil

    @State private var generatedCard: UIImage? = nil
    @State private var showCardPreview: Bool = false

    private let answerManager = AnswerManager()

    private let debugAllowMultipleSubmissions = true

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // Gradient header with question text
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: colorScheme == .dark ?
                            [Color(red: 5/255, green: 10/255, blue: 40/255),
                             Color(red: 15/255, green: 30/255, blue: 70/255)] :
                            [Color.purple.opacity(0.9), Color.blue.opacity(0.9)]
                        ),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea(edges: .top)

                    Text(question)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.15))
                                .blur(radius: 10)
                        )
                        .padding(.horizontal, 24)
                }
                .frame(height: geo.size.height * 0.3)

                VStack(spacing: 24) {
                    CountdownView(
                        answeredToday: $answeredToday,
                        timeRemaining: $timeRemaining,
                        setupTimer: setupTimer
                    )
                    StreakView(
                        streakCount: calculateStreak()
                    )
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)

                Spacer()

                if !answeredToday || debugAllowMultipleSubmissions {
                    VStack(spacing: 16) {
                        TextField("Your answer...", text: $answer)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(UIColor.separator), lineWidth: 1)
                            )
                            .autocapitalization(.sentences)
                            .disableAutocorrection(false)

                        Button(action: saveAnswer) {
                            Text("Submit")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(answer.isEmpty ? Color.gray.opacity(0.6) : Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .disabled(answer.isEmpty)

                        if !saveMessage.isEmpty {
                            Text(saveMessage)
                                .font(.footnote)
                                .foregroundColor(saveMessage.contains("Failed") ? .red : .green)
                                .transition(.opacity)
                        }
                    }
                    .padding(24)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .background(Color(UIColor.systemBackground))
            .edgesIgnoringSafeArea(.bottom)
        }
        .onAppear {
            entries = EntryStorage.shared.loadEntries()
            answeredToday = answerManager.checkIfAnsweredToday(entries: entries)
            if showCountdownScreen && !debugDisableTimer && answeredToday {
                setupTimer()
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
        // 👇 Sheet goes here
        .sheet(isPresented: $showCardPreview) {
            if let card = generatedCard {
                ShareableCardView(image: card)
            }
        }
    }

    private func setupTimer() {
        timer?.invalidate()

        let now = Date()
        let calendar = Calendar.current
        if let midnight = calendar.nextDate(after: now, matching: DateComponents(hour: 0, minute: 0, second: 0), matchingPolicy: .strict, direction: .forward) {
            timeRemaining = midnight.timeIntervalSince(now)
        } else {
            timeRemaining = 0
        }

        timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { _ in
            DispatchQueue.main.async {
                timeRemaining -= timerInterval

                if timeRemaining <= 0 {
                    timeRemaining = 0
                    answeredToday = false
                    question = QuestionManager.loadTodaysQuestion()
                    saveMessage = ""
                    showShareCard = false
                    answer = ""
                    timer?.invalidate()
                    timer = nil
                }
            }
        }
    }

    func saveAnswer() {
        do {
            try answerManager.saveAnswer(answer, question: question, entries: &entries)

            // 👇 Generate share card and show sheet
            generatedCard = MilestoneCardGenerator.generateCard(question: question, answer: answer)
            showCardPreview = true

            if showCountdownScreen {
                answeredToday = true
            }

            answer = ""

            if showCountdownScreen {
                setupTimer()
            } else {
                answeredToday = false
            }
        } catch {
            print("Failed to save answer: \(error.localizedDescription)")
        }
    }

    private func calculateStreak() -> Int {
        guard !entries.isEmpty else { return 0 }
        let calendar = Calendar.current

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateFormatter.timeZone = TimeZone.current

        let sortedEntries = entries.sorted {
            dateFormatter.date(from: $0.date)! > dateFormatter.date(from: $1.date)!
        }

        var currentDate = Date()
        if !answeredToday {
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        }

        var streak = 0
        while true {
            let dateString = dateFormatter.string(from: currentDate)
            if sortedEntries.contains(where: { $0.date == dateString && !$0.answer.isEmpty }) {
                streak += 1
                guard let prevDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
                currentDate = prevDay
            } else {
                break
            }
        }

        return streak
    }
}

#Preview {
    CurrentQuestionView()
}
