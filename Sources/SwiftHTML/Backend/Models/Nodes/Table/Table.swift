//
//  Table.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

public struct Table<Data: RandomAccessCollection>: BodyNode, Attributable {
    
    public let data: Data
    public let headerCellStyle: CSS?
    public let cellStyle: CSS?
    public let columns: [Column]
    public let rowBuilder: (Data.Element) -> [HTMLNode]
    
    public var attributes: Attributes = .empty

    public init(
        _ data: Data,
        headerCellStyle: CSS? = nil,
        cellStyle: CSS? = nil,
        @ColumnBuilder columns: () -> [Column],
        @CellBuilder row: @escaping (Data.Element) -> [HTMLNode]
    ) {
        self.data = data
        self.headerCellStyle = headerCellStyle
        self.cellStyle = cellStyle
        self.columns = columns()
        self.rowBuilder = row
    }

    public func render(into output: inout String, indent: Int) {
        let headerRow = GridRow {
            ForEach(columns.indices) { index in
                let column = columns[index]
                GridCell(alignment: column.alignment) {
                    if let headerCellStyle {
                        Text(column.title)
                            .style(headerCellStyle)
                    } else {
                        Text(column.title)
                    }
                }
            }
        }

        let bodyRows = ForEach(data) { element in
            let cells = rowBuilder(element)
            #if DEBUG
            assert(cells.count == columns.count, "Table row has \(cells.count) cells, expected \(columns.count).")
            let renderCount = min(cells.count, columns.count)
            #else
            let renderCount = min(cells.count, columns.count)
            #endif

            return [
                GridRow {
                    ForEach(0..<renderCount) { index in
                        let column = columns[index]
                        let node = cells[index]
                        if let cell = node as? GridCell {
                            if let cellStyle {
                                cell.style(cellStyle)
                            } else {
                                cell
                            }
                        } else {
                            if let cellStyle {
                                GridCell(alignment: column.alignment) {
                                    node
                                }
                                .style(cellStyle)
                            } else {
                                GridCell(alignment: column.alignment) {
                                    node
                                }
                            }
                        }
                    }
                }
            ]
        }

        let table = Grid(role: .presentation, width: "100%", cellpadding: 0, cellspacing: 0, border: 0, attributes: attributes) {
            headerRow
            bodyRows
        }
        
        table.render(into: &output, indent: indent)
    }
}
