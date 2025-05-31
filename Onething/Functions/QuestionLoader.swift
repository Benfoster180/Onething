import Foundation

struct QuestionLoader {
    static func loadTodaysQuestion() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM"
        let todayKey = formatter.string(from: Date())

        if let url = Bundle.main.url(forResource: "daily_questions", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let allQuestions = try? JSONDecoder().decode([String: String].self, from: data) {
            return allQuestions[todayKey] ?? "What's on your mind today?"
        }

        return "Failed to load question."
    }
}
