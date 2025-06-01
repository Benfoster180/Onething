import SwiftUI
import Photos

struct ShareableCardView: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var showAlert = false
    @State private var alertMessage = ""

    var caption: String? = "Keep shining and celebrating your growth ✨"

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Your Milestone Card")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.primary)

                Button(action: {
                    dismiss()
                }) {
                    Text("Close")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }

            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: gradientColors),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing)
                    )
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.7 : 0.15), radius: 15, x: 0, y: 8)

                VStack(spacing: 16) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .padding(.horizontal, 20)

                    if let caption = caption {
                        Text(caption)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.secondary)
                            .padding(.horizontal, 24)
                    }
                }
                .padding(.vertical, 30)
            }
            .padding(.horizontal, 20)

            Button(action: {
                savePhoto()
            }) {
                Text("Save to Photos")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: Color.accentColor.opacity(0.4), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, 24)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Photo Save"),
                    message: Text(alertMessage),
                    primaryButton: .default(Text("Settings"), action: {
                        if let url = URL(string: UIApplication.openSettingsURLString),
                           UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    }),
                    secondaryButton: .cancel()
                )
            }

            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: backgroundGradientColors),
                startPoint: .top,
                endPoint: .bottom)
            .ignoresSafeArea()
        )
    }

    // Dynamic gradient colors for card background
    private var gradientColors: [Color] {
        if colorScheme == .dark {
            return [Color.purple.opacity(0.6), Color.blue.opacity(0.4)]
        } else {
            return [Color.purple.opacity(0.2), Color.blue.opacity(0.15)]
        }
    }

    // Background gradient colors adapting to color scheme
    private var backgroundGradientColors: [Color] {
        if colorScheme == .dark {
            return [Color(UIColor.systemGray6), Color(UIColor.systemGray5)]
        } else {
            return [Color.white, Color(UIColor.systemGray6)]
        }
    }

    private func savePhoto() {
        PhotoPermissionManager.requestPermission { granted in
            if granted {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                alertMessage = "Photo saved to your library."
            } else {
                alertMessage = "Permission denied. Please enable photo library access in Settings."
            }
            showAlert = true
        }
    }
}
