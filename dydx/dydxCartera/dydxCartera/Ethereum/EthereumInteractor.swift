//
//  EthereumInteractor.swift
//  dydxCartera
//
//  Created by Rui Huang on 4/11/23.
//

import BigInt
import ParticlesKit
import Utilities
import web3

public typealias EthereumNetworkCompletion = (EthereumClientError?, EthereumNetwork?) -> Void
public typealias EthereumBigUIntCompletion = (EthereumClientError?, BigUInt?) -> Void
public typealias EthereumPreprationCompletion = (EthereumClientError?, BigUInt?, BigUInt?, Int?) -> Void
public typealias EthereumIntCompletion = (EthereumClientError?, Int?) -> Void
public typealias EthereumStringCompletion = (EthereumClientError?, String?) -> Void
public typealias EthereumTransactionReceiptCompletion = (EthereumClientError?, EthereumTransactionReceipt?) -> Void
public typealias EthereumTransactionCompletion = (EthereumClientError?, EthereumTransaction?) -> Void
public typealias EthereumGetLogsCompletion = (EthereumClientError?, [EthereumLog]?) -> Void
public typealias EthereumBlockCompetion = (EthereumClientError?, EthereumBlockInfo?) -> Void

public final class EthereumInteractor {

    private var _client: EthereumHttpClient?
    private var client: EthereumHttpClient? {
        if _client == nil, let clientUrl = URL(string: url) {
            _client = EthereumHttpClient(url: clientUrl)
        }
        return _client
    }

    private let url: String

    private let queue = DispatchQueue.global(qos: .userInitiated)

    public init(url: String) {
        self.url = url
    }

    public func net_version(completion: @escaping EthereumNetworkCompletion) {
        queue.async { [weak self] in
            self?.client?.net_version { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let network):
                        completion(nil, network)
                    case .failure(let error):
                        completion(error, nil)
                    }
                }
            }
        }
    }

    public func eth_gasPrice(completion: @escaping EthereumBigUIntCompletion) {
        queue.async { [weak self] in
            self?.client?.eth_gasPrice { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let value):
                        completion(nil, value)
                    case .failure(let error):
                        completion(error, nil)
                    }
                }
            }
        }
    }

    public func eth_blockNumber(completion: @escaping EthereumIntCompletion) {
        queue.async { [weak self] in
            self?.client?.eth_blockNumber { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let value):
                        completion(nil, value)
                    case .failure(let error):
                        completion(error, nil)
                    }
                }
            }
        }
    }

    public func eth_getBalance(address: EthereumAddress, block: EthereumBlock = .Latest, completion: @escaping EthereumBigUIntCompletion) {
        queue.async { [weak self] in
            self?.client?.eth_getBalance(address: address, block: block) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let value):
                        completion(nil, value)
                    case .failure(let error):
                        completion(error, nil)
                    }
                }
            }
        }
    }

    public func eth_getCode(address: EthereumAddress, block: EthereumBlock = .Latest, completion: @escaping EthereumStringCompletion) {
        queue.async { [weak self] in
            self?.client?.eth_getCode(address: address, block: block) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let value):
                        completion(nil, value)
                    case .failure(let error):
                        completion(error, nil)
                    }
                }
            }
        }
    }

    public func eth_estimateGas(_ transaction: EthereumTransaction, completion: @escaping EthereumBigUIntCompletion) {
        queue.async { [weak self] in
            self?.client?.eth_estimateGas(transaction) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let value):
                        completion(nil, value)
                    case .failure(let error):
                        completion(error, nil)
                    }
                }
            }
        }
    }

    public func eth_sendRawTransaction(_ transaction: EthereumTransaction, withAccount account: EthereumAccount, completion: @escaping EthereumStringCompletion) {
        queue.async { [weak self] in
            self?.client?.eth_sendRawTransaction(transaction, withAccount: account) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let value):
                        completion(nil, value)
                    case .failure(let error):
                        completion(error, nil)
                    }
                }
            }
        }
    }

    public func eth_getTransactionCount(address: EthereumAddress, block: EthereumBlock, completion: @escaping EthereumIntCompletion) {
        queue.async { [weak self] in
            self?.client?.eth_getTransactionCount(address: address, block: block) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let value):
                        completion(nil, value)
                    case .failure(let error):
                        completion(error, nil)
                    }
                }
            }
        }
    }

    public func eth_getTransactionReceipt(txHash: String, completion: @escaping EthereumTransactionReceiptCompletion) {
        queue.async { [weak self] in
            self?.client?.eth_getTransactionReceipt(txHash: txHash) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let receipt):
                        completion(nil, receipt)
                    case .failure(let error):
                        completion(error, nil)
                    }
                }
            }
        }
    }

    public func eth_getTransaction(byHash txHash: String, completion: @escaping EthereumTransactionCompletion) {
        queue.async { [weak self] in
            self?.client?.eth_getTransaction(byHash: txHash) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let value):
                        completion(nil, value)
                    case .failure(let error):
                        completion(error, nil)
                    }
                }
            }
        }
    }

    public func eth_call(_ transaction: EthereumTransaction, block: EthereumBlock = .Latest, completion: @escaping EthereumStringCompletion) {
        queue.async { [weak self] in
            self?.client?.eth_call(transaction, block: block) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let value):
                        Console.shared.log("eth_call log: \(value)")
                        completion(nil, value)
                    case .failure(let error):
                        completion(error, nil)
                    }
                }
            }
        }
    }

    public func eth_getLogs(addresses: [EthereumAddress]?, topics: [String?]?, fromBlock from: EthereumBlock = .Earliest, toBlock to: EthereumBlock = .Latest, completion: @escaping EthereumGetLogsCompletion) {
        queue.async { [weak self] in
            self?.client?.eth_getLogs(addresses: addresses, topics: topics, fromBlock: from, toBlock: to) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let value):
                        completion(nil, value)
                    case .failure(let error):
                        completion(error, nil)
                    }
                }
            }
        }
    }

    public func eth_getLogs(addresses: [EthereumAddress]?, orTopics topics: [[String]?]?, fromBlock from: EthereumBlock = .Earliest, toBlock to: EthereumBlock = .Latest, completion: @escaping EthereumGetLogsCompletion) {
        queue.async { [weak self] in
            self?.client?.eth_getLogs(addresses: addresses, orTopics: topics, fromBlock: from, toBlock: to) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let value):
                        completion(nil, value)
                    case .failure(let error):
                        completion(error, nil)
                    }
                }
            }
        }
    }

    public func eth_getBlockByNumber(_ block: EthereumBlock, completion: @escaping EthereumBlockCompetion) {
        queue.async { [weak self] in
            self?.client?.eth_getBlockByNumber(block) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let value):
                        completion(nil, value)
                    case .failure(let error):
                        completion(error, nil)
                    }
                }
            }
        }
    }

    public func call<T: ABIResponse>(_ transaction: EthereumTransaction, responseType: T.Type, block: EthereumBlock = .Latest, completion: @escaping ((EthereumClientError?, T?) -> Void)) {
        queue.async { [weak self] in
            self?.client?.eth_call(transaction, block: block) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let value):
                        if let response = (try? T(data: value)) {
                            return completion(nil, response)
                        } else {
                            return completion(EthereumClientError.decodeIssue, nil)
                        }
                    case .failure(let error):
                        completion(error, nil)
                    }
                }
            }
        }
    }
}
