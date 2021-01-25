import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(AttributedTextTests.allTests),
        testCase(FrameElementsTests.allTests),
        testCase(FrameRenderingOptionsTests.allTests),
        testCase(DefaultAttributesTests.allTests),
        testCase(PerformanceTests.allTests),
        testCase(AttributedTableTests.allTests),
        testCase(AttributedDocumentTests.allTests),
    ]
}
#endif
