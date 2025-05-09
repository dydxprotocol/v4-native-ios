//
//  dydxAppModeSurveyView.swift
//  dydxUI
//
//  Created by Rui Huang on 10/04/2025.
//  Copyright © 2025 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxAppModeSurveyViewModel: PlatformViewModel {
    public struct OptionItem: Hashable {
        public init(text: String, isSelected: Bool, selectionAction: @escaping () -> Void) {
            self.text = text
            self.isSelected = isSelected
            self.selectionAction = selectionAction
        }

        let text: String
        let isSelected: Bool
        let selectionAction: () -> Void

        public static func == (lhs: OptionItem, rhs: OptionItem) -> Bool {
            lhs.text == rhs.text &&
            lhs.isSelected == rhs.isSelected
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(text)
            hasher.combine(isSelected)
        }
    }

    @Published public var canSubmit: Bool = false
    @Published public var submitAction: (() -> Void)?
    @Published public var doNotShowAction: (() -> Void)?
    @Published public var options: [OptionItem] = []
    @Published public var feedbackText: String?
    @Published public var feedbackInput: PlatformTextInputViewModel?
    @Published public var feedbackAction: (() -> Void)?

    public init() {
        super.init()

        feedbackInput = PlatformTextInputViewModel(label: nil,
                                                   value: self.feedbackText,
                                                   placeHolder: "(" + DataLocalizer.localize(path: "APP.GENERAL.OPTIONAL") + ")",
                                                   inputType: .default,
                                                   onEdited: { [weak self] (v: String?) in
            self?.feedbackText = v
            self?.feedbackInput?.value = v
            self?.feedbackAction?()
        })
    }

    public static var previewValue: dydxAppModeSurveyViewModel {
        let vm = dydxAppModeSurveyViewModel()
        vm.options = [
            .init(text: DataLocalizer.localize(path: "SURVEY.SIMPLE_TO_PRO.OPTION_1"), isSelected: false, selectionAction: { }),
            .init(text: DataLocalizer.localize(path: "SURVEY.SIMPLE_TO_PRO.OPTION_2"), isSelected: true, selectionAction: { })
        ]
        return vm
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            let view = VStack(alignment: .leading, spacing: 24) {
                Image("survey_logo", bundle: Bundle.dydxView)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 92, height: 92)
                    .padding(.horizontal)

                Text(DataLocalizer.localize(path: "SURVEY.SIMPLE_TO_PRO.TITLE"))
                    .themeFont(fontSize: .large)
                    .themeColor(foreground: .textPrimary)

                VStack(alignment: .leading, spacing: 16) {
                    ForEach(self.options, id: \.self) { item in
                        HStack {
                            if item.isSelected {
                                PlatformIconViewModel.selectedCheckmark.createView(parentStyle: style)
                            } else {
                                self.uncheckedIcon
                            }
                            Text(item.text)
                                .themeFont(fontSize: .medium)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .themeColor(background: item.isSelected ? .layer0 : .layer3)
                        .borderAndClip(style: .capsule,
                                       borderColor: item.isSelected ? .colorPurple : .borderDefault,
                                       lineWidth: 1)
                        .onTapGesture {
                            item.selectionAction()
                            PlatformView.hideKeyboard()
                        }
                    }
                }

                Spacer()
                    .frame(height: 0)

                Text(DataLocalizer.localize(path: "SURVEY.SIMPLE_TO_PRO.ADDITIONAL_FEEDBACK"))
                    .themeFont(fontSize: .large)
                    .themeColor(foreground: .textPrimary)

                self.feedbackInput?
                    .createView(parentStyle: style)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 4)
                    .themeColor(background: .layer0)
                    .clipShape(.rect(cornerRadius: 8))
                    .frame(minWidth: 0, maxWidth: .infinity)

                Spacer()

                let buttonType = PlatformButtonType.defaultType(
                    fillWidth: true,
                    pilledCorner: false,
                    minHeight: 60,
                    cornerRadius: 16)
                let buttonText = DataLocalizer.localize(path: "SURVEY.SUBMIT")
                let buttonContent = Text(buttonText)
                    .themeFont(fontType: .plus, fontSize: .large)
                    .themeColor(foreground: self.canSubmit ? .colorWhite : .textTertiary)
                    .wrappedViewModel
                PlatformButtonViewModel(content: buttonContent,
                                        type: buttonType,
                                        state: self.canSubmit ? .primary : .disabled) { [weak self] in
                    PlatformView.hideKeyboard()
                    self?.submitAction?()
                }
                                        .createView(parentStyle: style)

                Button { [weak self] in
                    self?.doNotShowAction?()
                } label: {
                    HStack {
                        Spacer()
                        Text(DataLocalizer.localize(path: "SURVEY.DO_NOT_SHOW"))
                            .themeFont(fontSize: .large)
                            .themeColor(foreground: .textTertiary)

                        Spacer()
                    }
                }
            }
            .keyboardObserving()
            .padding([.leading, .trailing])
            .padding(.top, 32)
            .padding(.bottom, max((self.safeAreaInsets?.bottom ?? 0), 16))
            .themeColor(background: .layer2)

            // make it visible under the tabbar
            return AnyView(view.ignoresSafeArea(edges: [.bottom]))
        }
    }

    private var uncheckedIcon: some View {
        Circle()
            .stroke(ThemeColor.SemanticColor.colorPurple.color, lineWidth: 1)
            .frame(width: 20, height: 20)
    }

    private var checkedIcon: some View {
        PlatformIconViewModel(type: .asset(name: "icon_checked", bundle: Bundle.dydxView),
                              clip: .circle(background: .colorPurple,
                                            spacing: 12,
                                            borderColor: nil),
                              size: CGSize(width: 20, height: 20),
                              templateColor: .textPrimary)
        .createView()
    }
}

#if DEBUG
struct dydxAppModeSurveyView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxAppModeSurveyViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxAppModeSurveyView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxAppModeSurveyViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
