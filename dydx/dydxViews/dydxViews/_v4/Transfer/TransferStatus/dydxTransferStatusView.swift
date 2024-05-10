//
//  dydxTransferStatusView.swift
//  dydxUI
//
//  Created by Rui Huang on 4/18/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxTransferStatusViewModel: PlatformViewModel {
    @Published public var completed: Bool = false
    @Published public var title: String?
    @Published public var text: String?
    @Published public var steps = [PlatformViewModel]()
    @Published public var receipt: dydxReceiptViewModel? = dydxReceiptViewModel()
    @Published public var deleteAction: (() -> Void)?

    public init() { }

    public static var previewValue: dydxTransferStatusViewModel {
        let vm = dydxTransferStatusViewModel()
        vm.title = "Deposit initiated"
        vm.text = "Test"
        vm.steps = [
            ProgressStepViewModel.previewValue,
            ProgressStepViewModel.previewValue,
            ProgressStepViewModel.previewValue
        ]
        vm.receipt = .previewValue
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return AnyView(
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        let imageName = self.completed ? "icon_checked" : "icon_clock"
                        PlatformIconViewModel(type: .asset(name: imageName, bundle: Bundle.dydxView),
                                              size: CGSize(width: 24, height: 24))
                            .createView(parentStyle: style)
                        Text(self.title ?? "")
                            .themeFont(fontSize: .larger)
                            .animation(.default)
                    }
                    Text(self.text ?? "")
                        .themeFont(fontSize: .medium)
                        .animation(.default)

                    self.createSteps(style: parentStyle)

                    Spacer()

                    if self.receipt != nil {
                        VStack(spacing: -8) {
                            VStack {
                                self.receipt?.createView(parentStyle: style)

                                Spacer()
                            }
                            .padding()
                            .padding(.bottom, 12)
                            .frame(height: 180)
                            .frame(maxWidth: .infinity)
                            .themeColor(background: .layer1)
                            .cornerRadius(12, corners: [.topLeft, .topRight])

                            if self.deleteAction != nil {
                                self.createButtons(style: parentStyle)
                            }
                        }
                    } else {
                        if self.deleteAction != nil {
                            self.createButtons(style: parentStyle)
                        }
                    }
                }
                    .padding([.leading, .trailing])
                    .padding(.top, 40)
                    .padding(.bottom, max((self.safeAreaInsets?.bottom ?? 0), 16))
                    .themeColor(background: .layer3)
                    .makeSheet()
                    .ignoresSafeArea(edges: [.bottom])
            )
        }
    }

    @ViewBuilder
    private func createSteps(style: ThemeStyle) -> some View {
        ScrollView(showsIndicators: false) {
            VStack {
                ForEach(steps, id: \.id) { step in
                    step.createView(parentStyle: style)
                }
            }
        }.wrappedViewModel.createView(parentStyle: style)
    }

    @ViewBuilder
    private func createButtons(style: ThemeStyle) -> some View {
        HStack {
            let buttonContent = Text(DataLocalizer.localize(path: "APP.V4.DELETE_ALERT"))
                .wrappedViewModel

            PlatformButtonViewModel(content: buttonContent, state: .destructive) { [weak self] in
                self?.deleteAction?()
            }
            .createView(parentStyle: style)
            .frame(maxWidth: .infinity)
        }
    }
}

#if DEBUG
struct dydxTransferStatusView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxTransferStatusViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxTransferStatusView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxTransferStatusViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
