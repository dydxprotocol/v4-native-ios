//
//  dydxFAQView.swift
//  dydxViews
//
//  Created by Michael Maguire on 12/5/23.
//

import SwiftUI
import PlatformUI
import Utilities

public class dydxFAQViewModel: PlatformViewModel {

    public var id: String { questionLocalizationKey + answerLocalizationKey }
    private let questionLocalizationKey: String
    private let answerLocalizationKey: String
    @Published var isExpanded: Bool = false

    public init(questionLocalizationKey: String, answerLocalizationKey: String) {
        self.questionLocalizationKey = questionLocalizationKey
        self.answerLocalizationKey = answerLocalizationKey
        super.init()
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _ in
            guard let self = self else { return AnyView(PlatformView.nilView) }
            let hideShowImageDiameter: CGFloat = 20
            let hideShowViewDiameter: CGFloat = 28
            let paddingDim: CGFloat = (hideShowViewDiameter - hideShowImageDiameter) / 2
            return VStack(spacing: 0) {
                HStack {
                    Text(DataLocalizer.shared?.localize(path: self.questionLocalizationKey, params: nil) ?? "")
                        .themeFont(fontType: .text, fontSize: .small)
                        .themeColor(foreground: .textSecondary)
                    Spacer(minLength: 16)
                    // PlatformIconViewModel behaves weirdly here. When isExpanded is toggled, sometimes the icon hides entirely. Do not use.
                    Image(self.isExpanded ? "icon_collapse" : "icon_expand", bundle: .dydxView)
                        .frame(width: hideShowImageDiameter, height: hideShowImageDiameter)
                        .padding(.all, paddingDim)
                        .themeColor(background: .layer5)
                        .borderAndClip(style: .cornerRadius(hideShowViewDiameter/2), borderColor: .layer6, lineWidth: 1)
                    .onTapGesture { [weak self] in
                        withAnimation {
                            self?.isExpanded.toggle()
                        }
                    }
                }

                Text(DataLocalizer.shared?.localize(path: self.answerLocalizationKey, params: nil) ?? "")
                    .themeFont(fontType: .text, fontSize: .small)
                    .themeColor(foreground: .textTertiary)
                    .leftAligned()
                // this is for the animation to have a "slide-over" effect when hiding/showing the answer
                    .padding(.top, 16)
                    .frame(height: self.isExpanded ? nil : 0)
                    .clipped()
            }
            .padding(.top, 8)
            .padding(.bottom, self.isExpanded ? 18 : 12)
            .padding(.horizontal, 24)
            .wrappedInAnyView()
        }
    }

    public static var previewValue: dydxFAQViewModel {
        let vm = dydxFAQViewModel(questionLocalizationKey: "question", answerLocalizationKey: "answer")
        return vm
    }

}

#if DEBUG
struct dydxFAQViewModel_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return dydxFAQViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct dydxFAQViewModel_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return dydxFAQViewModel.previewValue
            .createView()
            .themeColor(background: .layer0)
            .environmentObject(themeSettings)
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif
