//
//  dydxTradeInputGoodTilView.swift
//  dydxViews
//
//  Created by John Huang on 1/4/23.
//

import PlatformUI
import SwiftUI
import Utilities

public class dydxTradeInputGoodTilViewModel: PlatformValueInputViewModel {
    @Published public var duration: dydxTradeInputGoodTilDurationViewModel?
    @Published public var unit: dydxTradeInputGoodTilUnitViewModel?

    public init(duration: dydxTradeInputGoodTilDurationViewModel? = nil, unit: dydxTradeInputGoodTilUnitViewModel? = nil) {
        self.duration = duration
        self.unit = unit
    }

    public static var previewValue: dydxTradeInputGoodTilViewModel {
        let vm = dydxTradeInputGoodTilViewModel()
        vm.duration = .previewValue
        vm.unit = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        return PlatformView { [weak self] style in
            AnyView(
                HStack {
                    self?.duration?.createView(parentStyle: style)
                    Spacer()
                    self?.unit?.createView(parentStyle: style)
                }
                .makeInput()
            )
        }
    }
}

public class dydxTradeInputGoodTilDurationViewModel: PlatformTextInputViewModel {
    public init(label: String? = nil, value: String? = nil, placeHolder: String? = nil, contentType: UITextContentType? = nil, onEdited: ((String?) -> Void)? = nil) {
        super.init(label: label, value: value, placeHolder: placeHolder, inputType: .wholeNumber, contentType: contentType, onEdited: onEdited)
    }

    public static var previewValue: dydxTradeInputGoodTilDurationViewModel = {
        let vm = dydxTradeInputGoodTilDurationViewModel(label: "Good Til", value: "100.0", placeHolder: "28")
        return vm
    }()
}

public class dydxTradeInputGoodTilUnitViewModel: PlatformPopoverOptionsInputViewModel {
    public static var previewValue: dydxTradeInputGoodTilUnitViewModel = {
        var options = [InputSelectOption]()
        options.append(InputSelectOption(value: "M", string: "APP.GENERAL.TIME.MINUTES"))
        options.append(InputSelectOption(value: "H", string: "APP.GENERAL.TIME.HOUR"))
        options.append(InputSelectOption(value: "D", string: "APP.GENERAL.TIME.DAY"))
        options.append(InputSelectOption(value: "W", string: "APP.GENERAL.TIME.WEEK"))
        let vm = dydxTradeInputGoodTilUnitViewModel(label: nil, value: nil, options: options, onEdited: nil)
        return vm
    }()

    public override var selectedItemView: PlatformViewModel {
        let index = index ?? 0
        if let titles = optionTitles, index < titles.count {
            let selectedText = titles[index]
            return
                Text(selectedText)
                    .themeFont(fontSize: .small)
                    .wrappedViewModel
        }
        return PlatformView.nilViewModel
    }
}

#if DEBUG
struct dydxTradeInputGoodTilView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTradeInputGoodTilViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTradeInputGoodTilView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTradeInputGoodTilViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
