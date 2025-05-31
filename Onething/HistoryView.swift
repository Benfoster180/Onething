import SwiftUI

struct HistoryView: View {
    let entries: [DailyEntry]

    var body: some View {
        ZStack {
            Color.themePurple // or your custom bg color
                .ignoresSafeArea()

            List(entries) { entry in
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.date)
                    Text(entry.question)
                    Text(entry.answer)
                }
                .foregroundColor(.black)  // black text
                .padding(.vertical, 4)
            }
            .listStyle(InsetGroupedListStyle()) // or your preferred style
            .background(Color.clear) // transparent so ZStack color shows
        }
        .navigationTitle("History")
    }
}
