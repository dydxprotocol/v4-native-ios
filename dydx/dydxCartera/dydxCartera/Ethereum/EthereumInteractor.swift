//
//  EthereumInteractor.swift
//  dydxCartera
//
//  Created by Rui Huang on 4/11/23.
//

import BigInt
import ParticlesKit
import Utilities
import Web3

public final class EthereumInteractor {

    private var _client: Web3?
    private var client: Web3? {
        if _client == nil {
            _client = Web3(rpcURL: url)
        }
        return _client
    }

    private let url: String

    private let queue = DispatchQueue.global(qos: .userInitiated)

    public init(url: String) {
        self.url = url
    }

    public func net_version(completion: @escaping Web3.Web3ResponseCompletion<String>) {
        client?.net.version { resp in
            DispatchQueue.main.async { completion(resp) }
        }
    }

    public func eth_blockNumber(completion: @escaping Web3.Web3ResponseCompletion<EthereumQuantity>) {
        client?.eth.blockNumber { resp in
            DispatchQueue.main.async { completion(resp) }
        }
    }

    public func eth_getBalance(address: EthereumAddress, block: EthereumQuantityTag = .latest, completion: @escaping Web3.Web3ResponseCompletion<EthereumQuantity>) {
        client?.eth.getBalance(address: address, block: block) { resp in
            DispatchQueue.main.async { completion(resp) }
        }
    }

    public func eth_getCode(address: EthereumAddress, block: EthereumQuantityTag = .latest, completion: @escaping Web3.Web3ResponseCompletion<EthereumData>) {
        client?.eth.getCode(address: address, block: block) { resp in
            DispatchQueue.main.async { completion(resp) }
        }
    }

    public func eth_estimateGas(_ transaction: EthereumCall, completion: @escaping Web3.Web3ResponseCompletion<EthereumQuantity>) {
        client?.eth.estimateGas(call: transaction) { resp in
            DispatchQueue.main.async { completion(resp) }
        }
    }

    public func eth_sendRawTransaction(_ transaction: EthereumSignedTransaction, completion: @escaping Web3.Web3ResponseCompletion<EthereumData>) {
        client?.eth.sendRawTransaction(transaction: transaction) { resp in
            DispatchQueue.main.async { completion(resp) }
        }
    }

    public func eth_getTransactionCount(address: EthereumAddress, block: EthereumQuantityTag, completion: @escaping Web3.Web3ResponseCompletion<EthereumQuantity>) {
        client?.eth.getTransactionCount(address: address, block: block) { resp in
            DispatchQueue.main.async { completion(resp) }
        }
    }

    public func eth_getTransactionReceipt(txHash: EthereumData, completion: @escaping Web3.Web3ResponseCompletion<EthereumTransactionReceiptObject?>) {
        client?.eth.getTransactionReceipt(transactionHash: txHash) { resp in
            DispatchQueue.main.async { completion(resp) }
        }
    }

    public func eth_getTransactionByHash(txHash: EthereumData, completion: @escaping Web3.Web3ResponseCompletion<EthereumTransactionObject?>) {
        client?.eth.getTransactionByHash(blockHash: txHash) { resp in
            DispatchQueue.main.async { completion(resp) }
        }
    }

    public func eth_call(_ transaction: EthereumCall, block: EthereumQuantityTag = .latest, completion: @escaping Web3.Web3ResponseCompletion<EthereumData>) {
        client?.eth.call(call: transaction, block: block) { resp in
            DispatchQueue.main.async { completion(resp) }
        }
    }

    public func eth_getBlockByNumber(_ block: EthereumQuantityTag, completion: @escaping Web3.Web3ResponseCompletion<EthereumBlockObject?>) {
        client?.eth.getBlockByNumber(block: block, fullTransactionObjects: true) { resp in
            DispatchQueue.main.async { completion(resp) }
        }
    }

//    public func call<T: ABIResponse>(_ transaction: EthereumTransaction, responseType: T.Type, block: EthereumBlock = .Latest, completion: @escaping ((EthereumClientError?, T?) -> Void)) {
//        queue.async { [weak self] in
//            self?.client?.eth_call(transaction, block: block) { result in
//                DispatchQueue.main.async {
//                    switch result {
//                    case .success(let value):
//                        if let response = (try? T(data: value)) {
//                            return completion(nil, response)
//                        } else {
//                            return completion(EthereumClientError.decodeIssue, nil)
//                        }
//                    case .failure(let error):
//                        completion(error, nil)
//                    }
//                }
//            }
//        }
//    }
}
