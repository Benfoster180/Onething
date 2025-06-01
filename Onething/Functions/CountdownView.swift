import SwiftUI

struct CountdownView: View {
    @Binding var answeredToday: Bool
    @Binding var timeRemaining: TimeInterval

    var setupTimer: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Text("⏳ Countdown to next question")
                .font(.headline)
                .foregroundColor(.primary.opacity(0.9))

            if answeredToday {
                Text(formattedTime(timeRemaining))
                    .font(.title3.monospacedDigit())
                    .fontWeight(.bold)
                    .foregroundColor(.accentColor)
                    .onAppear {
                        setupTimer()
                    }
            } else {
                Text("Today's question is ready ✅")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.green.opacity(0.9))
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.accentColor.opacity(0.1))
        )
    }

    private func formattedTime(_ interval: TimeInterval) -> String {
        if interval <= 0 {
            return "00:00:00"
        }
        let totalSeconds = Int(interval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = (totalSeconds % 60)
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

#Preview {
    CountdownView(
        answeredToday: .constant(true),
        timeRemaining: .constant(3600 * 3 + 120 + 10),
        setupTimer: {}
    )
    .padding()
    .previewLayout(.sizeThatFits)
}
