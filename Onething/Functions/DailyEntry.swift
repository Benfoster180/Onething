import Foundation

struct DailyEntry: Codable, Identifiable {
    var id: UUID = UUID()
    let date: String  // formatted date like "dd-MM-yyyy"
    let question: String
    let answer: String

    // Return dictionary representation like JSON object
    func toJSON() -> [String: Any] {
        return [
            "id": id.uuidString,
            "date": date,
            "question": question,
            "answer": answer
        ]
    }

    // Return JSON Data encoding this entry
    func toJSONData() throws -> Data {
        return try JSONEncoder().encode(self)
    }

    // Return pretty printed JSON String of this entry
    func toJSONString() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
