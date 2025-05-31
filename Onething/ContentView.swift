import SwiftUI

struct ContentView: View {
    @State private var answer: String = ""
    @State private var question: String = QuestionLoader.loadTodaysQuestion()
    @State private var saveMessage: String = ""
    @State private var entries: [DailyEntry] = EntryStorage.shared.loadEntries()

    var body: some View {
        VStack(spacing: 20) {
            Text(question)
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()

            TextField("Your answer...", text: $answer)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button("Save Answer") {
                saveAnswer()
            }
            .padding()
            .background(answer.isEmpty ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(answer.isEmpty)  // Disable button if answer is empty

            if !saveMessage.isEmpty {
                Text(saveMessage)
                    .foregroundColor(saveMessage.contains("Failed") ? .red : .green)
            }
        }
        .padding()
    }

    func saveAnswer() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let todayKey = formatter.string(from: Date())

        // Remove old entry for today if exists
        entries.removeAll { $0.date == todayKey }

        let newEntry = DailyEntry(date: todayKey, question: question, answer: answer)
        entries.append(newEntry)

        do {
            try EntryStorage.shared.saveEntries(entries)
            saveMessage = "Answer saved successfully!"
            answer = "" // Clear input after saving
        } catch {
            saveMessage = "Failed to save answer: \(error.localizedDescription)"
        }
        
    }
}

// Preview for Canvas
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
