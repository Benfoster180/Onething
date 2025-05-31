import SwiftUI

struct CurrentQuestionView: View {
    @State private var answer: String = ""
    @State private var question: String = QuestionLoader.loadTodaysQuestion() // questions use dd-MM keys (no year)
    @State private var saveMessage: String = ""
    @State private var entries: [DailyEntry] = []
    @State private var showShareCard = false
    
    @State private var timeRemaining: TimeInterval = 0
    @State private var timer: Timer? = nil
    @State private var answeredToday: Bool = false

    var body: some View {
        ZStack {
            Color.themePurple
                .ignoresSafeArea()

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

                if !answeredToday {
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
                } else {
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
            entries = EntryStorage.shared.loadEntries()   // Reload entries fresh from storage
            print("Loaded entries count: \(entries.count)")
            checkIfAnsweredToday()
            setupTimer()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }

    func saveAnswer() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"  // full date with year for entries
        let todayKey = formatter.string(from: Date())

        // Remove old entry for today if any
        entries.removeAll { $0.date == todayKey }

        let newEntry = DailyEntry(date: todayKey, question: question, answer: answer)
        entries.append(newEntry)

        do {
            try EntryStorage.shared.saveEntries(entries)
            saveMessage = "Answer saved successfully!"
            answeredToday = true
            
            withAnimation {
                showShareCard = true
            }

            answer = ""
            setupTimer()
        } catch {
            saveMessage = "Failed to save answer: \(error.localizedDescription)"
        }
    }

    private func checkIfAnsweredToday() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy" // full date with year
        let todayKey = formatter.string(from: Date())

        print("Checking if answered today: \(todayKey)")
        print("Entries:")
        for entry in entries {
            print("- \(entry.date): answer='\(entry.answer)'")
        }

        // Only block if there is an entry for today with a non-empty answer
        answeredToday = entries.contains { $0.date == todayKey && !$0.answer.isEmpty }

        if answeredToday {
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
                answer = ""  // Clear answer so user can input again after midnight reset
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
