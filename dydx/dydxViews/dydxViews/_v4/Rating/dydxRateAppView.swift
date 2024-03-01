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
    @Published public var rateAction: (() -> Void)?
    @Published public var deferAction: (() -> Void)?

    public static var previewValue: dydxRateAppViewModel = {
        let vm = dydxRateAppViewModel()
        return vm
    }()

    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] _  in
            guard let self = self else { return AnyView(PlatformView.nilView) }

            return ZStack {
                // Your content here
                Color.clear // Use clear color for the background to show the blur effect
                    .background(BlurView(style: .systemMaterialDark)) // Custom Blur View
                    .edgesIgnoringSafeArea(.all) // Extend to the edges of the display

                VStack {
                    Text("Hello, World!")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                }
            }
            .wrappedInAnyView()

//            ZStack(alignment: .center) {
//                VStack {
//                    Spacer()
//                    Text("wanna rate it?")
//                    HStack {
//                        Button("later") { [weak self] in
//                            self?.deferAction?()
//                        }
//                        Button("sure") { [weak self] in
//                            self?.rateAction?()
//                        }
//                    }
//                    Spacer()
//                }
//            }
//            .frame(width: 400, height: 400)
////            .ignoresSafeArea(.all)
//            .themeColor(background: .colorRed)
//            .wrappedInAnyView()
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
