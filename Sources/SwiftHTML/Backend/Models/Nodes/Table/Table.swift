//
//  Table.swift
//  swift-html
//
//  Created by Damian Van de Kauter on 08/01/2026.
//

public struct Table<Data: RandomAccessCollection>: BodyNode {
    
    public let data: Data
    public let gridStyle: String
    public let headerCellStyle: String
    public let cellStyle: String
    public let columns: [Column]
    public let rowBuilder: (Data.Element) -> [HTMLNode]

    public init(
        _ data: Data,
        gridStyle: String = "width: 100%;",
        headerCellStyle: String = "font-weight: 600; padding: 8px 0; border-bottom: 1px solid #e5e7eb;",
        cellStyle: String = "padding: 8px 0; border-bottom: 1px solid #f3f4f6;",
        @ColumnBuilder columns: () -> [Column],
        @CellBuilder row: @escaping (Data.Element) -> [HTMLNode]
    ) {
        self.data = data
        self.gridStyle = gridStyle
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
                    Text(column.title).style(headerCellStyle)
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
                            cell
                        } else {
                            GridCell(alignment: column.alignment) {
                                node
                            }
                        }
                    }
                }
            ]
        }

        let table = Grid(role: .presentation, width: "100%", cellpadding: 0, cellspacing: 0, border: 0) {
            headerRow
            bodyRows
        }
        .style(gridStyle)

        table.render(into: &output, indent: indent)
    }
}
