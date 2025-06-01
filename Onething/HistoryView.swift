import SwiftUI

struct HistoryView: View {
    let entries: [DailyEntry]

    private var years: [Int] {
        Set(entries.compactMap { Int($0.date.split(separator: "-").last ?? "") }).sorted()
    }

    private func months(for year: Int) -> [Int] {
        Set(entries.compactMap { entry -> Int? in
            let comps = entry.date.split(separator: "-")
            if comps.count == 3,
               let month = Int(comps[1]),
               let entryYear = Int(comps[2]),
               entryYear == year {
                return month
            }
            return nil
        }).sorted()
    }

    @State private var filterYear: Int? = nil
    @State private var filterMonth: Int? = nil

    var filteredEntries: [DailyEntry] {
        entries.filter { entry in
            let comps = entry.date.split(separator: "-")
            guard comps.count == 3 else { return false }

            if let year = filterYear,
               let entryYear = Int(comps[2]),
               entryYear != year {
                return false
            }

            if let month = filterMonth,
               let entryMonth = Int(comps[1]),
               entryMonth != month {
                return false
            }

            return true
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                // Filter controls
                HStack(spacing: 12) {
                    Picker("Year", selection: $filterYear) {
                        Text("All").tag(Int?.none)
                        ForEach(years, id: \.self) { year in
                            Text(String(year)).tag(Int?.some(year))
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: 100)
                    .padding(8)
                    .background(Color.purple.opacity(0.2))
                    .cornerRadius(10)

                    if let year = filterYear {
                        Picker("Month", selection: $filterMonth) {
                            Text("All").tag(Int?.none)
                            ForEach(months(for: year), id: \.self) { month in
                                Text(monthName(month)).tag(Int?.some(month))
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: 140)
                        .padding(8)
                        .background(Color.purple.opacity(0.2))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)

                // Card-style list
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredEntries) { entry in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(entry.question)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)

                                Text(entry.answer)
                                    .font(.body)
                                    .foregroundColor(.primary.opacity(0.85))

                                HStack {
                                    Spacer()
                                    Text(entry.date)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("History")
        }
    }

    private func monthName(_ month: Int) -> String {
        let formatter = DateFormatter()
        return formatter.monthSymbols[month - 1]
    }
}

#Preview {
    HistoryView(entries: [
        DailyEntry(date: "01-05-2023", question: "What made you smile today?", answer: "Sunshine and coffee."),
        DailyEntry(date: "15-06-2023", question: "What did you learn?", answer: "How to bake bread."),
        DailyEntry(date: "12-12-2024", question: "What are you grateful for?", answer: "Family and friends."),
        DailyEntry(date: "03-01-2025", question: "Your goal for tomorrow?", answer: "Exercise and read."),
    ])
}
