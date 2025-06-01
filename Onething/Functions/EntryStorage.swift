import SwiftUI
import Foundation

// MARK: - Model

struct DailyEntry: Identifiable, Codable {
    let id: UUID
    let date: String   // Format: "dd-MM-yyyy"
    let question: String
    let answer: String
    
    init(id: UUID = UUID(), date: String, question: String, answer: String) {
        self.id = id
        self.date = date
        self.question = question
        self.answer = answer
    }
}

// MARK: - Storage

class EntryStorage {
    static let shared = EntryStorage()

    private let filename = "all_entries.json"

    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
    }

    func loadEntries() -> [DailyEntry] {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let entries = try decoder.decode([DailyEntry].self, from: data)
            return entries
        } catch {
            print("Error loading entries: \(error.localizedDescription)")
            return []
        }
    }

    func saveEntries(_ entries: [DailyEntry]) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(entries)
        try data.write(to: fileURL, options: [.atomicWrite])
    }
}
