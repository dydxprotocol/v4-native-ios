//
//  dydxPredictionMarketsNoticeView.swift
//  dydxViews
//
//  Created by Michael Maguire on 8/9/24.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxPredictionMarketsNoticeViewModel: PlatformViewModel {
    @Published public var hidePredictionMarketsNotice = false
    @Published public var continueAction: (() -> Void)?

    public init() { }

    public static var previewValue: dydxPredictionMarketsNoticeViewModel {
        let vm = dydxPredictionMarketsNoticeViewModel()
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }
            return dydxPredictionMarketsNoticeView(viewModel: self)
                .wrappedInAnyView()
        }
    }
}

private struct dydxPredictionMarketsNoticeView: View {
    @ObservedObject var viewModel: dydxPredictionMarketsNoticeViewModel

    var title: some View {
        HStack(alignment: .center, spacing: 4) {
            Text(localizerPathKey: "APP.PREDICTION_MARKET.PREDICTION_MARKETS")
                .themeFont(fontSize: .larger)
                .themeColor(foreground: .textPrimary)
            Text(localizerPathKey: "APP.GENERAL.NEW")
                .themeFont(fontSize: .smaller)
                .padding(.horizontal, 4)
                .padding(.vertical, 2.5)
                .themeColor(foreground: .colorPurple)
                .themeColor(background: .colorFadedPurple)
                .clipShape(.rect(cornerRadius: 4))
        }
        .leftAligned()
        .wrappedInAnyView()
    }

    var checkboxRow: some View {
        HStack(spacing: 8) {
            ZStack(alignment: .center) {
                ThemeColor.SemanticColor.layer0.color
                PlatformIconViewModel(type: .asset(name: "icon_checked", bundle: .dydxView),
                                      clip: .noClip,
                                      size: .init(width: 15, height: 15),
                                      templateColor: .textPrimary)
                    .createView()
                    .opacity(viewModel.hidePredictionMarketsNotice ? 1 : 0)
            }
            .frame(width: 20, height: 20)
            .borderAndClip(style: .cornerRadius(6), borderColor: .borderDefault)
            .onTapGesture {
                viewModel.hidePredictionMarketsNotice.toggle()
            }
            Text(localizerPathKey: "APP.GENERAL.DONT_SHOW_AGAIN")
                .themeFont(fontSize: .medium)
                .themeColor(foreground: .textSecondary)
        }
        .leftAligned()
    }

    func infoRow(imageName: String, titlePathKey: String, descriptionPathKey: String) -> some View {
        HStack(alignment: .center, spacing: 8) {
            PlatformIconViewModel(type: .asset(name: imageName, bundle: .dydxView),
                                  clip: .circle(background: .layer5, spacing: 10.5, borderColor: nil),
                                  size: CGSize(width: 48, height: 48),
                                  templateColor: nil)
            .createView()
            VStack(alignment: .leading, spacing: 2) {
                Text(localizerPathKey: titlePathKey)
                    .themeFont(fontSize: .large)
                    .themeColor(foreground: .textSecondary)
                Text(localizerPathKey: descriptionPathKey)
                    .themeFont(fontSize: .medium)
                    .themeColor(foreground: .textTertiary)
            }
        }
        .leftAligned()
    }

    var continueButton: some View {
        let buttonContent =
            Text(DataLocalizer.localize(path: "APP.COMPLIANCE_MODAL.CONTINUE"))
            .wrappedViewModel
        return PlatformButtonViewModel(content: buttonContent) {
            viewModel.continueAction?()
        }
        .createView()
    }

    var body: some View {
            VStack(spacing: 16) {
                title
                VStack(spacing: 24) {
                    infoRow(imageName: "icon_settlement_cash",
                            titlePathKey: "APP.PREDICTION_MARKET.LEVERAGE_TRADE_EVENT_OUTCOMES_TITLE",
                            descriptionPathKey: "APP.PREDICTION_MARKET.LEVERAGE_TRADE_EVENT_OUTCOMES_DESCRIPTION")
                    infoRow(imageName: "icon_prediction_event",
                            titlePathKey: "APP.PREDICTION_MARKET.SETTLEMENT_OUTCOMES_TITLE",
                            descriptionPathKey: "APP.PREDICTION_MARKET.SETTLEMENT_OUTCOMES_DESCRIPTION")
                    checkboxRow
                    continueButton
                }
            }
            .makeSheet(sheetStyle: .forPresentedOverCurrentScreen)
    }
}
