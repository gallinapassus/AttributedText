import XCTest
@testable import AttributedText

final class AttributedTableTests: XCTestCase {
    typealias Document = AttributedDocument<DefaultAttributes>
    typealias Text = AttributedText<DefaultAttributes>
    typealias Table = AttributedTable<DefaultAttributes>
    typealias Header = Table.Header<DefaultAttributes>
    func test_table_mutation() {
        do {
            var t = Table(table: [[Text("R1C1"), Text("R1C2")], [Text("R2C1"), Text("R2C2")]],
                          title: Table.Title<DefaultAttributes>("Title"),
                          columns: [],
                          automaticRowNumbers: false,
                          frameElements: .ascii,
                          frameRenderingOptions: .inside,
                          cellProperty: nil)
            XCTAssertEqual(t.render(), [
                            "Title    ",
                            "R1C1|R1C2",
                            "----+----",
                            "R2C1|R2C2"].joined(separator: "\n"))

            t.automaticRowNumbers = true
            t.frameElements = .rounded()
            t.frameRenderingOptions = .all
            XCTAssertEqual(t.render(), [
                            "╭───────────╮",
                            "│Title      │",
                            "├─┬────┬────┤",
                            "│1│R1C1│R1C2│",
                            "├─┼────┼────┤",
                            "│2│R2C1│R2C2│",
                            "╰─┴────┴────╯"].joined(separator: "\n"))
        }
        do {
            var t = Table(table: [[Text("R1C1"), Text("R1C2")], [Text("R2C1"), Text("R2C2")]],
                          title: Table.Title<DefaultAttributes>("Title"),
                          columns: [Table.Column(Header("Column 1")), Table.Column(Header("Column 2"), width: 6)],
                          automaticRowNumbers: false,
                          frameElements: .squared(),
                          frameRenderingOptions: [.topFrame, .bottomFrame, .leftFrame, .rightFrame, .insideVerticalFrame],
                          cellProperty: nil)
            XCTAssertEqual(t.render(), [
                            "┌───────────────┐",
                            "│Title          │",
                            "├────────┬──────┤",
                            "│Column 1│Column│",
                            "│        │2     │",
                            "│R1C1    │R1C2  │",
                            "│R2C1    │R2C2  │",
                            "└────────┴──────┘"].joined(separator: "\n"))

            t.automaticRowNumbers = true
            t.frameElements = .singleSpace
            t.frameRenderingOptions = .insideVerticalFrame
            t.title = Table.Title("Overwhelmingly long title")
            XCTAssertEqual(t.render(), [
                            "Overwhelmingly   ",
                            "long title       ",
                            "  Column 1 Column",
                            "           2     ",
                            "1 R1C1     R1C2  ",
                            "2 R2C1     R2C2  "].joined(separator: "\n"))
        }
    }
    func test_code_coverage() {
        do {
            let cell = Table.Cell()
            XCTAssertEqual(cell.alignment, .topLeft)
            XCTAssertEqual(cell.wordWrapping, .none)
        }
        do {
            let expected:[String] = [
                [
                    "╭─────┬─────╮",
                    "│C1:12│C2:to│",
                    "│34567│pLeft│",
                    "│89012│     │",
                    "│34567│     │",
                    "│890  │     │",
                    "╰─────┴─────╯",
                ].joined(separator: "\n"),
                [
                    "╭─────┬─────╮",
                    "│C1:12│C2:to│",
                    "│34567│pRigh│",
                    "│89012│    t│",
                    "│34567│     │",
                    "│  890│     │",
                    "╰─────┴─────╯",
                ].joined(separator: "\n"),
                [
                    "╭─────┬─────╮",
                    "│C1:12│C2:to│",
                    "│34567│pCent│",
                    "│89012│ er  │",
                    "│34567│     │",
                    "│ 890 │     │",
                    "╰─────┴─────╯",
                ].joined(separator: "\n"),
                [
                    "╭─────┬─────╮",
                    "│C1:12│     │",
                    "│34567│     │",
                    "│89012│C2:bo│",
                    "│34567│ttomL│",
                    "│890  │eft  │",
                    "╰─────┴─────╯",
                ].joined(separator: "\n"),
                [
                    "╭─────┬─────╮",
                    "│C1:12│     │",
                    "│34567│     │",
                    "│89012│C2:bo│",
                    "│34567│ttomR│",
                    "│  890│ ight│",
                    "╰─────┴─────╯",
                ].joined(separator: "\n"),
                [
                    "╭─────┬─────╮",
                    "│C1:12│     │",
                    "│34567│     │",
                    "│89012│C2:bo│",
                    "│34567│ttomC│",
                    "│ 890 │enter│",
                    "╰─────┴─────╯",
                ].joined(separator: "\n"),
                [
                    "╭─────┬─────╮",
                    "│C1:12│     │",
                    "│34567│C2:mi│",
                    "│89012│ddleL│",
                    "│34567│eft  │",
                    "│890  │     │",
                    "╰─────┴─────╯",
                ].joined(separator: "\n"),
                [
                    "╭─────┬─────╮",
                    "│C1:12│     │",
                    "│34567│C2:mi│",
                    "│89012│ddleR│",
                    "│34567│ ight│",
                    "│  890│     │",
                    "╰─────┴─────╯",
                ].joined(separator: "\n"),
                [
                    "╭─────┬─────╮",
                    "│C1:12│     │",
                    "│34567│C2:mi│",
                    "│89012│ddleC│",
                    "│34567│enter│",
                    "│ 890 │     │",
                    "╰─────┴─────╯",
                ].joined(separator: "\n"),
                [
                    "╭─────┬─────╮",
                    "│C1:12│C2:au│",
                    "│34567│to   │",
                    "│89012│     │",
                    "│34567│     │",
                    "│890  │     │",
                    "╰─────┴─────╯",
                ].joined(separator: "\n"),
                [
                    "╭─────┬─────╮",
                    "│C1:12│C2:au│",
                    "│34567│to   │",
                    "│89012│     │",
                    "│34567│     │",
                    "│890  │     │",
                    "╰─────┴─────╯",
                ].joined(separator: "\n"),
            ]
            for (i,a) in (Alignment.allCases + [Alignment.auto]).enumerated() {
                let src = [[Text("C1:12345678901234567890"), Text("C2:\(a)")]]
                let col = Table.Column<DefaultAttributes>(nil, width: 5,
                                                          alignment: a,
                                                          wrapping: .none)
                let table = Table(table: src,
                                  title: nil,
                                  columns: [col, col],
                                  automaticRowNumbers: false,
                                  frameElements: .rounded(),
                                  frameRenderingOptions: .all,
                                  cellProperty: nil)
                print(table.render())
                XCTAssertEqual(table.render(), expected[i])
            }
        }
    }
    static let allTests = [
        ("test_code_coverage", test_code_coverage),
        ("test_table_mutation", test_table_mutation),
    ]
}
