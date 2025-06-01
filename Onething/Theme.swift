//
//  Theme.swift
//  Onething
//
//  Created by Ben Foster on 31/05/2025.
//

import SwiftUI

// MARK: - Color Extension for native adaptive colors
extension Color {
    // Custom themePurple color
    static let themePurple = Color(red: 0.5, green: 0.2, blue: 0.7)

    // Optional: Add semantic colors for reuse if you want
    static let background = Color(UIColor.systemBackground)
    static let foreground = Color.primary
}

// MARK: - View Modifier Extension for reusable style
extension View {
    func nativeBackgroundStyle() -> some View {
        self
            .background(Color.background.ignoresSafeArea())
            .foregroundColor(Color.foreground)
    }
}
