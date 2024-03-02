//
//  dydxRateAppView.swift
//  dydxUI
//
//  Created by Michael Maguire on 2/28/24.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI

// Define a UIViewRepresentable to use UIVisualEffectView in SwiftUI
struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

public class dydxRateAppViewModel: PlatformViewModel {
    @Published public var positiveRatingIntentAction: (() -> Void)?
    @Published public var negativeRatingIntentAction: (() -> Void)?
    @Published public var deferAction: (() -> Void)?

    public static var previewValue: dydxRateAppViewModel = {
        let vm = dydxRateAppViewModel()
        return vm
    }()

    private func createButtonContent(title: String) -> AnyView {
        HStack {
            Spacer()
            Text(title)
                .themeFont(fontSize: .medium)
                .themeColor(foreground: .textPrimary)
            Spacer()
        }.wrappedInAnyView()
    }

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return ZStack {
                Color.clear // Use clear color for the background to show the blur effect
                    .background(BlurView(style: .systemMaterialDark))
                    .edgesIgnoringSafeArea(.all)
                    .opacity(0.8)

                ZStack(alignment: .center) {
                    VStack(spacing: 32) {
                        Text("Placholder\nare you enjoying this app?")
                            .themeFont(fontSize: .large)
                            .themeColor(foreground: .textPrimary)
                        HStack {
                            PlatformButtonViewModel(content: self.createButtonContent(title: "no").wrappedViewModel) { [weak self] in
                                self?.negativeRatingIntentAction?()
                            }.createView(parentStyle: parentStyle, styleKey: styleKey)
                            PlatformButtonViewModel(content: self.createButtonContent(title: "yes").wrappedViewModel) { [weak self] in
                                self?.positiveRatingIntentAction?()
                            }.createView(parentStyle: parentStyle, styleKey: styleKey)
                        }
                        Text("later")
                            .themeColor(foreground: .textSecondary)
                            .themeFont(fontSize: .medium)
                            .onTapGesture {[weak self] in
                                self?.deferAction?()
                            }
                    }
                    .padding(.all, 16)
                }
                .themeColor(background: .layer1)
                .borderAndClip(style: .cornerRadius(8), borderColor: .borderDefault, lineWidth: 1)
                .padding(.horizontal, 32)
            }

            .wrappedInAnyView()
        }
    }
}

#if DEBUG
struct dydxRateAppView_Previews: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        Group {
            dydxRateAppViewModel.previewValue
                .createView()
                .environmentObject(themeSettings)
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif
