//
//  Theme.swift
//  Onething
//
//  Created by Ben Foster on 31/05/2025.
//

import SwiftUI

// MARK: - Color Extension for theme colors
extension Color {
    static let themePurple = Color(red: 204/255, green: 204/255, blue: 255/255)
}

// MARK: - View Modifier Extension for reusable style
extension View {
    func purpleBackgroundStyle() -> some View {
        self
            .background(Color.themePurple.ignoresSafeArea())
            .foregroundColor(.black)
    }
}
