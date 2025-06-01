import Foundation

class EntryStorage {
    static let shared = EntryStorage()
    
    private let filename = "daily_entries.json"
    
    private var fileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent(filename)
    }
    
    func saveEntries(_ entries: [DailyEntry]) throws {
        let data = try JSONEncoder().encode(entries)
        try data.write(to: fileURL)
    }
    
    func loadEntries() -> [DailyEntry] {
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([DailyEntry].self, from: data)
        } catch {
            return []
        }
    }
}
