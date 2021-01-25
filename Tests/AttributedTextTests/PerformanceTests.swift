import XCTest
@testable import AttributedText

@available (iOS 10.0, *)
internal extension UnitDuration {
    static var milliseconds:UnitDuration {
        return UnitDuration(symbol: "ms", converter: UnitConverterLinear(coefficient: 0.001))
    }
}
final class PerformanceTests: XCTestCase {
    typealias Document = AttributedDocument<DefaultAttributes>
    typealias Text = AttributedText<DefaultAttributes>
    typealias Table = AttributedTable<DefaultAttributes>

    #if os(macOS)
    override class var defaultMetrics: [XCTMetric] {
        [
          XCTClockMetric(),
          XCTCPUMetric(limitingToCurrentThread: true),
          XCTMemoryMetric(),
        ]
      }
    #endif

    private func _now() -> Double {
        return Date().timeIntervalSince1970
    }
    @available (iOS 10.0, *)
    func test_performance() {

        let sections = 2
        let rowCount = 15
        let columnCount = 15

        var table:[[Text]] = []
        for r in 1...rowCount {
            var vrow:[Text] = []
            for c in 1...columnCount {
                vrow.append(Text("r\(r) c\(c)", .bold))
            }
            table.append(vrow)
        }
        var wrapdefsForColumns:[[Table.Column<DefaultAttributes>]] = []
        for w in WordWrap.allCases {
            wrapdefsForColumns.append(
                Array(repeating: Table.Column(width: Width(2),
                                              alignment: .topLeft,
                                              wrapping: w),
                      count: columnCount)
            )
        }
        let code = {
            let doc = Document()
            let t0 = self._now()
            for _ in 0..<sections {
                for def in wrapdefsForColumns {
                    doc.append(Text("\(def.first!.cell.wordWrapping)"))
                    doc.append(Table(table: table,
                                     columns: def,
                                     automaticRowNumbers: true,
                                     frameElements: .ascii,
                                     frameRenderingOptions: .all))
                }
            }
            let t1 = self._now()
            _ = doc.render()
            let t2 = self._now()
            let durationInit = Measurement(value: t1-t0, unit: UnitDuration.seconds).converted(to: UnitDuration.milliseconds)
            let durationRender = Measurement(value: t2-t1, unit: UnitDuration.seconds).converted(to: UnitDuration.milliseconds)
            #if os(macOS) || os(iOS)
            let formatter = MeasurementFormatter()
            formatter.numberFormatter = NumberFormatter()
            formatter.unitOptions = .providedUnit
            formatter.unitStyle = .long
            formatter.numberFormatter.minimumFractionDigits = 3
            formatter.numberFormatter.maximumFractionDigits = 3
            print("init:", formatter.string(from: durationInit),
                  "render:", formatter.string(from: durationRender))
            #else
            print("init:", durationInit,
                  "render:", durationRender)
            #endif
        }
        //        code()
        #if os(macOS) || os(iOS)
        if #available(iOS 13.0, *) {
            self.measure(metrics: Self.defaultMetrics) {
                code()
            }
        }
        else {
            self.measure {
                code()
            }
        }
        #elseif os(Linux)
        for _ in 0..<10 {
            code()
        }
        #else
        print("Not implemented.")
        #endif
    }
    static let allTests = [
        ("test_performance", test_performance)
    ]
}
