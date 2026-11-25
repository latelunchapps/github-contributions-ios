//
//  TilesShape.swift
//  InterfaceKit
//

import SwiftUI

/// Rounded squares drawn as one shape, so each level is a single view however many days it has.
struct TilesShape: Shape {
    let rects: [CGRect]
    let cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cornerSize = CGSize(width: cornerRadius, height: cornerRadius)
        for tile in rects {
            path.addRoundedRect(in: tile.offsetBy(dx: rect.minX, dy: rect.minY), cornerSize: cornerSize, style: .continuous)
        }
        return path
    }
}
