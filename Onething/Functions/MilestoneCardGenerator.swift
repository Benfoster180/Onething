import UIKit

final class MilestoneCardGenerator {
    
    static func generateCard(question: String, answer: String) -> UIImage {
        let size = CGSize(width: 1080, height: 1350)
        
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let ctx = context.cgContext
            
            // MARK: - Background Gradient (rich purple-blue)
            let gradientColors = [
                UIColor(red: 102/255, green: 51/255, blue: 153/255, alpha: 1).cgColor,  // Deep purple
                UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1).cgColor    // iOS blue
            ] as CFArray
            
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                      colors: gradientColors,
                                      locations: [0.0, 1.0])!
            
            ctx.drawLinearGradient(gradient,
                                   start: CGPoint(x: size.width / 2, y: 0),
                                   end: CGPoint(x: size.width / 2, y: size.height),
                                   options: [])
            
            // MARK: - Card Background with Shadow & Rounded Corners
            let cardRect = CGRect(x: 80, y: 140, width: size.width - 160, height: size.height - 280)
            let cardPath = UIBezierPath(roundedRect: cardRect, cornerRadius: 48)
            
            ctx.saveGState()
            ctx.setShadow(offset: CGSize(width: 0, height: 18), blur: 28, color: UIColor.black.withAlphaComponent(0.18).cgColor)
            UIColor.white.setFill()
            cardPath.fill()
            ctx.restoreGState()
            
            // MARK: - Text Drawing Setup
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.lineSpacing = 8
            
            // Fonts
            let questionFont = UIFont.systemFont(ofSize: 52, weight: .heavy)
            let answerFont = UIFont.systemFont(ofSize: 40, weight: .regular)
            
            // Text Attributes
            let questionAttributes: [NSAttributedString.Key: Any] = [
                .font: questionFont,
                .foregroundColor: UIColor.label,
                .paragraphStyle: paragraphStyle
            ]
            
            let answerAttributes: [NSAttributedString.Key: Any] = [
                .font: answerFont,
                .foregroundColor: UIColor.darkGray,
                .paragraphStyle: paragraphStyle
            ]
            
            // Text Width & Insets
            let horizontalInset: CGFloat = 60
            let textWidth = cardRect.width - horizontalInset * 2
            
            // MARK: - Draw Question Text (top)
            let questionOrigin = CGPoint(x: cardRect.origin.x + horizontalInset, y: cardRect.origin.y + 120)
            let questionRect = CGRect(origin: questionOrigin, size: CGSize(width: textWidth, height: 280))
            question.draw(in: questionRect, withAttributes: questionAttributes)
            
            // MARK: - Draw Answer Text (below question)
            let answerOriginY = questionRect.origin.y + questionRect.height + 70
            let answerRect = CGRect(x: cardRect.origin.x + horizontalInset, y: answerOriginY, width: textWidth, height: 450)
            answer.draw(in: answerRect, withAttributes: answerAttributes)
            
            // MARK: - Watermark (bottom center)
            let watermark = "onething.app"
            let watermarkFont = UIFont.systemFont(ofSize: 22, weight: .medium)
            let watermarkAttributes: [NSAttributedString.Key: Any] = [
                .font: watermarkFont,
                .foregroundColor: UIColor.systemGray4
            ]
            
            let watermarkSize = watermark.size(withAttributes: watermarkAttributes)
            let watermarkPoint = CGPoint(
                x: cardRect.midX - watermarkSize.width / 2,
                y: cardRect.maxY - watermarkSize.height - 38
            )
            watermark.draw(at: watermarkPoint, withAttributes: watermarkAttributes)
            
            // MARK: - Subtle border glow around card (optional)
            ctx.saveGState()
            ctx.setShadow(offset: .zero, blur: 16, color: UIColor.systemBlue.withAlphaComponent(0.2).cgColor)
            UIColor.clear.setStroke()
            cardPath.lineWidth = 3
            cardPath.stroke()
            ctx.restoreGState()
        }
        
        return image
    }
}
