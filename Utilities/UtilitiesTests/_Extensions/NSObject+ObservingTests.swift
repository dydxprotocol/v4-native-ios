//
//  NSObject+ObservingTests.swift
//  UtilitiesTests
//
//  Created by Rui Huang on 5/9/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import XCTest
import Utilities

class NSObject_ObservingTests: XCTestCase {

    fileprivate var publisher: PublisherMock!
    fileprivate var observer: ObserverMock!

    override func setUp() {
        super.setUp()
        publisher = PublisherMock()
        observer = ObserverMock()
    }

    func disabled_testObservingPerformance() throws {
        measure {
            var receivedInitialVals = [Int?]()
            var receivedChangeVals = [Int?]()

            observer.initialBlock = {  _, val, _, _ in
                receivedInitialVals.append(val as? Int)
            }

            observer.changeBlock = {  _, val, _, _ in
                receivedChangeVals.append(val as? Int)
            }

            // Setter called -> Should execute initial block with the current publisher value
            observer.publisher = publisher
            for i in 0..<1_000_000 {
                publisher.count = i
            }
        }
    }
}

private class PublisherMock: NSObject {
     @objc dynamic var count: Int = 0

    override init() {}
}

private class ObserverMock: NSObject {

    var initialBlock: KVONotificationBlock?
    var changeBlock: KVONotificationBlock?

    var publisher: PublisherMock? {
        didSet {
            changeObservation(from: oldValue, to: publisher, keyPath: #keyPath(PublisherMock.count), initial: initialBlock, change: changeBlock)
        }
    }

    override init() {}
}
