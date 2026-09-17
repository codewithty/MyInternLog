import UIKit
import CoreText

enum PDFTemplate: String, CaseIterable {
    case cleanAcademic = "Clean Academic"
    case modernPortfolio = "Modern Portfolio"
    case simpleJournal = "Simple Journal"

    var titleFont: UIFont {
        switch self {
        case .cleanAcademic: return .systemFont(ofSize: 22, weight: .semibold)
        case .modernPortfolio: return .systemFont(ofSize: 26, weight: .heavy)
        case .simpleJournal: return .systemFont(ofSize: 20, weight: .bold)
        }
    }

    var accentColor: UIColor {
        switch self {
        case .cleanAcademic: return .black
        case .modernPortfolio: return .systemPurple
        case .simpleJournal: return .systemBlue
        }
    }

    var bodyFont: UIFont { .systemFont(ofSize: 12) }
}

struct PDFCoverInfo {
    var appName = "MyInternLog"
    var tagline = "Never forget what you accomplished."
    var reportTitle: String
    var internshipTitle: String
    var organization: String
    var dateRangeDescription: String
    var generatedAt: Date
}

// Renders a report as a PDF: a cover page, then the body text flowed across
// as many pages as it needs (via Core Text's framesetter), each with a page
// number footer.
enum PDFExportService {
    private static let pageSize = CGSize(width: 612, height: 792) // US Letter, points
    private static let margin: CGFloat = 48

    static func generateJournalPDF(template: PDFTemplate, cover: PDFCoverInfo, body: String) -> Data {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize))

        let attributedBody = NSAttributedString(string: body, attributes: [
            .font: template.bodyFont,
            .foregroundColor: UIColor.black
        ])
        let framesetter = CTFramesetterCreateWithAttributedString(attributedBody)
        let textRect = CGRect(x: margin, y: margin, width: pageSize.width - margin * 2, height: pageSize.height - margin * 2 - 24)
        let flippedTextRect = CGRect(x: textRect.minX, y: pageSize.height - textRect.maxY, width: textRect.width, height: textRect.height)
        let flippedPath = CGPath(rect: flippedTextRect, transform: nil)

        // First pass: measure how many body pages this text needs so page
        // numbers ("Page X of Y") can be drawn correctly on the second pass.
        let bodyPageCount = countPages(framesetter: framesetter, path: flippedPath, totalLength: attributedBody.length)
        let totalPages = 1 + max(bodyPageCount, body.isEmpty ? 0 : 1)

        return renderer.pdfData { context in
            context.beginPage()
            drawCoverPage(template: template, cover: cover, in: context.cgContext)
            drawPageNumber(1, of: totalPages, in: context.cgContext)

            guard !body.isEmpty else { return }

            var startIndex = 0
            var pageNumber = 2
            repeat {
                context.beginPage()
                let cgContext = context.cgContext

                cgContext.saveGState()
                cgContext.translateBy(x: 0, y: pageSize.height)
                cgContext.scaleBy(x: 1, y: -1)
                let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(startIndex, 0), flippedPath, nil)
                CTFrameDraw(frame, cgContext)
                cgContext.restoreGState()

                drawPageNumber(pageNumber, of: totalPages, in: cgContext)

                let visibleRange = CTFrameGetVisibleStringRange(frame)
                if visibleRange.length == 0 { break }
                startIndex += visibleRange.length
                pageNumber += 1
            } while startIndex < attributedBody.length
        }
    }

    private static func countPages(framesetter: CTFramesetter, path: CGPath, totalLength: Int) -> Int {
        guard totalLength > 0 else { return 0 }
        var startIndex = 0
        var pages = 0
        while startIndex < totalLength {
            let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(startIndex, 0), path, nil)
            let visibleRange = CTFrameGetVisibleStringRange(frame)
            if visibleRange.length == 0 { break }
            startIndex += visibleRange.length
            pages += 1
        }
        return pages
    }

    private static func drawCoverPage(template: PDFTemplate, cover: PDFCoverInfo, in context: CGContext) {
        var y: CGFloat = 120

        cover.appName.draw(at: CGPoint(x: margin, y: y), withAttributes: [
            .font: template.titleFont,
            .foregroundColor: template.accentColor
        ])
        y += 36

        cover.tagline.draw(at: CGPoint(x: margin, y: y), withAttributes: [
            .font: UIFont.italicSystemFont(ofSize: 13),
            .foregroundColor: UIColor.darkGray
        ])
        y += 40

        cover.reportTitle.draw(at: CGPoint(x: margin, y: y), withAttributes: [
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ])
        y += 28

        let detailAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor.darkGray]
        if !cover.internshipTitle.isEmpty {
            cover.internshipTitle.draw(at: CGPoint(x: margin, y: y), withAttributes: detailAttributes)
            y += 18
        }
        if !cover.organization.isEmpty {
            cover.organization.draw(at: CGPoint(x: margin, y: y), withAttributes: detailAttributes)
            y += 18
        }
        cover.dateRangeDescription.draw(at: CGPoint(x: margin, y: y), withAttributes: detailAttributes)
        y += 18
        ("Generated " + cover.generatedAt.formatted(date: .abbreviated, time: .shortened)).draw(at: CGPoint(x: margin, y: y), withAttributes: detailAttributes)
    }

    private static func drawPageNumber(_ page: Int, of total: Int, in context: CGContext) {
        let text = "Page \(page) of \(total)"
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 9), .foregroundColor: UIColor.gray]
        let size = text.size(withAttributes: attributes)
        text.draw(at: CGPoint(x: pageSize.width - margin - size.width, y: pageSize.height - 32), withAttributes: attributes)
    }
}
