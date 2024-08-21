//
//  Sequence+Reduce.swift
//  Utilities
//
//  Created by Qiang Huang on 2/3/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import Foundation

private struct BreakConditionError<Result>: Error {
    let result: Result
}

extension Sequence {
    func reduce<Result>(
        _ initialResult: Result,
        _ nextPartialResult: (Result, Self.Iterator.Element) throws -> Result,
        until conditionPassFor: (Result, Self.Iterator.Element) -> Bool
    ) rethrows -> Result {
        do {
            return try reduce(
                initialResult,
                {
                    if conditionPassFor($0, $1) {
                        throw BreakConditionError(result: $0)
                    } else {
                        return try nextPartialResult($0, $1)
                    }
                }
            )
        } catch let error as BreakConditionError<Result> {
            return error.result
        }
    }

    func reduce<Result>(
        _ initialResult: Result,
        _ nextPartialResult: (Result, Self.Iterator.Element) throws -> Result,
        while conditionPassFor: (Result, Self.Iterator.Element) -> Bool
    ) rethrows -> Result {
        do {
            return try reduce(
                initialResult,
                {
                    let _nextPartialResult = try nextPartialResult($0, $1)
                    if conditionPassFor(_nextPartialResult, $1) {
                        return _nextPartialResult
                    } else {
                        throw BreakConditionError(result: $0)
                    }
                }
            )
        } catch let error as BreakConditionError<Result> {
            return error.result
        }
    }
}
