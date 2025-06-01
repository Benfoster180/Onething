//
//  AnswerManager.swift
//  Onething
//
//  Created by Ben Foster on 01/06/2025.
//

import Foundation

final class AnswerManager {
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd-MM-yyyy"
        df.timeZone = TimeZone.current
        return df
    }()

    func saveAnswer(_ answer: String, question: String, entries: inout [DailyEntry]) throws {
        let todayKey = dateFormatter.string(from: Date())
        entries.removeAll { $0.date == todayKey }
        let newEntry = DailyEntry(date: todayKey, question: question, answer: answer)
        entries.append(newEntry)
        try EntryStorage.shared.saveEntries(entries)
    }

    func checkIfAnsweredToday(entries: [DailyEntry]) -> Bool {
        let todayKey = dateFormatter.string(from: Date())
        return entries.contains { $0.date == todayKey && !$0.answer.isEmpty }
    }
}
