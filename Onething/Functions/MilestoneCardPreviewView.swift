import SwiftUI
import UIKit

struct MilestoneCardPreviewView: View {
    let question: String
    let answer: String
    
    private var generatedImage: UIImage {
        MilestoneCardGenerator.generateCard(question: question, answer: answer)
    }
    
    var body: some View {
        Image(uiImage: generatedImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .cornerRadius(24)
            .shadow(radius: 10)
            .padding()
            .background(Color(UIColor.systemBackground))
            .edgesIgnoringSafeArea(.all)
    }
}

struct MilestoneCardPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        MilestoneCardPreviewView(
            question: "What motivates you every day?",
            answer: "Knowing that every step forward, no matter how small, is progress."
        )
        .previewLayout(.sizeThatFits)
    }
}
