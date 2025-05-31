import Foundation

class EntryStorage {
    static let shared = EntryStorage()

    private let filename = "all_entries.json"

    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
    }

    func loadEntries() -> [DailyEntry] {
        guard let data = try? Data(contentsOf: fileURL) else {
            return []
        }
        let decoder = JSONDecoder()
        return (try? decoder.decode([DailyEntry].self, from: data)) ?? []
    }

    func saveEntries(_ entries: [DailyEntry]) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(entries)
        try data.write(to: fileURL, options: [.atomicWrite])
    }
}
