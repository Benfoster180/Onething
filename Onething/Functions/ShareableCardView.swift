import SwiftUI
import Photos

struct ShareableCardView: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Your Milestone Card")
                    .font(.title2)
                    .fontWeight(.semibold)

                Button(action: {
                    dismiss()
                }) {
                    Text("Close")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding()

            Button(action: {
                savePhoto()
            }) {
                Text("Save to Photos")
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Photo Save"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }

            Spacer()
        }
        .padding()
    }
    
    private func savePhoto() {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized, .limited:
            // Already authorized, save immediately
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            alertMessage = "Photo saved to your library."
            showAlert = true
            
        case .notDetermined:
            // Request permission
            PHPhotoLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                        alertMessage = "Photo saved to your library."
                    } else {
                        alertMessage = "Permission denied. Please enable photo library access in Settings."
                    }
                    showAlert = true
                }
            }
            
        case .denied, .restricted:
            // Permission denied/restricted, alert user
            alertMessage = "Permission denied. Please enable photo library access in Settings."
            showAlert = true
            
        @unknown default:
            alertMessage = "Unknown error occurred."
            showAlert = true
        }
    }
}
