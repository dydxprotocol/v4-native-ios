//
//  dydxMoonPayRamp.swift
//  dydxFiatRamp
//
//  Created by Rui Huang on 11/04/2025.
//

import Foundation
import MoonPaySdk
internal import Utilities
import CryptoKit

public enum dydxMoonPayRampError: Error {
    case invalidUrl
    case noSecretkey
    case unableToGetSignature

    public var message: String {
        switch self {
        case .invalidUrl:
            return "Invalid URL"
        case .noSecretkey:
            return "No secret key"
        case .unableToGetSignature:
            return "Unable to get signature"
        }
    }
}

final public class dydxMoonPayRamp {
    private var moonPaySdk: MoonPayiOSSdk?
    private let session = URLSession(configuration: .default)

    private let isSandbox: Bool
    private let moonPayPk: String
    private let moonPaySk: String?

    public init (isSandbox: Bool, moonPayPk: String, moonPaySk: String? = nil) {
        self.isSandbox = isSandbox
        self.moonPayPk = moonPayPk
        self.moonPaySk = moonPaySk
    }

    public func show(targetAddress: String,
                     usdAmount: Double? = nil,
                     statusChangeHandler: @escaping ((String?, dydxMoonPayRampError?) -> Void)
    ) {
        // These run in your application and are all the of handlers available to you.
        let handlers = MoonPayHandlers(
            onAuthToken: { data in
                print("onAuthToken called", data)
            },
            onSwapsCustomerSetupComplete: {
                print("onSwapsCustomerSetupComplete called")
            },
            onUnsupportedRegion: {
                print("onUnsupportedRegion called")
            },
            onKmsWalletCreated: {
                print("onKmsWalletCreated called")
            },
            onLogin: { data in
                print("onLogin called", data)
            },
            onInitiateDeposit: { _ in
                print("onInitiateDepositCalled")
                let response = OnInitiateDepositResponsePayload(depositId: "yourDepositId")
                return response
            },
            onTransactionCreated: { data in
                print("onTransactionCreated called", data)
            }
        )

        let params = MoonPayBuyQueryParams(apiKey: moonPayPk)
        params.setBaseCurrencyCode(value: "USD")
        if let usdAmount {
            params.setBaseCurrencyAmount(value: KotlinDouble(value: usdAmount))
        }
        params.setPaymentMethod(value: "apple_pay")
        params.setTheme(value: "dark")
        params.setCurrencyCode(value: "usdc_noble")
        params.setWalletAddress(value: targetAddress)

        let config = MoonPaySdkBuyConfig(
            debug: false,
            environment: isSandbox ? MoonPayWidgetEnvironment.sandbox : MoonPayWidgetEnvironment.production,
            params: params,
            handlers: handlers
        )

        if moonPaySdk == nil {
            moonPaySdk = MoonPayiOSSdk(config: config)
        } else {
            moonPaySdk?.config = config
        }

        if let url = moonPaySdk?.generateUrlForSigning() {
            let components = url.split(separator: "?")
            if components.count == 2 {
                let queryString = "?" + components[1]
                if let queryPath = queryString.data(using: .utf8) {
                    getSignature(encodedUrlData: queryPath) { [weak self] signature, error in
                        if let signature {
                            self?.moonPaySdk?.updateSignature(signature: signature)
                            self?.moonPaySdk?.show(mode: MoonPayRenderingOptioniOS.WebViewOverlay())
                        } else {
                            statusChangeHandler(nil, error)
                        }
                    }
                }
            } else {
                statusChangeHandler(nil, dydxMoonPayRampError.invalidUrl)
            }
        } else {
            statusChangeHandler(nil, dydxMoonPayRampError.unableToGetSignature)
        }
    }

    private func getSignature(encodedUrlData: Data, completion: @escaping ((String?, dydxMoonPayRampError?) -> Void)) {
        if isSandbox {
            if let moonPaySk {
                 let key = SymmetricKey(data: Data(moonPaySk.utf8))
                let signature = HMAC<SHA256>.authenticationCode(for: encodedUrlData, using: key)
                let signatureHex = Data(signature).base64EncodedString()
                completion(signatureHex, nil)
            } else {
                completion(nil, dydxMoonPayRampError.noSecretkey)
            }
        } else {
            // completion(nil, Error("Not in sandbox"))
        }
    }

//    private func upload(_ data: Data, to url: URL) async throws -> URLResponse {
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//
//        let (responseData, response) = try await session.upload(
//            for: request, from: data
//        )
//
//        return response
//    }

}
