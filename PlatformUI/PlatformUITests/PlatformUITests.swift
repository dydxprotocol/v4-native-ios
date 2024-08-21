//
//  PlatformUITests.swift
//  PlatformUITests
//
//  Created by Rui Huang on 8/8/22.
//

import XCTest
@testable import PlatformUI

class PlatformUITests: XCTestCase {
    
    func testFont() throws {
        let themeConfig = ThemeConfig.sampleThemeConfig
        let font = themeConfig.themeFont.font(of: .text, fontSize: .largest)
        XCTAssert(font != nil)
    }
}
