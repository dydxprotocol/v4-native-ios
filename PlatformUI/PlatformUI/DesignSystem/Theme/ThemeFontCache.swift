//
//  ThemeFontCache.swift
//  PlatformUI
//
//  Created by Rui Huang on 10/4/23.
//

import Foundation
import SwiftUI

final class ThemeFontCache {
    static let shared = ThemeFontCache()
    
    private var cache = [Key: Font]()
    
    func get(fontType: ThemeFont.FontType, fontSize: ThemeFont.FontSize) -> Font? {
        let key = Key(type: fontType, size: fontSize)
        return cache[key]
    }
    
    func set(fontType: ThemeFont.FontType, fontSize: ThemeFont.FontSize, font: Font) {
        let key = Key(type: fontType, size: fontSize)
        cache[key] = font
    }
    
    func clear() {
        cache = [:]
    }
}

private struct Key: Hashable {
    let type: ThemeFont.FontType
    let size: ThemeFont.FontSize
}
