////
////  dydxTriggerInputViewModel.swift
////  dydxUI
////
////  Created by Michael Maguire on 4/2/24.
////  Copyright © 2024 dYdX Trading Inc. All rights reserved.
////
//
// import SwiftUI
//
// public class dydxTriggerInputViewModelModel: PlatformViewModel {
//    @Published public var text: String?
//
//    public static var previewValue: dydxTriggerInputViewModelModel = {
//        let vm = dydxTriggerInputViewModelModel()
//        vm.text = "Test String"
//        return vm
//    }()
//    
//    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
//        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
//            guard let self = self else { return AnyView(PlatformView.nilView) }
//
//            return AnyView(
//                Text(self.text ?? "")
//            )
//        }
//    }
// }
//
// #if DEBUG
// struct dydxTriggerInputViewModel_Previews: PreviewProvider {
//    @StateObject static var themeSettings = ThemeSettings.shared
//
//    static var previews: some View {
//        Group {
//            dydxTriggerInputViewModelModel.previewValue
//                .createView()
//                .environmentObject(themeSettings)
//                .previewLayout(.sizeThatFits)
//        }
//    }
// }
// #endif
//
