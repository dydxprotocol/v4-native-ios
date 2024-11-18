//
//  dydxOrderbookAsksView.swift
//  dydxViews
//
//  Created by John Huang on 1/4/23.
//

import dydxFormatter
import PlatformUI
import SwiftUI
import Utilities

public struct dydxOrderbookLine: Identifiable, Equatable {
    public var id: String {
        return "\(price)"
    }

    public let price: Double
    public let size: Double
    public let sizeText: String
    public let depth: Double?
    public let taken: Double?
    public let textColor: ThemeColor.SemanticColor

    public init(price: Double, size: Double, sizeText: String, depth: Double?, taken: Double?, textColor: ThemeColor.SemanticColor) {
        self.price = price
        self.size = size
        self.sizeText = sizeText
        self.depth = depth
        self.taken = taken
        self.textColor = textColor
    }
}

/// Delegates what happens upon price selection action
public protocol dydxOrderbookSideDelegate: AnyObject {
    func onPriceSelected(price: Double)
}

public class dydxOrderbookSideViewModel: PlatformViewModel, Equatable {
    public static func == (lhs: dydxOrderbookSideViewModel, rhs: dydxOrderbookSideViewModel) -> Bool {
        lhs.tickSize == rhs.tickSize &&
            lhs.lines == rhs.lines &&
            lhs.maxDepth == rhs.maxDepth &&
            lhs.displayStyle == rhs.displayStyle
    }

    public enum DisplayStyle {
        case topDown, sideBySide

        var intendedLineHeight: CGFloat {
            switch self {
            case .sideBySide: return 20
            case .topDown: return 16
            }
        }

        var spacing: CGFloat {
            switch self {
            case .sideBySide: return 8
            case .topDown: return 4
            }
        }
    }

    @Published public var tickSize: String?
    @Published public var lines = [dydxOrderbookLine]()
    @Published public var maxDepth: Double = 0.0
    @Published public var displayStyle: DisplayStyle = .topDown
    weak var delegate: dydxOrderbookSideDelegate?

    override public func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _ in
            guard let self = self else { return AnyView(PlatformView.nilView) }
            let maxDepth = self.maxDepth > 0.0 ? self.maxDepth : 100.0
            return AnyView(
                self.list(lines: self.lines, maxDepth: maxDepth)
                    .clipped()
            )
        }
    }

    func list(lines: [dydxOrderbookLine], maxDepth: Double) -> any View {
        return GeometryReader { [weak self] metrics in

            if let self = self {
                let spacing: CGFloat = displayStyle.spacing
                let intendedLineHeight: CGFloat = displayStyle.intendedLineHeight
                let effectiveAvailableHeight: CGFloat = (metrics.size.height + spacing)
                let numLinesToDisplayExact: CGFloat = effectiveAvailableHeight / (intendedLineHeight + spacing)
                let numLinesToDisplayFloored: CGFloat = trunc(numLinesToDisplayExact)
                let numLinesToDisplayInt: Int = Int(numLinesToDisplayExact)
                let additionalLineHeight: CGFloat = intendedLineHeight * (numLinesToDisplayExact.truncatingRemainder(dividingBy: 1)) / numLinesToDisplayFloored
                let actualLineHeight: CGFloat = intendedLineHeight + additionalLineHeight

                LazyVStack(spacing: spacing) {
                    ForEach(lines.prefix(numLinesToDisplayInt), id: \.self.id) { line in
                        AnyView(
                            self.cell(line: line, maxDepth: maxDepth, fixedHeight: actualLineHeight)
                        )
                        .id(line.id)
                    }

                    Spacer()
                }
                .animation(.default, value: lines) // Here the animation is applied to the LazyVStack
                .topAligned()
            }
        }
    }

    func cell(line: dydxOrderbookLine, maxDepth: Double, fixedHeight: Double?) -> any View {
        let lineView =
            ZStack {
                AnyView(depthBar(line: line, maxDepth: maxDepth))

                switch displayStyle {
                case .sideBySide:
                    AnyView(
                        sideBySideView(line: line)
                            .themeColor(foreground: line.textColor)
                            .padding(.horizontal, 12)
                            .themeFont(fontType: .number, fontSize: .medium)
                    )
                case .topDown:
                    AnyView(
                        topDownView(line: line)
                            .themeColor(foreground: line.textColor)
                            .padding(.horizontal, 8)
                            .themeFont(fontType: .number, fontSize: .smaller)
                    )
                }
            }

        return Group {
            if let fixedHeight = fixedHeight, fixedHeight > 0 {
                lineView
                    .frame(height: fixedHeight)
                    .animation(.default, value: line)
            } else {
                 lineView
                    .frame(maxHeight: .infinity)
                    .animation(.default, value: line)
            }
        }
        .contentShape(.rect)
        .onTapGesture {[weak self, line] in
            self?.delegate?.onPriceSelected(price: line.price)
        }
    }

    func sideBySideView(line: dydxOrderbookLine) -> any View {
        HStack(spacing: 8) {
            let priceText = dydxFormatter.shared.dollar(number: line.price, size: tickSize)
            Text(priceText ?? "")
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .leftAligned()
                .frame(maxWidth: .infinity)

            Text(line.sizeText)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .rightAligned()
                .frame(maxWidth: .infinity)
        }
    }

    func topDownView(line: dydxOrderbookLine) -> any View {
        HStack(spacing: 4) {
            let priceText = dydxFormatter.shared.dollar(number: line.price, size: tickSize)
            Text(line.sizeText)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .leftAligned()
                .frame(maxWidth: .infinity)

            Text(priceText ?? "")
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .rightAligned()
                .frame(maxWidth: .infinity)
        }
    }

    func depthBar(line: dydxOrderbookLine, maxDepth: Double) -> any View {
        GeometryReader { [weak self] geometry in
            let width = geometry.size.width
            let sizeRatio = min(1.0, (line.size) / maxDepth)
            let depthRatio = min(1.0, (line.depth ?? 0.0) / maxDepth)
            let takenRatio = min(1.0, (line.taken ?? 0.0) / maxDepth)
            ZStack {
                self?.color().color.opacity(0.2)
                    .frame(width: width * depthRatio)
                    .cornerRadius(4, corners: [.topRight, .bottomRight])
                    .leftAligned()

                self?.color().color.opacity(0.6)
                    .frame(width: width * sizeRatio)
                    .cornerRadius(4, corners: [.topRight, .bottomRight])
                    .leftAligned()

                ThemeColor.SemanticColor.colorYellow.color.opacity(0.9)
                    .frame(width: width * takenRatio)
                    .cornerRadius(4, corners: [.topRight, .bottomRight])
                    .leftAligned()
            }
        }
    }

    func color() -> ThemeColor.SemanticColor {
        return ThemeSettings.positiveColor
    }
}

public class dydxOrderbookAsksViewModel: dydxOrderbookSideViewModel {
    override internal func list(lines: [dydxOrderbookLine], maxDepth: Double) -> any View {
        let list = super.list(lines: lines, maxDepth: maxDepth)
        switch displayStyle {
        case .topDown:
            return list.flipped(.vertical)
        case .sideBySide:
            return list
        }
    }

    override internal func cell(line: dydxOrderbookLine, maxDepth: Double, fixedHeight: Double?) -> any View {
        let cell = super.cell(line: line, maxDepth: maxDepth, fixedHeight: fixedHeight)
        switch displayStyle {
        case .topDown:
            return cell.flipped(.vertical)
        case .sideBySide:
            return cell
        }
    }

    override func depthBar(line: dydxOrderbookLine, maxDepth: Double) -> any View {
        let depthBar = super.depthBar(line: line, maxDepth: maxDepth)
        switch displayStyle {
        case .topDown:
            return depthBar
        case .sideBySide:
            return depthBar
                .flipped(.horizontal)
        }
    }

    override func color() -> ThemeColor.SemanticColor {
        return ThemeSettings.negativeColor
    }

    override func sideBySideView(line: dydxOrderbookLine) -> any View {
        HStack(spacing: 8) {
            let priceText = dydxFormatter.shared.dollar(number: line.price, size: tickSize)
            Text(line.sizeText)
                .themeFont(fontType: .number, fontSize: .medium)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .leftAligned()
                .frame(maxWidth: .infinity)

            Text(priceText ?? "")
                .themeFont(fontType: .number, fontSize: .medium)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .rightAligned()
                .frame(maxWidth: .infinity)
        }
    }
}

public class dydxOrderbookBidsViewModel: dydxOrderbookSideViewModel {}
