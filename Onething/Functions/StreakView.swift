//
//  StreakView.swift
//  Onething
//
//  Created by Ben Foster on 01/06/2025.
//

import SwiftUI

struct StreakView: View {
    var streakCount: Int

    var body: some View {
        VStack(spacing: 8) {
            Text("🔥 Streak")
                .font(.headline)
                .foregroundColor(.primary.opacity(0.9))

            HStack(spacing: 4) {
                Text("\(streakCount)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)

                Text(streakEmoji(for: streakCount))
                    .font(.title3)
            }
            .padding(8)
            .background(Color.yellow.opacity(0.15))
            .cornerRadius(16)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.yellow.opacity(0.1))
        )
    }

    private func streakEmoji(for streak: Int) -> String {
        switch streak {
        case 0:
            return "😞"
        case 1...3:
            return "🔥"
        case 4...6:
            return "🎉"
        default:
            return "🏆"
        }
    }
}

#Preview {
    StreakView(streakCount: 5)
        .padding()
        .previewLayout(.sizeThatFits)
}
