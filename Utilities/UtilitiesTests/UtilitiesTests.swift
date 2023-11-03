//
//  UtilitiesTests.swift
//  UtilitiesTests
//
//  Created by Qiang Huang on 10/8/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import XCTest
@testable import Utilities

class UtilitiesTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStrings() {
        let string = "this/is/a/test.json"
        XCTAssert(string.lastPathComponent == "test.json", "lastPathComponent error")
        XCTAssert(string.pathExtension == "json", "pathExtension error")
        XCTAssert(string.stringByDeletingLastPathComponent == "this/is/a", "stringByDeletingLastPathComponent error")
        XCTAssert(string.stringByDeletingPathExtension == "this/is/a/test", "stringByDeletingPathExtension error")
        XCTAssert(string.pathComponents == ["this", "is", "a", "test.json"], "pathComponents error")
        XCTAssert(string.stringByAppendingPathComponent(path: "another") == "this/is/a/test.json/another", "stringByAppendingPathComponent error")
        XCTAssert(string.stringByAppendingPathExtension(ext: "pdf") == "this/is/a/test.json.pdf", "stringByAppendingPathExtension error")
        
        XCTAssert(string.begins(with: "this"), "begins error")
        XCTAssert(!string.begins(with: "thisx"), "begins error")
        
        XCTAssert(string.ends(with: "test.json"), "ends error")
        XCTAssert(!string.ends(with: "test_json"), "ends error")
    }
    
    func testStringNumberConversion() {
        let decimal = "\(Locale.current.decimalSeparator ?? ".")"
        XCTAssertEqual("-", "-".truncateToWholeNumber())
        XCTAssertEqual(nil, "--".truncateToWholeNumber())
        XCTAssertEqual(nil, "\(decimal)".truncateToWholeNumber())
        XCTAssertEqual("1", "1".truncateToWholeNumber())
        XCTAssertEqual("0", "0".truncateToWholeNumber())
        XCTAssertEqual("-0", "-0".truncateToWholeNumber())
        XCTAssertEqual("-1", "-1".truncateToWholeNumber())
        XCTAssertEqual("1", "1\(decimal)".truncateToWholeNumber())
        XCTAssertEqual("0", "0\(decimal)".truncateToWholeNumber())
        XCTAssertEqual("-1", "-1\(decimal)".truncateToWholeNumber())
        XCTAssertEqual("1", "1\(decimal)0".truncateToWholeNumber())
        XCTAssertEqual("0", "0\(decimal)0".truncateToWholeNumber())
        XCTAssertEqual("-1", "-1\(decimal)0".truncateToWholeNumber())
        XCTAssertEqual(nil, "--1\(decimal)0".truncateToWholeNumber())
        XCTAssertEqual("-1", "-01\(decimal)0".truncateToWholeNumber())
        XCTAssertEqual("63256", "63256".truncateToWholeNumber())
        XCTAssertEqual("63256", "63256\(decimal)".truncateToWholeNumber())
        XCTAssertEqual("63256", "63256\(decimal)0".truncateToWholeNumber())
        XCTAssertEqual("63256", "63256\(decimal)0123456789".truncateToWholeNumber())
        XCTAssertEqual("63256", "63256\(decimal)".truncateToWholeNumber())
        XCTAssertEqual("12345678912345678901234567891234567890", "0012345678912345678901234567891234567890\(decimal)12345678912345678901234567891234567890".truncateToWholeNumber())

        XCTAssertEqual("-", "-".cleanAsDecimalNumber())
        XCTAssertEqual(nil, "--".cleanAsDecimalNumber())
        XCTAssertEqual("0\(decimal)", "\(decimal)".cleanAsDecimalNumber())
        XCTAssertEqual("1", "1".cleanAsDecimalNumber())
        XCTAssertEqual("0", "0".cleanAsDecimalNumber())
        XCTAssertEqual("-0", "-0".cleanAsDecimalNumber())
        XCTAssertEqual("-1", "-1".cleanAsDecimalNumber())
        XCTAssertEqual("1\(decimal)", "1\(decimal)".cleanAsDecimalNumber())
        XCTAssertEqual("0\(decimal)", "0\(decimal)".cleanAsDecimalNumber())
        XCTAssertEqual("-1\(decimal)", "-1\(decimal)".cleanAsDecimalNumber())
        XCTAssertEqual("1\(decimal)0", "1\(decimal)0".cleanAsDecimalNumber())
        XCTAssertEqual("0\(decimal)0", "0\(decimal)0".cleanAsDecimalNumber())
        XCTAssertEqual("-1\(decimal)0", "-1\(decimal)0".cleanAsDecimalNumber())
        XCTAssertEqual(nil, "--1\(decimal)0".cleanAsDecimalNumber())
        XCTAssertEqual("-1\(decimal)0", "-01\(decimal)0".cleanAsDecimalNumber())
        XCTAssertEqual("63256", "63256".cleanAsDecimalNumber())
        XCTAssertEqual("63256\(decimal)", "63256\(decimal)".cleanAsDecimalNumber())
        XCTAssertEqual("63256\(decimal)0", "63256\(decimal)0".cleanAsDecimalNumber())
        XCTAssertEqual("63256\(decimal)0123456789", "63256\(decimal)0123456789".cleanAsDecimalNumber())
        XCTAssertEqual("63256\(decimal)", "63256\(decimal)".cleanAsDecimalNumber())
        XCTAssertEqual("12345678912345678901234567891234567890\(decimal)12345678912345678901234567891234567890", "0012345678912345678901234567891234567890\(decimal)12345678912345678901234567891234567890".cleanAsDecimalNumber())

        XCTAssertEqual(nil, "-a-3skl2dj1   ']\(decimal)  EKD 1 JK 2 J 3KLS(@&#".cleanAsDecimalNumber())
    }
    
    func testJavascriptRunner() {
        let javascriptRunner = JavascriptRunner(file: nil)
        let script = """
           var testFunct = function(message) { return \"Test Message: \" + message;}
        """
        javascriptRunner.run(script: script) { result in
            DispatchQueue.main.async {
                javascriptRunner.invoke(className:nil, function: "testFunct", params: ["my message"]) {result in
                    XCTAssert((result as? String) == "Test Message: my message")
                }
            }
        }
    }

}
