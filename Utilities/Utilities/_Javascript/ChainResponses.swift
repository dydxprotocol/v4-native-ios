//
//  ChainResponses.swift
//  Utilities
//
//  Created by Michael Maguire on 10/3/24.
//  Copyright © 2024 dYdX Trading Inc. All rights reserved.
//

import Foundation

public struct ChainError: Decodable, Error {
    static let unknownError = ChainError(message: "An unknown error occurred", line: nil, column: nil, stack: nil)

    public let message: String
    public let line: Int?
    public let column: Int?
    public let stack: String?
}

public struct ChainErrorResponse: Decodable, Error {
    public let error: ChainError
}

public struct ChainEvent: Decodable {
    let type: String
    let attributes: [ChainEventAttribute]
}

public struct ChainEventAttribute: Decodable {
    let key: String
    let value: String
}

public struct ChainSuccessResponse: Decodable {
    let height: Int?
    let hash: String?
    let code: Int?
    let tx: String
    let txIndex: Int?
    let gasUsed: String?
    let gasWanted: String?
    let events: [ChainEvent]?
}
