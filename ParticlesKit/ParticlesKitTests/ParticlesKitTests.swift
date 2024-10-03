//
//  ParticlesKitTests.swift
//  ParticlesKitTests
//
//  Created by Qiang Huang on 11/29/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import XCTest
@testable import ParticlesKit

class ParticlesKitTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testKeychain() {
        // keychain access requires entitlement
        /*
        let path1 = "path1"
        let key1 = "key1"
        let value1 = "value1"
        let obj1 = [key1: value1]
        let keychain = JsonKeychainCaching()
        keychain.write(path: path1, data: obj1, completion: nil)
        keychain.read(path: path1) { (obj, error) in
            if let dictionary = obj as? [String: String] {
                XCTAssert(dictionary[key1] == value1)
            } else {
                XCTAssert(false)
            }
        }
        */
    }

    func testExample() {

    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
