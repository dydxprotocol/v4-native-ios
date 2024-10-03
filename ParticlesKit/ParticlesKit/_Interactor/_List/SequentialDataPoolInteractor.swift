//
//  SequentialDataPoolInteractor.swift
//  ParticlesKit
//
//  Created by Qiang Huang on 11/5/21.
//  Copyright © 2021 dYdX Trading Inc. All rights reserved.
//

import Utilities

@objc open class SequentialDataPoolInteractor: DataPoolInteractor {
    public class Cursor: NSObject {
        private var objects: [ModelObjectProtocol]

        public init(objects: [ModelObjectProtocol]) {
            self.objects = objects
            if objects.count > 0 {
                index = 0
                current = objects[0]
            }
            super.init()
        }

        public var index: Int? {
            didSet {
                if index != oldValue {
                    if let index = index {
                        current = objects[index]
                    } else {
                        current = nil
                    }
                }
            }
        }

        public var current: ModelObjectProtocol?

        public func advance() {
            if let index = index, index + 1 < objects.count {
                self.index = index + 1
            } else {
                index = nil
            }
        }

        public func rest() -> [ModelObjectProtocol]? {
            if let index = index {
                return Array(objects[index...])
            } else {
                return nil
            }
        }
    }

    override public var sequential: Bool {
        return true
    }

    public var inputReversed: Bool = false

    public init(inputReversed: Bool = false) {
        self.inputReversed = inputReversed
        super.init()
    }

    public init(key: String? = nil, default defaultJson: String? = nil, inputReversed: Bool = false) {
        self.inputReversed = inputReversed
        super.init(key: key, default: defaultJson)
    }

    override open func sequence(sequence: [ModelObjectProtocol]?) -> [ModelObjectProtocol]? {
        if let sequence = sequence {
            if let existing = self.sequence {
                return merge(existing, sequence)
            } else {
                return sequence
            }
        } else {
            return self.sequence
        }
    }

    override public func ordered(sequence: [ModelObjectProtocol]?) -> [ModelObjectProtocol]? {
        if let sequence = sequence {
            if inputReversed {
                return Array(sequence.reversed())
            } else {
                return sequence
            }
        } else {
            return nil
        }
    }

    override open func sequence(data: [String: ModelObjectProtocol]?) -> [ModelObjectProtocol]? {
        return nil
    }

    open func merge(_ sequence1: [ModelObjectProtocol], _ sequence2: [ModelObjectProtocol]) -> [ModelObjectProtocol] {
        if let first1 = sequence1.first, let first2 = sequence2.first, let last1 = sequence1.last, let last2 = sequence2.last {
            if last1.order?(ascending: first2) == true {
                var merged = sequence1
                merged.append(contentsOf: sequence2)
                return merged
            } else if last2.order?(ascending: first1) == true {
                var merged = sequence2
                merged.append(contentsOf: sequence1)
                return merged
            } else {
                if first1.order?(ascending: first2) == true {
                    if last1.order?(ascending: last2) == true {
                        return binaryMerge(sequence1, sequence2)
                    } else {
                        return sequence1
                    }
                } else if first2.order?(ascending: first1) == true {
                    if last2.order?(ascending: last1) == true {
                        return binaryMerge(sequence2, sequence1)
                    } else {
                        return sequence2
                    }
                } else {
                    return sequence1
                }
            }
        } else {
            return sequence1.count > 0 ? sequence1 : sequence2
        }
    }

    open func binaryMerge(_ sequence1: [ModelObjectProtocol], _ sequence2: [ModelObjectProtocol]) -> [ModelObjectProtocol] {
        // first sequence is in front of the second
        if let last1 = sequence1.last {
            if let index = sequence2.binarySearch(for: { element2 in
                return compare(element2, last1)
            }) {
                if index < sequence2.count - 1 {
                    let nextIndex = index + 1
                    let rest = sequence2[nextIndex...]
                    var merged = sequence1
                    merged.append(contentsOf: rest)
                    return merged
                } else {
                    return sequence1
                }
            } else {
                return walk(sequence1, sequence2)
            }
        } else {
            return sequence2
        }
    }

    open func compare(_ item1: ModelObjectProtocol, _ item2: ModelObjectProtocol) -> ComparisonResult {
        if item1 === item2 {
            return .orderedSame
        } else {
            let ascending = item1.order?(ascending: item2)
            if ascending == true {
                return .orderedAscending
            } else if ascending == false {
                return .orderedDescending
            } else {
                return .orderedAscending
            }
        }
    }

    open func walk(_ sequence1: [ModelObjectProtocol], _ sequence2: [ModelObjectProtocol]) -> [ModelObjectProtocol] {
        var merged = [ModelObjectProtocol]()
        let cursor1 = Cursor(objects: sequence1)
        let cursor2 = Cursor(objects: sequence2)
        while let obj1 = cursor1.current, let obj2 = cursor2.current {
            if obj1 === obj2 {
                merged.append(obj1)
                cursor1.advance()
                cursor2.advance()
            } else {
                if obj1.order?(ascending: obj2) ?? false {
                    merged.append(obj1)
                    cursor1.advance()
                } else {
                    merged.append(obj2)
                    cursor2.advance()
                }
            }
        }

        if let rest = cursor1.rest() {
            merged.append(contentsOf: rest)
        }
        if let rest = cursor2.rest() {
            merged.append(contentsOf: rest)
        }

        return merged
    }
}
