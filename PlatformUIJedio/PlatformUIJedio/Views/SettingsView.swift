//
//  SettingsView.swift
//  PlatformUIJedio
//
//  Created by Rui Huang on 3/20/23.
//  Copyright © 2023 dYdX Trading Inc. All rights reserved.
//

import SwiftUI
import PlatformUI
import Utilities

public class SettingsViewModel: PlatformViewModel {
    public struct SectionViewModel: Identifiable {
        public var id: String {
            title ?? UUID().uuidString
        }
        public var title: String?
        public var items: PlatformListViewModel?
        
        public init(title: String? = nil, items: PlatformListViewModel? = nil) {
            self.title = title
            self.items = items
        }
    }
    
    @Published public var headerViewModel: PlatformViewModel? = SettingHeaderViewModel()
    @Published public var sections: [SectionViewModel] = [] {
        didSet {
            sections.forEach { section in
                section.items?.contentChanged = { [weak self] in
                    self?.objectWillChange.send()
                }
            }
        }
    }
    @Published public var footerViewModel: PlatformViewModel?

    public init(headerViewModel: PlatformViewModel? = nil, sections: [SectionViewModel] = [], footerViewModel: PlatformViewModel? = nil) {
        self.headerViewModel = headerViewModel
        self.sections = sections
        self.footerViewModel = footerViewModel
    }
    
    public static var previewValue: SettingsViewModel {
        let vm = SettingsViewModel()
        vm.headerViewModel = SettingHeaderViewModel.previewValue
        let itemList =  PlatformListViewModel()
        itemList.items = [
            Text("Item 1").wrappedViewModel,
            Text("Item 2").wrappedViewModel,
            Text("Item 3").wrappedViewModel
        ]
        vm.sections = [SectionViewModel(title: "Title", items: itemList)]
        return vm
    }
    
    public override func createView(parentStyle: ThemeStyle = ThemeStyle.defaultStyle, styleKey: String? = nil) -> PlatformView {
        PlatformView(viewModel: self, parentStyle: parentStyle, styleKey: styleKey) { [weak self] style  in
            guard let self = self else { return AnyView(PlatformView.nilView) }
            
            let view = AnyView(
                VStack(alignment: .leading, spacing: 30) {
                    self.headerViewModel?.createView(parentStyle: style)
                    
                    ScrollView(showsIndicators: false) {
                        //note, using a LazyVStack here caused app unresponsiveness, needs investigation
                        // settings lists are fairly static/finite, so no concerned about using a VStack
                        VStack {
                            ForEach(self.sections) { section in
                                if let sectionTitle = section.title {
                                    let header = Text(sectionTitle)
                                        .leftAligned()
                              
                                    Section(header: header) {
                                        section.items?.createView(parentStyle: style)
                                    }
                                } else {
                                    Section {
                                        section.items?.createView(parentStyle: style)
                                    }
                                }
                            }
                            
                            self.footerViewModel?.createView(parentStyle: style)
                        }
                    }
                    
                    Spacer()
                }
                    .padding([.leading, .trailing])
                    .themeColor(background: .layer2)
                    .navigationViewEmbedded(backgroundColor: ThemeColor.SemanticColor.layer2.color)
            )
            
            // make it visible under the tabbar
            return AnyView(
                view.ignoresSafeArea(edges: [.bottom])
            )
        }
    }
}

#if DEBUG
struct SettingsView_Previews_Dark: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyDarkTheme()
        ThemeSettings.applyStyles()
        return SettingsViewModel.previewValue
            .createView()
            // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}

struct SettingsView_Previews_Light: PreviewProvider {
    @StateObject static var themeSettings = ThemeSettings.shared

    static var previews: some View {
        ThemeSettings.applyLightTheme()
        ThemeSettings.applyStyles()
        return SettingsViewModel.previewValue
            .createView()
        // .edgesIgnoringSafeArea(.bottom)
            .previewLayout(.sizeThatFits)
    }
}
#endif

