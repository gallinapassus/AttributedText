import XCTest
@testable import AttributedText

final class FrameRenderingOptionsTests: XCTestCase {
    typealias Document = AttributedDocument<DefaultAttributes>
    typealias Text = AttributedText<DefaultAttributes>
    typealias Table = AttributedTable<DefaultAttributes>

    func test_all_and_none() {
        XCTAssertEqual(FrameRenderingOptions.none.rawValue, 0)
        let str = "Have you added more options? If yes, you should update the FrameElements tests as well."
        XCTAssertEqual(FrameRenderingOptions(rawValue: 1<<6).optionsInEffect, "", str)
        XCTAssertEqual(FrameRenderingOptions(rawValue: 1<<5).optionsInEffect, "insideVerticalFrame", str)
        XCTAssertEqual(FrameRenderingOptions.all.rawValue, 1<<6 - 1, str)
    }
    func test_all_frame_rendering_variations() {
        do {
            let tableSource:[[Text]] = [
                ["a", "b"], ["c","d"]
            ]

            let expectedResults:[String] = [
                /* [0] automaticRowNumbers=true, frameRenderingOptions= */
                [
                "Title  ",
                "row    ",
                " h1hdr2",
                "1a b   ",
                "2c d   "
                ].joined(separator: "\n"),

                /* [1] automaticRowNumbers=true, frameRenderingOptions=topFrame */
                [
                "-------",
                "Title  ",
                "row    ",
                "-------",
                " h1hdr2",
                "1a b   ",
                "2c d   "
                ].joined(separator: "\n"),

                /* [2] automaticRowNumbers=true, frameRenderingOptions=bottomFrame */
                [
                "Title  ",
                "row    ",
                " h1hdr2",
                "1a b   ",
                "2c d   ",
                "-------"
                ].joined(separator: "\n"),

                /* [3] automaticRowNumbers=true, frameRenderingOptions=topFrame, bottomFrame */
                [
                "-------",
                "Title  ",
                "row    ",
                "-------",
                " h1hdr2",
                "1a b   ",
                "2c d   ",
                "-------"
                ].joined(separator: "\n"),

                /* [4] automaticRowNumbers=true, frameRenderingOptions=leftFrame */
                [
                "|Title  ",
                "|row    ",
                "| h1hdr2",
                "|1a b   ",
                "|2c d   "
                ].joined(separator: "\n"),

                /* [5] automaticRowNumbers=true, frameRenderingOptions=topFrame, leftFrame */
                [
                "+-------",
                "|Title  ",
                "|row    ",
                "+-------",
                "| h1hdr2",
                "|1a b   ",
                "|2c d   "
                ].joined(separator: "\n"),

                /* [6] automaticRowNumbers=true, frameRenderingOptions=bottomFrame, leftFrame */
                [
                "|Title  ",
                "|row    ",
                "| h1hdr2",
                "|1a b   ",
                "|2c d   ",
                "+-------"
                ].joined(separator: "\n"),

                /* [7] automaticRowNumbers=true, frameRenderingOptions=topFrame, bottomFrame, leftFrame */
                [
                "+-------",
                "|Title  ",
                "|row    ",
                "+-------",
                "| h1hdr2",
                "|1a b   ",
                "|2c d   ",
                "+-------"
                ].joined(separator: "\n"),

                /* [8] automaticRowNumbers=true, frameRenderingOptions=rightFrame */
                [
                "Title  |",
                "row    |",
                " h1hdr2|",
                "1a b   |",
                "2c d   |"
                ].joined(separator: "\n"),

                /* [9] automaticRowNumbers=true, frameRenderingOptions=topFrame, rightFrame */
                [
                "-------+",
                "Title  |",
                "row    |",
                "-------+",
                " h1hdr2|",
                "1a b   |",
                "2c d   |"
                ].joined(separator: "\n"),

                /* [10] automaticRowNumbers=true, frameRenderingOptions=bottomFrame, rightFrame */
                [
                "Title  |",
                "row    |",
                " h1hdr2|",
                "1a b   |",
                "2c d   |",
                "-------+"
                ].joined(separator: "\n"),

                /* [11] automaticRowNumbers=true, frameRenderingOptions=topFrame, bottomFrame, rightFrame */
                [
                "-------+",
                "Title  |",
                "row    |",
                "-------+",
                " h1hdr2|",
                "1a b   |",
                "2c d   |",
                "-------+"
                ].joined(separator: "\n"),

                /* [12] automaticRowNumbers=true, frameRenderingOptions=leftFrame, rightFrame */
                [
                "|Title  |",
                "|row    |",
                "| h1hdr2|",
                "|1a b   |",
                "|2c d   |"
                ].joined(separator: "\n"),

                /* [13] automaticRowNumbers=true, frameRenderingOptions=topFrame, leftFrame, rightFrame */
                [
                "+-------+",
                "|Title  |",
                "|row    |",
                "+-------+",
                "| h1hdr2|",
                "|1a b   |",
                "|2c d   |"
                ].joined(separator: "\n"),

                /* [14] automaticRowNumbers=true, frameRenderingOptions=bottomFrame, leftFrame, rightFrame */
                [
                "|Title  |",
                "|row    |",
                "| h1hdr2|",
                "|1a b   |",
                "|2c d   |",
                "+-------+"
                ].joined(separator: "\n"),

                /* [15] automaticRowNumbers=true, frameRenderingOptions=topFrame, bottomFrame, leftFrame, rightFrame */
                [
                "+-------+",
                "|Title  |",
                "|row    |",
                "+-------+",
                "| h1hdr2|",
                "|1a b   |",
                "|2c d   |",
                "+-------+"
                ].joined(separator: "\n"),

                /* [16] automaticRowNumbers=true, frameRenderingOptions=insideHorizontalFrame */
                [
                "Title  ",
                "row    ",
                " h1hdr2",
                "-------",
                "1a b   ",
                "-------",
                "2c d   "
                ].joined(separator: "\n"),

                /* [17] automaticRowNumbers=true, frameRenderingOptions=topFrame, insideHorizontalFrame */
                [
                "-------",
                "Title  ",
                "row    ",
                "-------",
                " h1hdr2",
                "-------",
                "1a b   ",
                "-------",
                "2c d   "
                ].joined(separator: "\n"),

                /* [18] automaticRowNumbers=true, frameRenderingOptions=bottomFrame, insideHorizontalFrame */
                [
                "Title  ",
                "row    ",
                " h1hdr2",
                "-------",
                "1a b   ",
                "-------",
                "2c d   ",
                "-------"
                ].joined(separator: "\n"),

                /* [19] automaticRowNumbers=true, frameRenderingOptions=topFrame, bottomFrame, insideHorizontalFrame */
                [
                "-------",
                "Title  ",
                "row    ",
                "-------",
                " h1hdr2",
                "-------",
                "1a b   ",
                "-------",
                "2c d   ",
                "-------"
                ].joined(separator: "\n"),

                /* [20] automaticRowNumbers=true, frameRenderingOptions=leftFrame, insideHorizontalFrame */
                [
                "|Title  ",
                "|row    ",
                "| h1hdr2",
                "+-------",
                "|1a b   ",
                "+-------",
                "|2c d   "
                ].joined(separator: "\n"),

                /* [21] automaticRowNumbers=true, frameRenderingOptions=topFrame, leftFrame, insideHorizontalFrame */
                [
                "+-------",
                "|Title  ",
                "|row    ",
                "+-------",
                "| h1hdr2",
                "+-------",
                "|1a b   ",
                "+-------",
                "|2c d   "
                ].joined(separator: "\n"),

                /* [22] automaticRowNumbers=true, frameRenderingOptions=bottomFrame, leftFrame, insideHorizontalFrame */
                [
                "|Title  ",
                "|row    ",
                "| h1hdr2",
                "+-------",
                "|1a b   ",
                "+-------",
                "|2c d   ",
                "+-------"
                ].joined(separator: "\n"),

                /* [23] automaticRowNumbers=true, frameRenderingOptions=topFrame, bottomFrame, leftFrame, insideHorizontalFrame */
                [
                "+-------",
                "|Title  ",
                "|row    ",
                "+-------",
                "| h1hdr2",
                "+-------",
                "|1a b   ",
                "+-------",
                "|2c d   ",
                "+-------"
                ].joined(separator: "\n"),

                /* [24] automaticRowNumbers=true, frameRenderingOptions=rightFrame, insideHorizontalFrame */
                [
                "Title  |",
                "row    |",
                " h1hdr2|",
                "-------+",
                "1a b   |",
                "-------+",
                "2c d   |"
                ].joined(separator: "\n"),

                /* [25] automaticRowNumbers=true, frameRenderingOptions=topFrame, rightFrame, insideHorizontalFrame */
                [
                "-------+",
                "Title  |",
                "row    |",
                "-------+",
                " h1hdr2|",
                "-------+",
                "1a b   |",
                "-------+",
                "2c d   |"
                ].joined(separator: "\n"),

                /* [26] automaticRowNumbers=true, frameRenderingOptions=bottomFrame, rightFrame, insideHorizontalFrame */
                [
                "Title  |",
                "row    |",
                " h1hdr2|",
                "-------+",
                "1a b   |",
                "-------+",
                "2c d   |",
                "-------+"
                ].joined(separator: "\n"),

                /* [27] automaticRowNumbers=true, frameRenderingOptions=topFrame, bottomFrame, rightFrame, insideHorizontalFrame */
                [
                "-------+",
                "Title  |",
                "row    |",
                "-------+",
                " h1hdr2|",
                "-------+",
                "1a b   |",
                "-------+",
                "2c d   |",
                "-------+"
                ].joined(separator: "\n"),

                /* [28] automaticRowNumbers=true, frameRenderingOptions=leftFrame, rightFrame, insideHorizontalFrame */
                [
                "|Title  |",
                "|row    |",
                "| h1hdr2|",
                "+-------+",
                "|1a b   |",
                "+-------+",
                "|2c d   |"
                ].joined(separator: "\n"),

                /* [29] automaticRowNumbers=true, frameRenderingOptions=topFrame, leftFrame, rightFrame, insideHorizontalFrame */
                [
                "+-------+",
                "|Title  |",
                "|row    |",
                "+-------+",
                "| h1hdr2|",
                "+-------+",
                "|1a b   |",
                "+-------+",
                "|2c d   |"
                ].joined(separator: "\n"),

                /* [30] automaticRowNumbers=true, frameRenderingOptions=bottomFrame, leftFrame, rightFrame, insideHorizontalFrame */
                [
                "|Title  |",
                "|row    |",
                "| h1hdr2|",
                "+-------+",
                "|1a b   |",
                "+-------+",
                "|2c d   |",
                "+-------+"
                ].joined(separator: "\n"),

                /* [31] automaticRowNumbers=true, frameRenderingOptions=topFrame, bottomFrame, leftFrame, rightFrame, insideHorizontalFrame */
                [
                "+-------+",
                "|Title  |",
                "|row    |",
                "+-------+",
                "| h1hdr2|",
                "+-------+",
                "|1a b   |",
                "+-------+",
                "|2c d   |",
                "+-------+"
                ].joined(separator: "\n"),

                /* [32] automaticRowNumbers=true, frameRenderingOptions=insideVerticalFrame */
                [
                "Title row",
                " |h1|hdr2",
                "1|a |b   ",
                "2|c |d   "
                ].joined(separator: "\n"),

                /* [33] automaticRowNumbers=true, frameRenderingOptions=topFrame, insideVerticalFrame */
                [
                "---------",
                "Title row",
                "-+--+----",
                " |h1|hdr2",
                "1|a |b   ",
                "2|c |d   "
                ].joined(separator: "\n"),

                /* [34] automaticRowNumbers=true, frameRenderingOptions=bottomFrame, insideVerticalFrame */
                [
                "Title row",
                " |h1|hdr2",
                "1|a |b   ",
                "2|c |d   ",
                "-+--+----"
                ].joined(separator: "\n"),

                /* [35] automaticRowNumbers=true, frameRenderingOptions=topFrame, bottomFrame, insideVerticalFrame */
                [
                "---------",
                "Title row",
                "-+--+----",
                " |h1|hdr2",
                "1|a |b   ",
                "2|c |d   ",
                "-+--+----"
                ].joined(separator: "\n"),

                /* [36] automaticRowNumbers=true, frameRenderingOptions=leftFrame, insideVerticalFrame */
                [
                "|Title row",
                "| |h1|hdr2",
                "|1|a |b   ",
                "|2|c |d   "
                ].joined(separator: "\n"),

                /* [37] automaticRowNumbers=true, frameRenderingOptions=topFrame, leftFrame, insideVerticalFrame */
                [
                "+---------",
                "|Title row",
                "+-+--+----",
                "| |h1|hdr2",
                "|1|a |b   ",
                "|2|c |d   "
                ].joined(separator: "\n"),

                /* [38] automaticRowNumbers=true, frameRenderingOptions=bottomFrame, leftFrame, insideVerticalFrame */
                [
                "|Title row",
                "| |h1|hdr2",
                "|1|a |b   ",
                "|2|c |d   ",
                "+-+--+----"
                ].joined(separator: "\n"),

                /* [39] automaticRowNumbers=true, frameRenderingOptions=topFrame, bottomFrame, leftFrame, insideVerticalFrame */
                [
                "+---------",
                "|Title row",
                "+-+--+----",
                "| |h1|hdr2",
                "|1|a |b   ",
                "|2|c |d   ",
                "+-+--+----"
                ].joined(separator: "\n"),

                /* [40] automaticRowNumbers=true, frameRenderingOptions=rightFrame, insideVerticalFrame */
                [
                "Title row|",
                " |h1|hdr2|",
                "1|a |b   |",
                "2|c |d   |"
                ].joined(separator: "\n"),

                /* [41] automaticRowNumbers=true, frameRenderingOptions=topFrame, rightFrame, insideVerticalFrame */
                [
                "---------+",
                "Title row|",
                "-+--+----+",
                " |h1|hdr2|",
                "1|a |b   |",
                "2|c |d   |"
                ].joined(separator: "\n"),

                /* [42] automaticRowNumbers=true, frameRenderingOptions=bottomFrame, rightFrame, insideVerticalFrame */
                [
                "Title row|",
                " |h1|hdr2|",
                "1|a |b   |",
                "2|c |d   |",
                "-+--+----+"
                ].joined(separator: "\n"),

                /* [43] automaticRowNumbers=true, frameRenderingOptions=topFrame, bottomFrame, rightFrame, insideVerticalFrame */
                [
                "---------+",
                "Title row|",
                "-+--+----+",
                " |h1|hdr2|",
                "1|a |b   |",
                "2|c |d   |",
                "-+--+----+"
                ].joined(separator: "\n"),

                /* [44] automaticRowNumbers=true, frameRenderingOptions=leftFrame, rightFrame, insideVerticalFrame */
                [
                "|Title row|",
                "| |h1|hdr2|",
                "|1|a |b   |",
                "|2|c |d   |"
                ].joined(separator: "\n"),

                /* [45] automaticRowNumbers=true, frameRenderingOptions=topFrame, leftFrame, rightFrame, insideVerticalFrame */
                [
                "+---------+",
                "|Title row|",
                "+-+--+----+",
                "| |h1|hdr2|",
                "|1|a |b   |",
                "|2|c |d   |"
                ].joined(separator: "\n"),

                /* [46] automaticRowNumbers=true, frameRenderingOptions=bottomFrame, leftFrame, rightFrame, insideVerticalFrame */
                [
                "|Title row|",
                "| |h1|hdr2|",
                "|1|a |b   |",
                "|2|c |d   |",
                "+-+--+----+"
                ].joined(separator: "\n"),

                /* [47] automaticRowNumbers=true, frameRenderingOptions=topFrame, bottomFrame, leftFrame, rightFrame, insideVerticalFrame */
                [
                "+---------+",
                "|Title row|",
                "+-+--+----+",
                "| |h1|hdr2|",
                "|1|a |b   |",
                "|2|c |d   |",
                "+-+--+----+"
                ].joined(separator: "\n"),

                /* [48] automaticRowNumbers=true, frameRenderingOptions=insideHorizontalFrame, insideVerticalFrame */
                [
                "Title row",
                " |h1|hdr2",
                "-+--+----",
                "1|a |b   ",
                "-+--+----",
                "2|c |d   "
                ].joined(separator: "\n"),

                /* [49] automaticRowNumbers=true, frameRenderingOptions=topFrame, insideHorizontalFrame, insideVerticalFrame */
                [
                "---------",
                "Title row",
                "-+--+----",
                " |h1|hdr2",
                "-+--+----",
                "1|a |b   ",
                "-+--+----",
                "2|c |d   "
                ].joined(separator: "\n"),

                /* [50] automaticRowNumbers=true, frameRenderingOptions=bottomFrame, insideHorizontalFrame, insideVerticalFrame */
                [
                "Title row",
                " |h1|hdr2",
                "-+--+----",
                "1|a |b   ",
                "-+--+----",
                "2|c |d   ",
                "-+--+----"
                ].joined(separator: "\n"),

                /* [51] automaticRowNumbers=true, frameRenderingOptions=topFrame, bottomFrame, insideHorizontalFrame, insideVerticalFrame */
                [
                "---------",
                "Title row",
                "-+--+----",
                " |h1|hdr2",
                "-+--+----",
                "1|a |b   ",
                "-+--+----",
                "2|c |d   ",
                "-+--+----"
                ].joined(separator: "\n"),

                /* [52] automaticRowNumbers=true, frameRenderingOptions=leftFrame, insideHorizontalFrame, insideVerticalFrame */
                [
                "|Title row",
                "| |h1|hdr2",
                "+-+--+----",
                "|1|a |b   ",
                "+-+--+----",
                "|2|c |d   "
                ].joined(separator: "\n"),

                /* [53] automaticRowNumbers=true, frameRenderingOptions=topFrame, leftFrame, insideHorizontalFrame, insideVerticalFrame */
                [
                "+---------",
                "|Title row",
                "+-+--+----",
                "| |h1|hdr2",
                "+-+--+----",
                "|1|a |b   ",
                "+-+--+----",
                "|2|c |d   "
                ].joined(separator: "\n"),

                /* [54] automaticRowNumbers=true, frameRenderingOptions=bottomFrame, leftFrame, insideHorizontalFrame, insideVerticalFrame */
                [
                "|Title row",
                "| |h1|hdr2",
                "+-+--+----",
                "|1|a |b   ",
                "+-+--+----",
                "|2|c |d   ",
                "+-+--+----"
                ].joined(separator: "\n"),

                /* [55] automaticRowNumbers=true, frameRenderingOptions=topFrame, bottomFrame, leftFrame, insideHorizontalFrame, insideVerticalFrame */
                [
                "+---------",
                "|Title row",
                "+-+--+----",
                "| |h1|hdr2",
                "+-+--+----",
                "|1|a |b   ",
                "+-+--+----",
                "|2|c |d   ",
                "+-+--+----"
                ].joined(separator: "\n"),

                /* [56] automaticRowNumbers=true, frameRenderingOptions=rightFrame, insideHorizontalFrame, insideVerticalFrame */
                [
                "Title row|",
                " |h1|hdr2|",
                "-+--+----+",
                "1|a |b   |",
                "-+--+----+",
                "2|c |d   |"
                ].joined(separator: "\n"),

                /* [57] automaticRowNumbers=true, frameRenderingOptions=topFrame, rightFrame, insideHorizontalFrame, insideVerticalFrame */
                [
                "---------+",
                "Title row|",
                "-+--+----+",
                " |h1|hdr2|",
                "-+--+----+",
                "1|a |b   |",
                "-+--+----+",
                "2|c |d   |"
                ].joined(separator: "\n"),

                /* [58] automaticRowNumbers=true, frameRenderingOptions=bottomFrame, rightFrame, insideHorizontalFrame, insideVerticalFrame */
                [
                "Title row|",
                " |h1|hdr2|",
                "-+--+----+",
                "1|a |b   |",
                "-+--+----+",
                "2|c |d   |",
                "-+--+----+"
                ].joined(separator: "\n"),

                /* [59] automaticRowNumbers=true, frameRenderingOptions=topFrame, bottomFrame, rightFrame, insideHorizontalFrame, insideVerticalFrame */
                [
                "---------+",
                "Title row|",
                "-+--+----+",
                " |h1|hdr2|",
                "-+--+----+",
                "1|a |b   |",
                "-+--+----+",
                "2|c |d   |",
                "-+--+----+"
                ].joined(separator: "\n"),

                /* [60] automaticRowNumbers=true, frameRenderingOptions=leftFrame, rightFrame, insideHorizontalFrame, insideVerticalFrame */
                [
                "|Title row|",
                "| |h1|hdr2|",
                "+-+--+----+",
                "|1|a |b   |",
                "+-+--+----+",
                "|2|c |d   |"
                ].joined(separator: "\n"),

                /* [61] automaticRowNumbers=true, frameRenderingOptions=topFrame, leftFrame, rightFrame, insideHorizontalFrame, insideVerticalFrame */
                [
                "+---------+",
                "|Title row|",
                "+-+--+----+",
                "| |h1|hdr2|",
                "+-+--+----+",
                "|1|a |b   |",
                "+-+--+----+",
                "|2|c |d   |"
                ].joined(separator: "\n"),

                /* [62] automaticRowNumbers=true, frameRenderingOptions=bottomFrame, leftFrame, rightFrame, insideHorizontalFrame, insideVerticalFrame */
                [
                "|Title row|",
                "| |h1|hdr2|",
                "+-+--+----+",
                "|1|a |b   |",
                "+-+--+----+",
                "|2|c |d   |",
                "+-+--+----+"
                ].joined(separator: "\n"),

                /* [63] automaticRowNumbers=true, frameRenderingOptions=topFrame, bottomFrame, leftFrame, rightFrame, insideHorizontalFrame, insideVerticalFrame */
                [
                "+---------+",
                "|Title row|",
                "+-+--+----+",
                "| |h1|hdr2|",
                "+-+--+----+",
                "|1|a |b   |",
                "+-+--+----+",
                "|2|c |d   |",
                "+-+--+----+"
                ].joined(separator: "\n"),

                /* [64] automaticRowNumbers=false, frameRenderingOptions= */
                [
                "Title ",
                "row   ",
                "h1hdr2",
                "a b   ",
                "c d   "
                ].joined(separator: "\n"),

                /* [65] automaticRowNumbers=false, frameRenderingOptions=topFrame */
                [
                "------",
                "Title ",
                "row   ",
                "------",
                "h1hdr2",
                "a b   ",
                "c d   "
                ].joined(separator: "\n"),

                /* [66] automaticRowNumbers=false, frameRenderingOptions=bottomFrame */
                [
                "Title ",
                "row   ",
                "h1hdr2",
                "a b   ",
                "c d   ",
                "------"
                ].joined(separator: "\n"),

                /* [67] automaticRowNumbers=false, frameRenderingOptions=topFrame, bottomFrame */
                [
                "------",
                "Title ",
                "row   ",
                "------",
                "h1hdr2",
                "a b   ",
                "c d   ",
                "------"
                ].joined(separator: "\n"),

                /* [68] automaticRowNumbers=false, frameRenderingOptions=leftFrame */
                [
                "|Title ",
                "|row   ",
                "|h1hdr2",
                "|a b   ",
                "|c d   "
                ].joined(separator: "\n"),

                /* [69] automaticRowNumbers=false, frameRenderingOptions=topFrame, leftFrame */
                [
                "+------",
                "|Title ",
                "|row   ",
                "+------",
                "|h1hdr2",
                "|a b   ",
                "|c d   "
                ].joined(separator: "\n"),

                /* [70] automaticRowNumbers=false, frameRenderingOptions=bottomFrame, leftFrame */
                [
                "|Title ",
                "|row   ",
                "|h1hdr2",
                "|a b   ",
                "|c d   ",
                "+------"
                ].joined(separator: "\n"),

                /* [71] automaticRowNumbers=false, frameRenderingOptions=topFrame, bottomFrame, leftFrame */
                [
                "+------",
                "|Title ",
                "|row   ",
                "+------",
                "|h1hdr2",
                "|a b   ",
                "|c d   ",
                "+------"
                ].joined(separator: "\n"),

                /* [72] automaticRowNumbers=false, frameRenderingOptions=rightFrame */
                [
                "Title |",
                "row   |",
                "h1hdr2|",
                "a b   |",
                "c d   |"
                ].joined(separator: "\n"),

                /* [73] automaticRowNumbers=false, frameRenderingOptions=topFrame, rightFrame */
                [
                "------+",
                "Title |",
                "row   |",
                "------+",
                "h1hdr2|",
                "a b   |",
                "c d   |"
                ].joined(separator: "\n"),

                /* [74] automaticRowNumbers=false, frameRenderingOptions=bottomFrame, rightFrame */
                [
                "Title |",
                "row   |",
                "h1hdr2|",
                "a b   |",
                "c d   |",
                "------+"
                ].joined(separator: "\n"),

                /* [75] automaticRowNumbers=false, frameRenderingOptions=topFrame, bottomFrame, rightFrame */
                [
                "------+",
                "Title |",
                "row   |",
                "------+",
                "h1hdr2|",
                "a b   |",
                "c d   |",
                "------+"
                ].joined(separator: "\n"),

                /* [76] automaticRowNumbers=false, frameRenderingOptions=leftFrame, rightFrame */
                [
                "|Title |",
                "|row   |",
                "|h1hdr2|",
                "|a b   |",
                "|c d   |"
                ].joined(separator: "\n"),

                /* [77] automaticRowNumbers=false, frameRenderingOptions=topFrame, leftFrame, rightFrame */
                [
                "+------+",
                "|Title |",
                "|row   |",
                "+------+",
                "|h1hdr2|",
                "|a b   |",
                "|c d   |"
                ].joined(separator: "\n"),

                /* [78] automaticRowNumbers=false, frameRenderingOptions=bottomFrame, leftFrame, rightFrame */
                [
                "|Title |",
                "|row   |",
                "|h1hdr2|",
                "|a b   |",
                "|c d   |",
                "+------+"
                ].joined(separator: "\n"),

                /* [79] automaticRowNumbers=false, frameRenderingOptions=topFrame, bottomFrame, leftFrame, rightFrame */
                [
                "+------+",
                "|Title |",
                "|row   |",
                "+------+",
                "|h1hdr2|",
                "|a b   |",
                "|c d   |",
                "+------+"
                ].joined(separator: "\n"),

                /* [80] automaticRowNumbers=false, frameRenderingOptions=insideHorizontalFrame */
                [
                "Title ",
                "row   ",
                "h1hdr2",
                "------",
                "a b   ",
                "------",
                "c d   "
                ].joined(separator: "\n"),

                /* [81] automaticRowNumbers=false, frameRenderingOptions=topFrame, insideHorizontalFrame */
                [
                "------",
                "Title ",
                "row   ",
                "------",
                "h1hdr2",
                "------",
                "a b   ",
                "------",
                "c d   "
                ].joined(separator: "\n"),

                /* [82] automaticRowNumbers=false, frameRenderingOptions=bottomFrame, insideHorizontalFrame */
                [
                "Title ",
                "row   ",
                "h1hdr2",
                "------",
                "a b   ",
                "------",
                "c d   ",
                "------"
                ].joined(separator: "\n"),

                /* [83] automaticRowNumbers=false, frameRenderingOptions=topFrame, bottomFrame, insideHorizontalFrame */
                [
                "------",
                "Title ",
                "row   ",
                "------",
                "h1hdr2",
                "------",
                "a b   ",
                "------",
                "c d   ",
                "------"
                ].joined(separator: "\n"),

                /* [84] automaticRowNumbers=false, frameRenderingOptions=leftFrame, insideHorizontalFrame */
                [
                "|Title ",
                "|row   ",
                "|h1hdr2",
                "+------",
                "|a b   ",
                "+------",
                "|c d   "
                ].joined(separator: "\n"),

                /* [85] automaticRowNumbers=false, frameRenderingOptions=topFrame, leftFrame, insideHorizontalFrame */
                [
                "+------",
                "|Title ",
                "|row   ",
                "+------",
                "|h1hdr2",
                "+------",
                "|a b   ",
                "+------",
                "|c d   "
                ].joined(separator: "\n"),

                /* [86] automaticRowNumbers=false, frameRenderingOptions=bottomFrame, leftFrame, insideHorizontalFrame */
                [
                "|Title ",
                "|row   ",
                "|h1hdr2",
                "+------",
                "|a b   ",
                "+------",
                "|c d   ",
                "+------"
                ].joined(separator: "\n"),

                /* [87] automaticRowNumbers=false, frameRenderingOptions=topFrame, bottomFrame, leftFrame, insideHorizontalFrame */
                [
                "+------",
                "|Title ",
                "|row   ",
                "+------",
                "|h1hdr2",
                "+------",
                "|a b   ",
                "+------",
                "|c d   ",
                "+------"
                ].joined(separator: "\n"),

                /* [88] automaticRowNumbers=false, frameRenderingOptions=rightFrame, insideHorizontalFrame */
                [
                "Title |",
                "row   |",
                "h1hdr2|",
                "------+",
                "a b   |",
                "------+",
                "c d   |"
                ].joined(separator: "\n"),

                /* [89] automaticRowNumbers=false, frameRenderingOptions=topFrame, rightFrame, insideHorizontalFrame */
                [
                "------+",
                "Title |",
                "row   |",
                "------+",
                "h1hdr2|",
                "------+",
                "a b   |",
                "------+",
                "c d   |"
                ].joined(separator: "\n"),

                /* [90] automaticRowNumbers=false, frameRenderingOptions=bottomFrame, rightFrame, insideHorizontalFrame */
                [
                "Title |",
                "row   |",
                "h1hdr2|",
                "------+",
                "a b   |",
                "------+",
                "c d   |",
                "------+"
                ].joined(separator: "\n"),

                /* [91] automaticRowNumbers=false, frameRenderingOptions=topFrame, bottomFrame, rightFrame, insideHorizontalFrame */
                [
                "------+",
                "Title |",
                "row   |",
                "------+",
                "h1hdr2|",
                "------+",
                "a b   |",
                "------+",
                "c d   |",
                "------+"
                ].joined(separator: "\n"),

                /* [92] automaticRowNumbers=false, frameRenderingOptions=leftFrame, rightFrame, insideHorizontalFrame */
                [
                "|Title |",
                "|row   |",
                "|h1hdr2|",
                "+------+",
                "|a b   |",
                "+------+",
                "|c d   |"
                ].joined(separator: "\n"),

                /* [93] automaticRowNumbers=false, frameRenderingOptions=topFrame, leftFrame, rightFrame, insideHorizontalFrame */
                [
                "+------+",
                "|Title |",
                "|row   |",
                "+------+",
                "|h1hdr2|",
                "+------+",
                "|a b   |",
                "+------+",
                "|c d   |"
                ].joined(separator: "\n"),

                /* [94] automaticRowNumbers=false, frameRenderingOptions=bottomFrame, leftFrame, rightFrame, insideHorizontalFrame */
                [
                "|Title |",
                "|row   |",
                "|h1hdr2|",
                "+------+",
                "|a b   |",
                "+------+",
                "|c d   |",
                "+------+"
                ].joined(separator: "\n"),

                /* [95] automaticRowNumbers=false, frameRenderingOptions=topFrame, bottomFrame, leftFrame, rightFrame, insideHorizontalFrame */
                [
                "+------+",
                "|Title |",
                "|row   |",
                "+------+",
                "|h1hdr2|",
                "+------+",
                "|a b   |",
                "+------+",
                "|c d   |",
                "+------+"
                ].joined(separator: "\n"),

                /* [96] automaticRowNumbers=false, frameRenderingOptions=insideVerticalFrame */
                [
                "Title  ",
                "row    ",
                "h1|hdr2",
                "a |b   ",
                "c |d   "
                ].joined(separator: "\n"),

                /* [97] automaticRowNumbers=false, frameRenderingOptions=topFrame, insideVerticalFrame */
                [
                "-------",
                "Title  ",
                "row    ",
                "--+----",
                "h1|hdr2",
                "a |b   ",
                "c |d   "
                ].joined(separator: "\n"),

                /* [98] automaticRowNumbers=false, frameRenderingOptions=bottomFrame, insideVerticalFrame */
                [
                "Title  ",
                "row    ",
                "h1|hdr2",
                "a |b   ",
                "c |d   ",
                "--+----"
                ].joined(separator: "\n"),

                /* [99] automaticRowNumbers=false, frameRenderingOptions=topFrame, bottomFrame, insideVerticalFrame */
                [
                "-------",
                "Title  ",
                "row    ",
                "--+----",
                "h1|hdr2",
                "a |b   ",
                "c |d   ",
                "--+----"
                ].joined(separator: "\n"),

                /* [100] automaticRowNumbers=false, frameRenderingOptions=leftFrame, insideVerticalFrame */
                [
                "|Title  ",
                "|row    ",
                "|h1|hdr2",
                "|a |b   ",
                "|c |d   "
                ].joined(separator: "\n"),

                /* [101] automaticRowNumbers=false, frameRenderingOptions=topFrame, leftFrame, insideVerticalFrame */
                [
                "+-------",
                "|Title  ",
                "|row    ",
                "+--+----",
                "|h1|hdr2",
                "|a |b   ",
                "|c |d   "
                ].joined(separator: "\n"),

                /* [102] automaticRowNumbers=false, frameRenderingOptions=bottomFrame, leftFrame, insideVerticalFrame */
                [
                "|Title  ",
                "|row    ",
                "|h1|hdr2",
                "|a |b   ",
                "|c |d   ",
                "+--+----"
                ].joined(separator: "\n"),

                /* [103] automaticRowNumbers=false, frameRenderingOptions=topFrame, bottomFrame, leftFrame, insideVerticalFrame */
                [
                "+-------",
                "|Title  ",
                "|row    ",
                "+--+----",
                "|h1|hdr2",
                "|a |b   ",
                "|c |d   ",
                "+--+----"
                ].joined(separator: "\n"),

                /* [104] automaticRowNumbers=false, frameRenderingOptions=rightFrame, insideVerticalFrame */
                [
                "Title  |",
                "row    |",
                "h1|hdr2|",
                "a |b   |",
                "c |d   |"
                ].joined(separator: "\n"),

                /* [105] automaticRowNumbers=false, frameRenderingOptions=topFrame, rightFrame, insideVerticalFrame */
                [
                "-------+",
                "Title  |",
                "row    |",
                "--+----+",
                "h1|hdr2|",
                "a |b   |",
                "c |d   |"
                ].joined(separator: "\n"),

                /* [106] automaticRowNumbers=false, frameRenderingOptions=bottomFrame, rightFrame, insideVerticalFrame */
                [
                "Title  |",
                "row    |",
                "h1|hdr2|",
                "a |b   |",
                "c |d   |",
                "--+----+"
                ].joined(separator: "\n"),

                /* [107] automaticRowNumbers=false, frameRenderingOptions=topFrame, bottomFrame, rightFrame, insideVerticalFrame */
                [
                "-------+",
                "Title  |",
                "row    |",
                "--+----+",
                "h1|hdr2|",
                "a |b   |",
                "c |d   |",
                "--+----+"
                ].joined(separator: "\n"),

                /* [108] automaticRowNumbers=false, frameRenderingOptions=leftFrame, rightFrame, insideVerticalFrame */
                [
                "|Title  |",
                "|row    |",
                "|h1|hdr2|",
                "|a |b   |",
                "|c |d   |"
                ].joined(separator: "\n"),

                /* [109] automaticRowNumbers=false, frameRenderingOptions=topFrame, leftFrame, rightFrame, insideVerticalFrame */
                [
                "+-------+",
                "|Title  |",
                "|row    |",
                "+--+----+",
                "|h1|hdr2|",
                "|a |b   |",
                "|c |d   |"
                ].joined(separator: "\n"),

                /* [110] automaticRowNumbers=false, frameRenderingOptions=bottomFrame, leftFrame, rightFrame, insideVerticalFrame */
                [
                "|Title  |",
                "|row    |",
                "|h1|hdr2|",
                "|a |b   |",
                "|c |d   |",
                "+--+----+"
                ].joined(separator: "\n"),

                /* [111] automaticRowNumbers=false, frameRenderingOptions=topFrame, bottomFrame, leftFrame, rightFrame, insideVerticalFrame */
                [
                "+-------+",
                "|Title  |",
                "|row    |",
                "+--+----+",
                "|h1|hdr2|",
                "|a |b   |",
                "|c |d   |",
                "+--+----+"
                ].joined(separator: "\n"),

                /* [112] automaticRowNumbers=false, frameRenderingOptions=insideHorizontalFrame, insideVerticalFrame */
                [
                "Title  ",
                "row    ",
                "h1|hdr2",
                "--+----",
                "a |b   ",
                "--+----",
                "c |d   "
                ].joined(separator: "\n"),

                /* [113] automaticRowNumbers=false, frameRenderingOptions=topFrame, insideHorizontalFrame, insideVerticalFrame */
                [
                "-------",
                "Title  ",
                "row    ",
                "--+----",
                "h1|hdr2",
                "--+----",
                "a |b   ",
                "--+----",
                "c |d   "
                ].joined(separator: "\n"),

                /* [114] automaticRowNumbers=false, frameRenderingOptions=bottomFrame, insideHorizontalFrame, insideVerticalFrame */
                [
                "Title  ",
                "row    ",
                "h1|hdr2",
                "--+----",
                "a |b   ",
                "--+----",
                "c |d   ",
                "--+----"
                ].joined(separator: "\n"),

                /* [115] automaticRowNumbers=false, frameRenderingOptions=topFrame, bottomFrame, insideHorizontalFrame, insideVerticalFrame */
                [
                "-------",
                "Title  ",
                "row    ",
                "--+----",
                "h1|hdr2",
                "--+----",
                "a |b   ",
                "--+----",
                "c |d   ",
                "--+----"
                ].joined(separator: "\n"),

                /* [116] automaticRowNumbers=false, frameRenderingOptions=leftFrame, insideHorizontalFrame, insideVerticalFrame */
                [
                "|Title  ",
                "|row    ",
                "|h1|hdr2",
                "+--+----",
                "|a |b   ",
                "+--+----",
                "|c |d   "
                ].joined(separator: "\n"),

                /* [117] automaticRowNumbers=false, frameRenderingOptions=topFrame, leftFrame, insideHorizontalFrame, insideVerticalFrame */
                [
                "+-------",
                "|Title  ",
                "|row    ",
                "+--+----",
                "|h1|hdr2",
                "+--+----",
                "|a |b   ",
                "+--+----",
                "|c |d   "
                ].joined(separator: "\n"),

                /* [118] automaticRowNumbers=false, frameRenderingOptions=bottomFrame, leftFrame, insideHorizontalFrame, insideVerticalFrame */
                [
                "|Title  ",
                "|row    ",
                "|h1|hdr2",
                "+--+----",
                "|a |b   ",
                "+--+----",
                "|c |d   ",
                "+--+----"
                ].joined(separator: "\n"),

                /* [119] automaticRowNumbers=false, frameRenderingOptions=topFrame, bottomFrame, leftFrame, insideHorizontalFrame, insideVerticalFrame */
                [
                "+-------",
                "|Title  ",
                "|row    ",
                "+--+----",
                "|h1|hdr2",
                "+--+----",
                "|a |b   ",
                "+--+----",
                "|c |d   ",
                "+--+----"
                ].joined(separator: "\n"),

                /* [120] automaticRowNumbers=false, frameRenderingOptions=rightFrame, insideHorizontalFrame, insideVerticalFrame */
                [
                "Title  |",
                "row    |",
                "h1|hdr2|",
                "--+----+",
                "a |b   |",
                "--+----+",
                "c |d   |"
                ].joined(separator: "\n"),

                /* [121] automaticRowNumbers=false, frameRenderingOptions=topFrame, rightFrame, insideHorizontalFrame, insideVerticalFrame */
                [
                "-------+",
                "Title  |",
                "row    |",
                "--+----+",
                "h1|hdr2|",
                "--+----+",
                "a |b   |",
                "--+----+",
                "c |d   |"
                ].joined(separator: "\n"),

                /* [122] automaticRowNumbers=false, frameRenderingOptions=bottomFrame, rightFrame, insideHorizontalFrame, insideVerticalFrame */
                [
                "Title  |",
                "row    |",
                "h1|hdr2|",
                "--+----+",
                "a |b   |",
                "--+----+",
                "c |d   |",
                "--+----+"
                ].joined(separator: "\n"),

                /* [123] automaticRowNumbers=false, frameRenderingOptions=topFrame, bottomFrame, rightFrame, insideHorizontalFrame, insideVerticalFrame */
                [
                "-------+",
                "Title  |",
                "row    |",
                "--+----+",
                "h1|hdr2|",
                "--+----+",
                "a |b   |",
                "--+----+",
                "c |d   |",
                "--+----+"
                ].joined(separator: "\n"),

                /* [124] automaticRowNumbers=false, frameRenderingOptions=leftFrame, rightFrame, insideHorizontalFrame, insideVerticalFrame */
                [
                "|Title  |",
                "|row    |",
                "|h1|hdr2|",
                "+--+----+",
                "|a |b   |",
                "+--+----+",
                "|c |d   |"
                ].joined(separator: "\n"),

                /* [125] automaticRowNumbers=false, frameRenderingOptions=topFrame, leftFrame, rightFrame, insideHorizontalFrame, insideVerticalFrame */
                [
                "+-------+",
                "|Title  |",
                "|row    |",
                "+--+----+",
                "|h1|hdr2|",
                "+--+----+",
                "|a |b   |",
                "+--+----+",
                "|c |d   |"
                ].joined(separator: "\n"),

                /* [126] automaticRowNumbers=false, frameRenderingOptions=bottomFrame, leftFrame, rightFrame, insideHorizontalFrame, insideVerticalFrame */
                [
                "|Title  |",
                "|row    |",
                "|h1|hdr2|",
                "+--+----+",
                "|a |b   |",
                "+--+----+",
                "|c |d   |",
                "+--+----+"
                ].joined(separator: "\n"),

                /* [127] automaticRowNumbers=false, frameRenderingOptions=topFrame, bottomFrame, leftFrame, rightFrame, insideHorizontalFrame, insideVerticalFrame */
                [
                "+-------+",
                "|Title  |",
                "|row    |",
                "+--+----+",
                "|h1|hdr2|",
                "+--+----+",
                "|a |b   |",
                "+--+----+",
                "|c |d   |",
                "+--+----+"
                ].joined(separator: "\n"),
            ]
            var i = 0
            for automaticRowNumbers in [true,false] {
                for x in 0..<(1<<6) { // Go through all variations
                    let frameRenderingOptions = FrameRenderingOptions(rawValue: x)
                    let table = Table(table: tableSource,
                                      title: "Title row",
                                      columns: [Table.Column("h1", width: .auto),
                                                Table.Column("hdr2", width: .auto)],
                                      automaticRowNumbers: automaticRowNumbers,
                                      frameElements: .ascii,
                                      frameRenderingOptions: frameRenderingOptions)
                    //print("/* [\(i)] automaticRowNumbers=\(automaticRowNumbers), frameRenderingOptions=\(frameRenderingOptions.optionsInEffect) */")
                    //print(table.render())
                    // Create expected results
                    /*
                    print("[")
                    let rows = table.render().split(separator: "\n").map { "\"\($0)\"" }
                    print(rows.joined(separator: ",\n"))
                    print("].joined(separator: \"\\n\"),\n")
                     */
                    XCTAssertEqual(table.render(), expectedResults[i])
                    i += 1
                }
            }
        }
    }
    static var allTests = [
        ("test_all_and_none", test_all_and_none),
        ("test_all_frame_rendering_variations", test_all_frame_rendering_variations)
    ]
}
