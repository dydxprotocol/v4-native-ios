//
//  CombineObservingTests.swift
//  UtilitiesTests
//
//  Created by Rui Huang on 5/8/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import XCTest
import Utilities
import Combine

class CombineObservingTests: XCTestCase {

    fileprivate var publisher: PublisherMock!
    fileprivate var observer: ObserverMock!

    override func setUp() {
        super.setUp()
        publisher = PublisherMock()
        observer = ObserverMock()
    }

    func testCombineObserving() throws {
        var receivedInitialVals = [Int?]()
        var receivedChangeVals = [Int?]()

        observer.initialBlock = { val, emitState in
            receivedInitialVals.append(val)
            XCTAssertEqual(val, self.publisher?.count)
            XCTAssertEqual(emitState, .initial)
        }

        observer.changeBlock = { val, emitState in
            receivedChangeVals.append(val)
            XCTAssertEqual(val, self.publisher?.count)
            XCTAssertEqual(emitState, .change)
        }

        // Setter called -> Should execute initial block with the current publisher value
        observer.publisher = publisher
        waitForDispatchMain()

        XCTAssertEqual(receivedInitialVals, [0])
        XCTAssertEqual(receivedChangeVals, [])

        // Publisher emits a new value -> should execute change block
        publisher.count = 12
        waitForDispatchMain()

        XCTAssertEqual(receivedInitialVals, [0])
        XCTAssertEqual(receivedChangeVals, [12])

        publisher.count = 12
        waitForDispatchMain()

        XCTAssertEqual(receivedInitialVals, [0])
        XCTAssertEqual(receivedChangeVals, [12, 12])

        // Set the same publisher -> No change
        observer.publisher = publisher
        waitForDispatchMain()

        XCTAssertEqual(receivedInitialVals, [0])
        XCTAssertEqual(receivedChangeVals, [12, 12])

        // Set to a new publisher -> initital gets called again
        publisher = PublisherMock()
        publisher.count = 1
        waitForDispatchMain()

        observer.publisher = publisher
        waitForDispatchMain()

        publisher.count = 13
        waitForDispatchMain()

        XCTAssertEqual(receivedInitialVals, [0, 1])
        XCTAssertEqual(receivedChangeVals, [12, 12, 13])
    }

    func testCombineObserving_deDup() throws {
        var receivedInitialVals = [Int?]()
        var receivedChangeVals = [Int?]()

        observer.initialBlock = { val, emitState in
            receivedInitialVals.append(val)
            XCTAssertEqual(val, self.publisher?.count)
            XCTAssertEqual(emitState, .initial)
        }

        observer.changeBlock = { val, emitState in
            receivedChangeVals.append(val)
            XCTAssertEqual(val, self.publisher?.count)
            XCTAssertEqual(emitState, .change)
        }

        // Setter called -> Should execute initial block with the current publisher value
        observer.deDupPublisher = publisher
        waitForDispatchMain()

        XCTAssertEqual(receivedInitialVals, [0])
        XCTAssertEqual(receivedChangeVals, [])

        // Publisher emits a new value -> should execute change block
        publisher.count = 12
        waitForDispatchMain()

        publisher.count = 12
        waitForDispatchMain()

        XCTAssertEqual(receivedInitialVals, [0])
        XCTAssertEqual(receivedChangeVals, [12])

    }

    func disabled_testCombineObservingPerformance() throws {
        measure {
            var receivedInitialVals = [Int?]()
            var receivedChangeVals = [Int?]()

            observer.initialBlock = { val, _ in
                receivedInitialVals.append(val)
            }

            observer.changeBlock = { val, _ in
                receivedChangeVals.append(val)
            }

            // Setter called -> Should execute initial block with the current publisher value
            observer.publisher = publisher
            for i in 0..<1_000_000 {
                publisher.count = i
            }
        }
    }
}

extension XCTestCase {
    func waitForDispatchMain() {
        RunLoop.current.run(until: Date())
    }
}

private class PublisherMock {
    @Published var count: Int = 0
}

private class ObserverMock: CombineObserving {
    var cancellableMap = [AnyKeyPath: AnyCancellable]()

    var initialBlock: ((_ obj: Int?, _ emitState: EmitState) -> Void) = { _, _ in }
    var changeBlock: ((_ obj: Int?, _  emitState: EmitState) -> Void) = { _, _ in }

    var publisher: PublisherMock? {
        didSet {
            observeTo(publisher: publisher?.$count,
                      keyPath: \PublisherMock.count,
                      resetCondition: { oldValue !== publisher },
                      initial: initialBlock,
                      change: changeBlock)
        }
    }

    var deDupPublisher: PublisherMock? {
        didSet {
            observeTo(publisher: deDupPublisher?.$count,
                      keyPath: \PublisherMock.count,
                      resetCondition: { oldValue !== deDupPublisher },
                      dedupCondition: ==,
                      initial: initialBlock,
                      change: changeBlock)
        }
    }

    init() {}
}
