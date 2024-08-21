//
//  ThemeColorCache.swift
//  PlatformUI
//
//  Created by Rui Huang on 10/4/23.
//

import Foundation
import SwiftUI

final class ThemeColorCache {
    static let shared = ThemeColorCache()
    
    private var cache = [ThemeColor.SemanticColor: Color]()
    
    func get(_ key: ThemeColor.SemanticColor) -> Color? {
        return cache[key]
    }
    
    func set(_ key: ThemeColor.SemanticColor, color: Color) {
        cache[key] = color
    }
    
    func clear() {
        cache = [:]
    }
}

