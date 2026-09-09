import Foundation
import CoreGraphics
import PDFKit
import ImageIO
import UniformTypeIdentifiers

// Split the generated slide deck into chapter and individual-page PDFs.
// Uses Apple's built-in PDF framework; no third-party package is installed.
let directory = URL(fileURLWithPath: CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "output/pdf", isDirectory: true)
let source = directory.appendingPathComponent("onyx-complete.pdf")
guard let editable = PDFDocument(url: source), editable.pageCount == 33 else {
    fputs("Expected 33 pages: cover, contents, 30 learning pages and sources.\n", stderr)
    exit(1)
}
let submissionData = try Data(contentsOf: directory.appendingPathComponent("submission.json"))
let submission = try JSONDecoder().decode([String: String].self, from: submissionData)
let author = [submission["thaiName"], submission["englishName"], submission["studentId"]].compactMap { $0 }.joined(separator: " / ")
editable.documentAttributes = [PDFDocumentAttribute.titleAttribute: "ONYX-01: การพัฒนาคำสั่ง AI", PDFDocumentAttribute.authorAttribute: author, PDFDocumentAttribute.subjectAttribute: "เนื้อหาการเรียนรู้ 6 หัวข้อ พร้อมภาพและคำสั่งก่อน-หลัง"]
let root = PDFOutline()
for (title, page) in [("ปก", 0), ("สารบัญ", 1), ("01 ภาพ AI", 2), ("02 Desmos", 7), ("03 Mermaid", 12), ("04 LaTeX", 17), ("05 NotebookLM", 22), ("06 GitHub", 27), ("แหล่งข้อมูล", 32)] {
    let item = PDFOutline()
    item.label = title
    item.destination = PDFDestination(page: editable.page(at: page)!, at: CGPoint(x: 0, y: 540))
    root.insertChild(item, at: root.numberOfChildren)
}
editable.outlineRoot = root
guard editable.write(to: source), let document = CGPDFDocument(source as CFURL) else { exit(1) }
func export(_ name: String, _ pages: ClosedRange<Int>) {
    let chapter = PDFDocument()
    let url = directory.appendingPathComponent(name)
    for number in pages {
        guard let page = editable.page(at: number - 1)?.copy() as? PDFPage else { exit(1) }
        chapter.insert(page, at: chapter.pageCount)
    }
    chapter.documentAttributes = editable.documentAttributes
    guard chapter.write(to: url) else { exit(1) }
}
for page in 1...30 { export(String(format: "page-%02d.pdf", page), (page + 2)...(page + 2)) }
for page in [1, 2, 33] { export(String(format: "document-%02d.pdf", page), page...page) }
let ids = ["visual", "math", "systems", "document", "slides", "github"]
for (index, id) in ids.enumerated() { export("onyx-\(id).pdf", (index * 5 + 3)...(index * 5 + 7)) }

let previews = URL(fileURLWithPath: "tmp/pdfs", isDirectory: true)
try FileManager.default.createDirectory(at: previews, withIntermediateDirectories: true)
func renderPage(_ number: Int, width: Int) -> CGImage {
    let page = document.page(at: number)!
    let bounds = page.getBoxRect(.mediaBox)
    let height = Int(Double(width) * bounds.height / bounds.width)
    let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    context.setFillColor(CGColor(gray: 1, alpha: 1)); context.fill(CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
    context.scaleBy(x: Double(width) / bounds.width, y: Double(height) / bounds.height)
    context.drawPDFPage(page)
    return context.makeImage()!
}
func png(_ image: CGImage, _ name: String) {
    let url = previews.appendingPathComponent(name)
    let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(destination, image, nil)
    CGImageDestinationFinalize(destination)
}
let sheet = CGContext(data: nil, width: 1280, height: 1620, bitsPerComponent: 8, bytesPerRow: 5120, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
sheet.setFillColor(CGColor(gray: 0.13, alpha: 1)); sheet.fill(CGRect(x: 0, y: 0, width: 1280, height: 1620))
for number in 1...33 {
    let col = (number - 1) % 4; let row = (number - 1) / 4
    sheet.draw(renderPage(number, width: 320), in: CGRect(x: CGFloat(col * 320), y: CGFloat(1620 - (row + 1) * 180), width: 320, height: 180))
}
png(sheet.makeImage()!, "contact-sheet.png")
for number in [1, 4, 5, 6, 9, 10, 11, 14, 15, 16, 19, 20, 21, 25, 28, 29, 30, 31, 32, 33] { png(renderPage(number, width: 1280), String(format: "document-%02d.png", number)) }

let webDestination = URL(fileURLWithPath: "web/downloads/pdfs", isDirectory: true)
try FileManager.default.createDirectory(at: webDestination, withIntermediateDirectories: true)
for file in try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) where file.pathExtension == "pdf" {
    try Data(contentsOf: file).write(to: webDestination.appendingPathComponent(file.lastPathComponent), options: .atomic)
}
print("Created complete PDF (33 pages), 6 chapter PDFs, 30 learning-page PDFs and 3 supplemental-page PDFs. Added bookmarks and Thai metadata; saved copies for web downloads.")
