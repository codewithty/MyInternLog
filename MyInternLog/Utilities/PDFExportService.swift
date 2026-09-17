import UIKit
import CoreText

// Renders a simple, single-template text report as a PDF. Pagination uses
// Core Text's framesetter so arbitrarily long journal text flows across as
// many pages as it needs.
enum PDFExportService {

    private static let pageSize = CGSize(width: 612, height: 792) // US Letter, points
    private static let margin: CGFloat = 48

    static func generateJournalPDF(title: String, subtitle: String, generatedAt: Date, body: String) -> Data {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))

        let attributedBody = NSAttributedString(string: body, attributes: [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.black
        ])
        let framesetter = CTFramesetterCreateWithAttributedString(attributedBody)

        let textRect = CGRect(
            x: margin,
            y: margin + 60,
            width: pageSize.width - margin * 2,
            height: pageSize.height - margin * 2 - 60
        )
        let path = CGPath(rect: textRect, transform: nil)

        var startIndex = 0
        let totalLength = attributedBody.length

        return renderer.pdfData { context in
            repeat {
                context.beginPage()
                let cgContext = context.cgContext

                drawHeader(title: title, subtitle: subtitle, generatedAt: generatedAt, in: cgContext)

                // Core Text draws bottom-up, so flip into PDF (top-down) coordinates.
                cgContext.saveGState()
                cgContext.translateBy(x: 0, y: pageSize.height)
                cgContext.scaleBy(x: 1, y: -1)

                let flippedTextRect = CGRect(
                    x: textRect.minX,
                    y: pageSize.height - textRect.maxY,
                    width: textRect.width,
                    height: textRect.height
                )
                let flippedPath = CGPath(rect: flippedTextRect, transform: nil)

                let frame = CTFramesetterCreateFrame(
                    framesetter,
                    CFRangeMake(startIndex, 0),
                    flippedPath,
                    nil
                )
                CTFrameDraw(frame, cgContext)
                cgContext.restoreGState()

                let visibleRange = CTFrameGetVisibleStringRange(frame)
                startIndex += visibleRange.length

                if visibleRange.length == 0 {
                    // Safety valve: avoid an infinite loop if a page can't fit any text.
                    break
                }
            } while startIndex < totalLength
        }
    }

    private static func drawHeader(title: String, subtitle: String, generatedAt: Date, in context: CGContext) {
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 20)
        ]
        let subtitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.darkGray
        ]

        title.draw(at: CGPoint(x: margin, y: margin), withAttributes: titleAttributes)
        subtitle.draw(at: CGPoint(x: margin, y: margin + 26), withAttributes: subtitleAttributes)

        let generated = "Generated " + generatedAt.formatted(date: .abbreviated, time: .shortened)
        generated.draw(at: CGPoint(x: margin, y: margin + 42), withAttributes: subtitleAttributes)
    }
}
