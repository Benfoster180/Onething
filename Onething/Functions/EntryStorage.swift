import SwiftUI
import Foundation

// MARK: - Model

struct DailyEntry: Codable, Identifiable {
    var id: UUID = UUID()
    let date: String
    let question: String
    let answer: String
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
            print("Error loading entries: \(error)")
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

// MARK: - ContentView

