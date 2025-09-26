//
//  dydxMoonPayRamp.swift
//  dydxFiatRamp
//
//  Created by Rui Huang on 11/04/2025.
//

import Foundation
import MoonPaySdk
import Utilities
import CryptoKit

final public class dydxMoonPayRamp: SingletonProtocol {
    public static var shared = dydxMoonPayRamp()

    private var moonPaySdk: MoonPayiOSSdk?
    private let session = URLSession(configuration: .default)

    private let isSandbox: Bool = false

    public init () {
    }

    public func show(targetAddress: String, usdAmount: Double? = nil) {
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

        let publicKey = isSandbox ?
            "pk_test_2Cy2D3iPl0Y0DI8ru0yvtyeKC54R9GBV" :
            "<to_do>"
        let params = MoonPayBuyQueryParams(apiKey: publicKey)
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
                let signature = getSignature(encodedUrlData: queryString.data(using: .utf8)!)
                moonPaySdk?.updateSignature(signature: signature)
            }
        }

        moonPaySdk?.show(mode: MoonPayRenderingOptioniOS.WebViewOverlay())
     }

    private func getSignature(encodedUrlData: Data) -> String {
        let secretString = isSandbox ? "sk_test_XkFPvgZ57z7DEEMm4lnzRwfj8DsfMHl9" : "<to_do>"
        let key = SymmetricKey(data: Data(secretString.utf8))
        let signature = HMAC<SHA256>.authenticationCode(for: encodedUrlData, using: key)
        let signatureHex = Data(signature).base64EncodedString()
        return signatureHex
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
