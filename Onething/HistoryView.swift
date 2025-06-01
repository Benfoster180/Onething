import SwiftUI

struct HistoryView: View {
    let entries: [DailyEntry]

    // Extract valid years from entries
    private var availableYears: [Int] {
        Set(entries.compactMap { entry -> Int? in
            let comps = entry.date.split(separator: "-")
            if comps.count == 3, let year = Int(comps[2]) {
                return year
            }
            return nil
        }).sorted()
    }

    // Extract valid months for a given year
    private func availableMonths(for year: Int) -> [Int] {
        Set(entries.compactMap { entry -> Int? in
            let comps = entry.date.split(separator: "-")
            if comps.count == 3,
               let entryYear = Int(comps[2]),
               entryYear == year,
               let month = Int(comps[1]) {
                return month
            }
            return nil
        }).sorted()
    }

    @State private var selectedYear: Int? = nil
    @State private var selectedMonth: Int? = nil

    // Filter entries based on selected year and month
    private var filteredEntries: [DailyEntry] {
        entries.filter { entry in
            let comps = entry.date.split(separator: "-")
            guard comps.count == 3 else { return false }
            if let year = selectedYear, let entryYear = Int(comps[2]), entryYear != year {
                return false
            }
            if let month = selectedMonth, let entryMonth = Int(comps[1]), entryMonth != month {
                return false
            }
            return true
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Year picker - centered
                VStack(spacing: 4) {
                    Text("Select Year")
                        .font(.headline)
                        .foregroundColor(.purple)
                    Picker("Year", selection: $selectedYear) {
                        Text("All Years").tag(Int?.none)
                        ForEach(availableYears, id: \.self) { year in
                            Text(String(year)).tag(Int?.some(year))
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: 200, maxHeight: 100)
                    .clipped()
                }

                // Month picker - only shows if year selected
                if let year = selectedYear {
                    VStack(spacing: 4) {
                        Text("Select Month")
                            .font(.headline)
                            .foregroundColor(.purple)
                        Picker("Month", selection: $selectedMonth) {
                            Text("All Months").tag(Int?.none)
                            ForEach(availableMonths(for: year), id: \.self) { month in
                                Text(monthName(month)).tag(Int?.some(month))
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(maxWidth: 200, maxHeight: 100)
                        .clipped()
                    }
                }

                Divider()
                    .padding(.vertical, 8)

                // Entries list
                ScrollView {
                    LazyVStack(spacing: 20) {
                        if filteredEntries.isEmpty {
                            Text("No entries for selected filters.")
                                .foregroundColor(.secondary)
                                .italic()
                                .padding()
                        } else {
                            ForEach(filteredEntries) { entry in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(entry.question)
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)

                                    Text(entry.answer)
                                        .font(.body)
                                        .foregroundColor(.primary.opacity(0.8))

                                    HStack {
                                        Spacer()
                                        Text(entry.date)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(18)
                                .shadow(color: Color.black.opacity(0.07), radius: 6, x: 0, y: 3)
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .padding(.top)
            .onChange(of: selectedYear) { _ in
                // Reset month when year changes
                selectedMonth = nil
            }
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
