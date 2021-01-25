
public struct AttributedTable<Attributes:AttributeProtocol> : Rendable {

    public struct Cell : Equatable {
        var alignment:Alignment     = .topLeft
        var wordWrapping:WordWrap   = .none
    }
    public struct Column<Attributes:AttributeProtocol> {
        public let header:Header<Attributes>?
        public let width:Width
        public let cell:Cell
        public init(_ header:Header<Attributes>? = nil, width:Width = .auto, alignment:Alignment = .topLeft, wrapping:WordWrap = .word) {
            self.header = header
            self.cell = Cell(alignment: alignment, wordWrapping: wrapping)
            self.width = width
        }
    }
    public struct Header<Attributes:AttributeProtocol> : ExpressibleByStringLiteral {
        public typealias StringLiteralType = String
        public let text:AttributedText<Attributes>
        public let cell:Cell
        public init(stringLiteral: StringLiteralType) {
            self.init(AttributedText<Attributes>(stringLiteral))
        }
        public init(_ text:AttributedText<Attributes>, alignment:Alignment = .topLeft, wrapping:WordWrap = .word) {
            self.text = text
            self.cell = Cell(alignment: alignment, wordWrapping: wrapping)
        }
    }
    public typealias Title = Header

    public var automaticRowNumbers:Bool
    public var title:Title<Attributes>? = nil
    public var frameElements: FrameElements<Attributes>? = nil
    public var frameRenderingOptions: FrameRenderingOptions = .all
    private (set) public var columns: [Column<Attributes>]
    public var cellPropertyClosure:((Int, Int)->Cell)?
    private var layout: [[[AttributedText<Attributes>]]]
    private var calculatedWidths: [Width]
    private var hasHeaders:Bool
    // MARK: -
    // Table + static definitions
    public init(table source:[[AttributedText<Attributes>]],
                title:Title<Attributes>? = nil,
                columns: [Column<Attributes>] = [],
                automaticRowNumbers:Bool = false,
                frameElements: FrameElements<Attributes> = .default,
                frameRenderingOptions: FrameRenderingOptions = .all,
                cellProperty override:((Int, Int) -> Cell)? = nil) {
        self.automaticRowNumbers = automaticRowNumbers
        self.title = title
        self.frameElements = frameElements
        self.frameRenderingOptions = frameRenderingOptions
        self.columns = columns
        self.cellPropertyClosure = override
        self.layout = []
        self.calculatedWidths = []
        self.hasHeaders = columns.filter( { $0.header != nil }).isEmpty == false
        let dataSource = hasHeaders ? [columns.map { $0.header?.text ?? .init() }] + source : source
        let (tableLayout,calculatedWidths) = layout(table: dataSource)
        self.layout = tableLayout
        self.calculatedWidths = calculatedWidths
    }
    // MARK: -
    // MARK: Rendering
    public func render() -> String {
        return self.renderLayout()
    }
    // MARK: -
    private func equalizeElementCount(table source:[[AttributedText<Attributes>]]) -> [[AttributedText<Attributes>]] {
        var copy = source
        let maxElementCount = copy.reduce(0, { Swift.max($0, $1.count) })
        for i in copy.indices {
            if copy[i].count < maxElementCount {
                for _ in 1...(maxElementCount - copy[i].count) {
                    copy[i].append(.init())
                }
            }
        }
        return copy
    }
    private func layout(table source:[[AttributedText<Attributes>]]) -> (layout:[[[AttributedText<Attributes>]]], columnDefinitions:[Width]) {
        // Autofill missing column definitions
        let columnCount = source.reduce(0, { Swift.max($0, $1.count) })
        let pscp = columns + Array(repeating: Column(), count: Swift.max(0, (columnCount - (columns.count))))
        //let hasHeaders = pscp.prefix(while: { $0.header != nil }).isEmpty == false
        var columnWidths:[Width] = pscp.map { $0.width }
            .prefix(columnCount) + Array<Width>(repeating: .auto, count: Swift.max(0, (columnCount - (columns.count))))

        // Update column widths for .auto columns
        for (i,coldef) in columnWidths.prefix(columnCount).enumerated() {
            guard coldef == .auto else { // Fast
                // Not auto, use given width
                columnWidths[i] = coldef
                continue
            }
            // Calculate width for .auto columns
            for j in source { // Slow
                guard j.count > i else {
                    continue
                }
                let autoWidth:Int = j[i].reduce("", { $0 + "\($1)" })
                    .split(whereSeparator: { $0.isNewline })
                    .reduce(0, { Swift.max($0, $1.count) })
                columnWidths[i] = Width(Swift.max(columnWidths[i].value, autoWidth))
            }
        }

        // Equalize element count + fit vertically & horizontally
        var layout:[[[AttributedText<Attributes>]]] = []
        for (rowIndex,row) in self.equalizeElementCount(table: source).enumerated() {

            // Pass 1: fit horizontally
            var rowHeight = 0
            var hfittedColumns:[[AttributedText<Attributes>]] = []
            for (colIndex,(cdef, col)) in zip(columnWidths,row).enumerated() {

                // ---
                let alignment:Alignment
                let wrapping:WordWrap
                if let overrideClosure = cellPropertyClosure {
                    let cell = overrideClosure(rowIndex, colIndex)
                    alignment = rowIndex == 0 && hasHeaders ? pscp[colIndex].header?.cell.alignment ?? .topLeft : cell.alignment
                    wrapping = rowIndex == 0 && hasHeaders ? pscp[colIndex].header?.cell.wordWrapping ?? .none : cell.wordWrapping
                }
                else {
                    alignment = rowIndex == 0 && hasHeaders ? pscp[colIndex].header?.cell.alignment ?? .topLeft : pscp[colIndex].cell.alignment
                    wrapping = rowIndex == 0 && hasHeaders ? pscp[colIndex].header?.cell.wordWrapping ?? .none : pscp[colIndex].cell.wordWrapping
                }
                // ---
                let w:Int = cdef.value
                if w == Width.hidden.value { continue }
                let fittedColumn = fit(col, toWidth: w, wordWrap: wrapping)
                let hpadded = fittedColumn.map { $0.padHorizontally(for: w, alignment) }
                rowHeight = Swift.max(rowHeight, fittedColumn.count)
                hfittedColumns.append(hpadded)
            }
            // Pass 2: fit vertically
            // Note: hidden columns are no longer present in hfittedColumns)
            var vfittedColumns:[[AttributedText<Attributes>]] = []
            for (colIndex,(cdef, colRows)) in zip(columnWidths.filter({ $0 != .hidden }),hfittedColumns).enumerated() {
                let w:Int = cdef.value
                // ---
                let alignment:Alignment
                if let overrideClosure = cellPropertyClosure {
                    let cell = overrideClosure(rowIndex, colIndex)
                    alignment = rowIndex == 0 ? pscp[colIndex].header?.cell.alignment ?? .topLeft : cell.alignment
                }
                else {
                    alignment = rowIndex == 0 && hasHeaders ? pscp[colIndex].header?.cell.alignment ?? .topLeft : pscp[colIndex].cell.alignment
                }
                // ---

                let vpadded = padVertically(column: colRows, for: rowHeight, alignment)
                vfittedColumns.append(vpadded.map { $0.padHorizontally(for: w, alignment)})
            }
            layout.append(vfittedColumns.transposed())
        }
        return (layout, columnWidths)
    }
    private func renderLayout() -> String {


        let rowNumberWidth = "\(layout.count + 1)".count
        // PreRender horizontal column separator elements
        var preRenderedTopHorizontalTitleSeparators:[String] = []
        var preRenderedTopHorizontalSeparators:[String]      = []
        var preRenderedInsideHorizontalSeparators:[String]   = []
        var preRenderedBottomHorizontalSeparators:[String]   = []

        var ttlwdth:Int = 0
        if let vrow = layout.first,
           let row = vrow.first,
           let frameElements = frameElements {
            ttlwdth = vrow.reduce(0, { $0 + $1.reduce(0, { $0 + $1.count })}) + ((frameRenderingOptions.contains(.insideVerticalFrame) ? frameElements.insideHorizontalVerticalSeparator.unattributedString.count : 0) * vrow.reduce(0, { $0 + $1.count }) - 1)

            ttlwdth += automaticRowNumbers ? (rowNumberWidth + frameElements.insideHorizontalVerticalSeparator.unattributedString.count) : 0
            for c in row {
                do {
                    var lt = frameElements.topHorizontalSeparator
                    let rep = lt
                    for _ in 0..<c.count - 1 {
                        lt.appending(rep)
                    }
                    preRenderedTopHorizontalSeparators.append(lt.render())
                }
                do {
                    var lt = frameElements.bottomHorizontalSeparator
                    let rep = lt
                    for _ in 0..<c.count - 1 {
                        lt.appending(rep)
                    }
                    preRenderedBottomHorizontalSeparators.append(lt.render())
                }
                do {
                    var lt = frameElements.insideHorizontalSeparator
                    let rep = lt
                    for _ in 0..<c.count - 1 {
                        lt.appending(rep)
                    }
                    preRenderedInsideHorizontalSeparators.append(lt.render())
                }
            }
            do {
                let len = row.map { $0.count }.reduce(0, +) + (automaticRowNumbers ? rowNumberWidth : 0)
                var lt = frameElements.topHorizontalSeparator
                let rep = lt
                for _ in 0..<len {
                    lt.appending(rep)
                }
                preRenderedTopHorizontalTitleSeparators.append(lt.render())
            }
        }

        // Generate rendered output
        var stream:String = ""
        // Title
        if let vrow = layout.first,
           let row = vrow.first,
           let frameElements = frameElements,
           let title = title {
            if frameRenderingOptions.contains(.topFrame) {
                if frameRenderingOptions.contains(.leftFrame) { // topLeftCorner
                    stream.append(frameElements.topLeftCorner.render())
                }
                var tr = AttributedText<Attributes>()
                for col in row  {
                    for _ in col {
                        tr.appending(frameElements.topHorizontalSeparator)
                    }
                }
                if frameRenderingOptions.contains(.insideVerticalFrame) {
                    for _ in 0..<(row.count - (automaticRowNumbers ? 0 : 1)) {
                        for _ in 0..<frameElements.insideVerticalSeparator.count {
                            tr.appending(frameElements.topHorizontalSeparator)
                        }
                    }
                }
                if automaticRowNumbers {
                    for _ in 0..<rowNumberWidth {
                        tr.appending(frameElements.topHorizontalSeparator)
                    }
                }
                stream.append(tr.render(/*with: renderer*/))
                if frameRenderingOptions.contains(.rightFrame) { // topRightCorner
                    stream.append(frameElements.topRightCorner.render())
                }
                stream.append("\n")
            }
            ttlwdth = calculatedWidths.reduce(0, { $0 + ($1.value < 0 ? 0 : $1.value) }) // Calculated widths
            //print(#line, calculatedWidths, calculatedWidths.map { $0.value }, ttlwdth)
            ttlwdth += automaticRowNumbers ? rowNumberWidth : 0 // Add rowNumberWidth if automatic row numbers is enabled
            //print(#line, ttlwdth)
            ttlwdth += (row.count - (automaticRowNumbers ? 0 : 1)) * (frameRenderingOptions.contains(.insideVerticalFrame) ? frameElements.insideVerticalSeparator.unattributedString.count : 0) // Add vert separator width
            //print(#line, row.count, "-", (automaticRowNumbers ? 0 : 1),"x", (frameRenderingOptions.contains(.insideVerticalFrame) ? frameElements.insideVerticalSeparator.unattributedString.count : 0), ttlwdth)

            let fitted = fit(title.text, toWidth: ttlwdth, wordWrap: title.cell.wordWrapping)
            for line in fitted {
                if frameRenderingOptions.contains(.leftFrame) {
                    stream.append(frameElements.leftVerticalSeparator.render())
                }
                stream.append(line.padHorizontally(for: ttlwdth, title.cell.alignment).render(/*with: renderer*/))
                if frameRenderingOptions.contains(.rightFrame) {
                    stream.append(frameElements.rightVerticalSeparator.render())
                }
                stream.append("\n")
            }
        }
        // Top row
        if let vrow = layout.first,
           let row = vrow.first,
           let frameElements = frameElements,
           frameRenderingOptions.contains(.topFrame) {

            if frameRenderingOptions.contains(.leftFrame) {
                if title != nil {
                    stream.append(frameElements.insideLeftVerticalSeparator.render())
                }
                else {
                    stream.append(frameElements.topLeftCorner.render())
                }
            }
            if automaticRowNumbers {
                stream.append(String(repeating: frameElements.topHorizontalSeparator.render(), count: rowNumberWidth))
                if frameRenderingOptions.contains(.insideVerticalFrame) {
                    stream.append(frameElements.topHorizontalVerticalSeparator.render())
                }
            }
            for i in 0..<row.count {
                stream.append(preRenderedTopHorizontalSeparators[i])
                if i + 1 < row.count,
                   frameRenderingOptions.contains(.insideVerticalFrame) {
                    stream.append(frameElements.topHorizontalVerticalSeparator.render())
                }
            }
            if title != nil {
                if frameRenderingOptions.contains(.rightFrame) {
                    stream.append(frameElements.insideRightVerticalSeparator.render())
                }
            }
            else {
                if frameRenderingOptions.contains(.rightFrame) {
                    stream.append(frameElements.topRightCorner.render())
                }
            }
            stream.append("\n")
        }

        // Inside rows
        for (rowIdx,tableRow) in layout.enumerated() {
            for (colIdx,row) in tableRow.enumerated() {
                var rowElements:[String] = []
                if automaticRowNumbers {
                    if colIdx == 0, (hasHeaders == false || rowIdx > 0) {
                        rowElements.append(String((String(repeating: " ", count: rowNumberWidth) + "\(rowIdx + (hasHeaders ? 0 : 1))").suffix(rowNumberWidth)))
                    }
                    else {
                        rowElements.append(String(repeating: " ", count: rowNumberWidth))
                    }
                }
                // Inside individual rows
                row.forEach({ rowElements.append($0.render()) })
                var tmp = ""
                if let frameElements = frameElements {
                    let rowContent:String
                    if frameRenderingOptions.contains(.insideVerticalFrame) {
                        rowContent = String(rowElements.joined(separator: frameElements.insideVerticalSeparator.render()))
                    }
                    else {
                        rowContent = String(rowElements.joined())
                    }

                    if frameRenderingOptions.contains(.leftFrame) {
                        tmp.append(frameElements.leftVerticalSeparator.render())
                    }
                    tmp.append(rowContent)
                    if frameRenderingOptions.contains(.rightFrame) {
                        tmp.append(frameElements.rightVerticalSeparator.render())
                    }
                }
                else {
                    let rowContent = rowElements.joined()
                    tmp.append(rowContent)
                }
                stream.append(tmp + "\n")
            }
            // Inside row separation
            if rowIdx + 1 < layout.count,
               let vrow = layout.first,
               let row = vrow.first,
               let frameElements = frameElements,
               frameRenderingOptions.contains(.insideHorizontalFrame) {
                if frameRenderingOptions.contains(.leftFrame) {
                    stream.append(frameElements.insideLeftVerticalSeparator.render())
                }
                if automaticRowNumbers {
                    stream.append(String(repeating: frameElements.insideHorizontalSeparator.render(), count: rowNumberWidth))
                    if frameRenderingOptions.contains(.insideVerticalFrame) {
                        stream.append(frameElements.insideHorizontalVerticalSeparator.render())
                    }
                }
                for i in 0..<row.count {
                    stream.append(preRenderedInsideHorizontalSeparators[i])
                    if i + 1 < row.count,
                       frameRenderingOptions.contains(.insideVerticalFrame) {
                        stream.append(frameElements.insideHorizontalVerticalSeparator.render())
                    }
                }
                if frameRenderingOptions.contains(.rightFrame) {
                    stream.append(frameElements.insideRightVerticalSeparator.render())
                }
                stream.append("\n")
            }
        }
        // Bottom row
        if frameRenderingOptions.contains(.bottomFrame),
           let vrow = layout.first,
           let row = vrow.first,
           let frameElements = frameElements {
            if frameRenderingOptions.contains(.leftFrame) {
                stream.append(frameElements.bottomLeftCorner.render())
            }
            if automaticRowNumbers {
                stream.append(String(repeating: frameElements.bottomHorizontalSeparator.render(), count: rowNumberWidth))
                if frameRenderingOptions.contains(.insideVerticalFrame) {
                    stream.append(frameElements.bottomHorizontalVerticalSeparator.render())
                }
            }
            for i in 0..<row.count {
                stream.append(preRenderedBottomHorizontalSeparators[i])
                if i + 1 < row.count,
                   frameRenderingOptions.contains(.insideVerticalFrame) {
                    stream.append(frameElements.bottomHorizontalVerticalSeparator.render())
                }
            }
            if frameRenderingOptions.contains(.rightFrame) {
                stream.append(frameElements.bottomRightCorner.render())
            }
        }
        else {
            if stream.last?.isNewline ?? false {
                _ = stream.popLast()
            }
        }
        return stream
    }
    private func padVertically(column rows:[AttributedText<Attributes>], for height:Int, _ alignment:Alignment) -> [AttributedText<Attributes>] {
        let clamped = rows.prefix(height)
        switch alignment {
        // TODO: Alignment .auto
        // Current implementation of .auto means alignment
        // vertically to "top".
        // But, for example depending on the data type, it could be
        // "middle" or "bottom".
        case .auto, .topLeft, .topCenter, .topRight:
            let padder = Array(repeating: AttributedText<Attributes>(), count: Swift.max(0, height - clamped.count))
            return clamped + padder
        case .middleLeft, .middleCenter, .middleRight:
            let top = Array(repeating: AttributedText<Attributes>(), count: Swift.max(0, height - clamped.count) / 2)
            let bottom = Array(repeating: AttributedText<Attributes>(), count: Swift.max(0, height - clamped.count) - top.count)
            return top + clamped + bottom
        case .bottomLeft, .bottomCenter, .bottomRight:
            let padder = Array(repeating: AttributedText<Attributes>(), count: Swift.max(0, height - clamped.count))
            return padder + clamped
        }
    }
}
extension AttributedTable : TextOutputStreamable {
    public func write<Target>(to target: inout Target) where Target : TextOutputStream {
        target.write(self.render())
    }
}
