//
//  dydxTransferFaucetView.swift
//  dydxViews
//
//  Created by Rui Huang on 1/24/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxTransferFaucetViewModel: PlatformViewModel {
    @Published public var valueSelected: ((Int) -> Void)?
    private var value: String? = "2000"

    public init() { }

    public static var previewValue: dydxTransferFaucetViewModel {
        let vm = dydxTransferFaucetViewModel()
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                ScrollView(showsIndicators: false) {
                    LazyVStack(pinnedViews: [.sectionHeaders]) {
                        PlatformIconViewModel(type: .system(name: "spigot"),
                                              size: CGSize(width: 128, height: 128))
                        .createView(parentStyle: style)

                        Text("Loading from test-net faucet (max: $2000)")
                            .themeFont(fontSize: .medium)
                            .leftAligned()
                            .padding(.top, 32)

                        HStack {
                            PlatformTextInputViewModel(label: nil, value: self.value, inputType: .decimalDigits, onEdited: { [weak self] (v: String?) in
                                self?.value = v
                            })
                            .createView(parentStyle: style)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 10)
                            .themeColor(background: .layer1)
                            .clipShape(Capsule())
                            .frame(minWidth: 0, maxWidth: .infinity)

                            PlatformButtonViewModel(content: Text("Submit").wrappedViewModel, state: .secondary) { [weak self] in
                                if let value = self?.value, let v = Int(value) {
                                    self?.valueSelected?(v)
                                }
                            }
                            .createView(parentStyle: style)
                            .frame(maxWidth: 120)
                        }

                        DividerModel().createView(parentStyle: style).padding(.vertical, 16)

                        PlatformButtonViewModel(content: Text("$100").wrappedViewModel, state: .secondary) {
                            self.valueSelected?(100)
                        }
                        .createView(parentStyle: style)

                        PlatformButtonViewModel(content: Text("$1000").wrappedViewModel, state: .secondary) {
                            self.valueSelected?(1000)
                        }
                        .createView(parentStyle: style)

                        PlatformButtonViewModel(content: Text("Roll a dice").wrappedViewModel, state: .secondary) {
                            self.valueSelected?(Int.random(in: 1...2000))
                        }
                        .createView(parentStyle: style)

                        Spacer()
                    }
                }
                .animation(.default)
            )

        }
    }
}

#if DEBUG
struct dydxTransferFaucetView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTransferFaucetViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTransferFaucetView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTransferFaucetViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
