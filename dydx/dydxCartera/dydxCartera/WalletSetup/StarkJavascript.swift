//
//  StarkJavascript.swift
//  dydxModels
//
//  Created by Qiang Huang on 5/29/21.
//  Copyright © 2021 dYdX. All rights reserved.
//

import ParticlesKit
import Utilities

public final class StarkJavascript: NSObject, SingletonProtocol {
    public static var shared: StarkJavascript = StarkJavascript()

    private var starklibInitialized: Bool = false
    private var starklibRunner: JavascriptRunner? = {
        JavascriptRunner.runner(file: "starkex-lib.js")
    }()

    private var starkethInitialized: Bool = false
    private var starkethRunner: JavascriptRunner? = {
        JavascriptRunner.runner(file: "starkex-eth.js")
    }()

    private func loadStarkLib(completion: @escaping JavascriptCompletion) {
        if starklibInitialized {
            completion(nil)
        } else {
            if let runner = starklibRunner {
                runner.load { successful in
                    guard successful else {
                        Console.shared.log("StarkJavascript loading failed")
                        completion(nil)
                        return
                    }
                    runner.run(script: "var helper = new StarkHelper.StarkHelper()") { [weak self] _ in
                        self?.starklibInitialized = true
                        completion(nil)
                    }
                }

            } else {
                completion(nil)
            }
        }
    }

    private func loadStarkEth(completion: @escaping JavascriptCompletion) {
        if starkethInitialized {
            completion(nil)
        } else {
            if let runner = starkethRunner {
                runner.load { successful in
                    guard successful else {
                        Console.shared.log("StarkJavascript loading failed")
                        completion(nil)
                        return
                    }
                    runner.run(script: "var helper = new StarkHelper.StarkHelper()") { [weak self] _ in
                        self?.starkethInitialized = true
                        completion(nil)
                    }
                }
            } else {
                completion(nil)
            }
        }
    }

    public func aesDecrypt(string: String?, password: String?, completion: @escaping JavascriptCompletion) {
        loadStarkLib { [weak self] _ in
            if let self = self, let string = string, let password = password, let runner = self.starklibRunner {
                let script = "helper.aesDecrypt('\(string)','\(password)')"
                runner.run(script: script, completion: { result in
                    if (result as? String) == "undefined" || result == nil {
                        let error = NSError(domain: "javascript.aesDecrypt", code: 0, userInfo: [
                            "string": string
                        ])
                        ErrorLogging.shared?.log(error)
                    }
                    completion(result)
                })
            } else {
                completion(nil)
            }
        }
    }

    func generateStarkKey(signature: String?, completion: @escaping JavascriptCompletion) {
        loadStarkLib { [weak self] _ in
            if let signature = signature, let runner = self?.starklibRunner {
                let script = "helper.privateKeyFromSignature('\(signature)')"
                runner.run(script: script, completion: { result in
                    if (result as? String) == "undefined" || result == nil {
                        let error = NSError(domain: "sign.starkKey", code: 0, userInfo: [
                            "signature": signature
                        ])
                        ErrorLogging.shared?.log(error)
                    }
                    completion(result)
                })
            } else {
                completion(nil)
            }
        }
    }
}
