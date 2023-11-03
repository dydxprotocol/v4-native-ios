//
//  MarginUsage.swift
//  dydxViews
//
//  Created by Rui Huang on 10/18/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities
import dydxFormatter

public class MarginUsageModel: PlatformViewModel {
    public enum DisplayOption {
        case iconOnly
        case iconAndValue
    }
    @Published public var percent: Double = 0 {
        didSet {
            updateProgress()
        }
    }
    @Published public var viewSize: CGFloat = 18
    @Published public var lineWidth: CGFloat = 3 {
        didSet {
            updateLineWidth()
        }
    }
    @Published public var displayOption: DisplayOption = .iconAndValue

    private lazy var progressView: CircularProgressViewModel = {
        let progressView = CircularProgressViewModel()
        return progressView
    }()

    public init(percent: Double = 0, viewSize: CGFloat = 18, lineWidth: CGFloat = 3, displayOption: DisplayOption = .iconAndValue) {
        self.percent = percent
        self.viewSize = viewSize
        self.lineWidth = lineWidth
        self.displayOption = displayOption
        super.init()
        updateProgress()
        updateLineWidth()
    }

    private func updateProgress() {
        if percent <= 0.2 {
            let positive = ThemeSettings.positiveColor.color
            progressView.innerTrackColor = positive
            progressView.outerTrackColor = positive
        } else if percent <= 0.4 {
            let yellow = ThemeColor.SemanticColor.colorYellow.color
            progressView.innerTrackColor = yellow
            progressView.outerTrackColor = yellow
        } else {
            let negative = ThemeSettings.negativeColor.color
            progressView.innerTrackColor = negative
            progressView.outerTrackColor = negative
        }

        progressView.progress = percent
    }

    private func updateLineWidth() {
        progressView.lineWidth = lineWidth
    }

    public static var previewValue: MarginUsageModel {
        let vm = MarginUsageModel()
        vm.percent = 0.9
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let marginPercent = dydxFormatter.shared.percent(number: self.percent, digits: 2)

            return AnyView(
                HStack {
                    self.progressView
                        .createView(parentStyle: style)
                        .frame(width: self.viewSize, height: self.viewSize)
                        .padding(self.lineWidth)
                    if self.displayOption == .iconAndValue {
                        Text(marginPercent ?? "")
                            .themeFont(fontType: .number, fontSize: .small)
                            .lineLimit(1)
                    }
                }
            )
        }
    }
}

#if DEBUG
struct MarginUsage_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return MarginUsageModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct MarginUsage_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return MarginUsageModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
