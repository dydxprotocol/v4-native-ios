//
//  SingleAxisGeometryReader.swift
//  PlatformUI
//
//  Created by Michael Maguire on 6/7/24.
//

import SwiftUI

// https://stackoverflow.com/questions/64778379/how-to-use-geometry-reader-so-that-the-view-does-not-expand
// "this view can get messed up in transition animations, beware"
/// A view which acts as a geometry reader being greedy only in a single axis..
public struct SingleAxisGeometryReader<Content: View>: View {
    public static var defaultSize: CGFloat { 10 }

    public init(size: CGFloat = SingleAxisGeometryReader.defaultSize, axis: Axis = .horizontal, alignment: Alignment = .center, content: @escaping ((CGFloat) -> Content)) {
        self.size = size
        self.axis = axis
        self.alignment = alignment
        self.content = content
    }

    private struct SizeKey: PreferenceKey {
        static var defaultValue: CGFloat { SingleAxisGeometryReader.defaultSize }
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }

    @State private var size: CGFloat
    /// the greedy dimension
    var axis: Axis = .horizontal
    var alignment: Alignment = .center
    let content: (CGFloat) -> Content

    public var body: some View {
        content(size)
            .frame(maxWidth: axis == .horizontal ? .infinity : nil,
                   maxHeight: axis == .vertical   ? .infinity : nil,
                   alignment: alignment)
            .background(GeometryReader {
                proxy in
                Color.clear.preference(key: SizeKey.self, value: axis == .horizontal ? proxy.size.width : proxy.size.height)
            }).onPreferenceChange(SizeKey.self) { size = $0 }
    }
}
