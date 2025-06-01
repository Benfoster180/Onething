import Foundation

struct QuestionManager {
    static private var questions: [String: String] = [:]

    // Load questions.json once
    static func loadQuestions() {
        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json") else {
            print("questions.json not found")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            questions = try JSONDecoder().decode([String: String].self, from: data)
        } catch {
            print("Failed to load or decode questions.json: \(error)")
        }
    }

    // Get question for today's date in dd-MM format
    static func loadTodaysQuestion() -> String {
        if questions.isEmpty {
            loadQuestions()
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM"
        let todayKey = formatter.string(from: Date())

        return questions[todayKey] ?? "No question for today."
    }
}
