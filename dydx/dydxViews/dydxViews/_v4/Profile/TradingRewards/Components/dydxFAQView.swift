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

    public var id: String { question + answer }
    private let question: String
    private let answer: String
    @Published var isExpanded: Bool = false

    public init(question: String, answer: String) {
        self.question = question
        self.answer = answer
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
                    Text(self.question)
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

                Text(self.answer)
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
        let vm = dydxFAQViewModel(question: "question", answer: "answer answer answer answer answer answer answer answer answer answer answer answer answer answer answer answer")
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