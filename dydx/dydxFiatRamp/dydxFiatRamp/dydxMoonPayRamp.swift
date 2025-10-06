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
import Abacus
import dydxAnalytics

final public class dydxMoonPayRamp {
    private static let providerName = "moonpay"

    enum dydxMoonPayRampError: Error {
        case invalidUrl
        case noSecretkey
        case noSignUrl
        case unableToGetSignature
        case custom(String)

        var message: String {
            switch self {
            case .invalidUrl:
                return "Invalid URL"
            case .noSecretkey:
                return "No secret key"
            case .noSignUrl:
                return "No sign url"
            case .unableToGetSignature:
                return "Unable to get signature"
            case .custom(let msg):
                return msg
            }
        }
    }

    private var moonPaySdk: MoonPayiOSSdk?

    private let isSandbox: Bool
    private let moonPayPk: String
    private let moonPaySk: String?
    private let moonPaySignUrl: String?
    private let isDarkTheme: Bool

    public init (isSandbox: Bool, moonPayPk: String, moonPaySk: String? = nil, moonPaySignUrl: String? = nil, isDarkTheme: Bool = false) {
        self.isSandbox = isSandbox
        self.moonPayPk = moonPayPk
        self.moonPaySk = moonPaySk
        self.moonPaySignUrl = moonPaySignUrl
        self.isDarkTheme = isDarkTheme
    }

    public func show(targetAddress: String, usdAmount: Double? = nil) {
        Tracking.shared?.logSharedEvent(ClientTrackableEventType.FiatDepositShowInputEvent())

        let handlers = MoonPayHandlers(
            onAuthToken: { _ in
                Tracking.shared?.logSharedEvent(ClientTrackableEventType.FiatDepositMoonPayCallbackEvent(callbackName: "onAuthToken", data: [:]))
            },
            onSwapsCustomerSetupComplete: {
                Tracking.shared?.logSharedEvent(ClientTrackableEventType.FiatDepositMoonPayCallbackEvent(callbackName: "onSwapsCustomerSetupComplete", data: [:]))
            },
            onUnsupportedRegion: {
                Tracking.shared?.logSharedEvent(ClientTrackableEventType.FiatDepositMoonPayCallbackEvent(callbackName: "onUnsupportedRegion", data: [:]))
            },
            onKmsWalletCreated: {
                Tracking.shared?.logSharedEvent(ClientTrackableEventType.FiatDepositMoonPayCallbackEvent(callbackName: "onKmsWalletCreated", data: [:]))
            },
            onLogin: { data in
                Tracking.shared?.logSharedEvent(ClientTrackableEventType.FiatDepositMoonPayCallbackEvent(callbackName: "onLogin", data: [
                    "isRefresh": data.isRefresh
                ]))
            },
            onInitiateDeposit: { data in
                Tracking.shared?.logSharedEvent(ClientTrackableEventType.FiatDepositMoonPayCallbackEvent(callbackName: "onInitiateDeposit", data: [
                    "cryptoCurrency": data.cryptoCurrency,
                    "cryptoCurrencyAmount": data.cryptoCurrencyAmount,
                    "depositWalletAddress": data.depositWalletAddress,
                    "fiatCurrency": data.fiatCurrency,
                    "fiatCurrencyAmount": data.fiatCurrencyAmount ?? "0",
                    "transactionId": data.transactionId
                ]))

                let response = OnInitiateDepositResponsePayload(depositId: "yourDepositId")
                return response
            },
            onTransactionCreated: { data in
                Tracking.shared?.logSharedEvent(ClientTrackableEventType.FiatDepositMoonPayCallbackEvent(callbackName: "onTransactionCreated", data: [
                    "baseCurrencyAmount": data.baseCurrencyAmount,
                    "baseCurrencyCode": data.baseCurrencyCode,
                    "id": data.id,
                    "status": data.status
                ]))
            }
        )

        let params = MoonPayBuyQueryParams(apiKey: moonPayPk)
        params.setBaseCurrencyCode(value: "USD")
        if let usdAmount {
            params.setBaseCurrencyAmount(value: KotlinDouble(value: usdAmount))
        }
        params.setPaymentMethod(value: "apple_pay")
        params.setTheme(value: isDarkTheme ? "dark" : "light")
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

                            Tracking.shared?.logSharedEvent(ClientTrackableEventType.FiatDepositRouteToProviderCompletedEvent(amountUsd: KotlinDouble(value: usdAmount ?? 0), depositAddress: targetAddress, provider: Self.providerName))
                        } else {
                            ErrorInfo.shared?.info(title: DataLocalizer.localize(path: "APP.GENERAL.ERROR"), message: error?.message, type: .error, error: nil)
                            Tracking.shared?.logSharedEvent(ClientTrackableEventType.FiatDepositRouteToProviderErrorEvent(message: error?.message, provider: Self.providerName))
                        }
                    }
                } else {
                    ErrorInfo.shared?.info(title: DataLocalizer.localize(path: "APP.GENERAL.ERROR"), message: dydxMoonPayRampError.invalidUrl.message, type: .error, error: nil)
                    Tracking.shared?.logSharedEvent(ClientTrackableEventType.FiatDepositRouteToProviderErrorEvent(message: dydxMoonPayRampError.invalidUrl.message, provider: Self.providerName))
                }
            } else {
                ErrorInfo.shared?.info(title: DataLocalizer.localize(path: "APP.GENERAL.ERROR"), message: dydxMoonPayRampError.invalidUrl.message, type: .error, error: nil)
                Tracking.shared?.logSharedEvent(ClientTrackableEventType.FiatDepositRouteToProviderErrorEvent(message: dydxMoonPayRampError.invalidUrl.message, provider: Self.providerName))
            }
        } else {
            ErrorInfo.shared?.info(title: DataLocalizer.localize(path: "APP.GENERAL.ERROR"), message: dydxMoonPayRampError.unableToGetSignature.message, type: .error, error: nil)
            Tracking.shared?.logSharedEvent(ClientTrackableEventType.FiatDepositRouteToProviderErrorEvent(message: dydxMoonPayRampError.unableToGetSignature.message, provider: Self.providerName))
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
            if let moonPaySignUrl {
                getRemoteSignature(encodedUrlData: encodedUrlData, url: moonPaySignUrl, completion: completion)
            } else {
                completion(nil, dydxMoonPayRampError.noSignUrl)
            }
        }
    }

    private func getRemoteSignature(encodedUrlData: Data, url: String, completion: @escaping ((String?, dydxMoonPayRampError?) -> Void)) {
        let pathData = encodedUrlData.base64EncodedString()
        let urlString = "\(url)?path=\(pathData)"

        guard let url = URL(string: urlString) else {
            completion(nil, dydxMoonPayRampError.invalidUrl)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(nil, dydxMoonPayRampError.custom("Failed obtain signature: \(error)"))
                }
                return
            }

            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let signatureResponse = try decoder.decode(SignatureResponse.self, from: data)
                    DispatchQueue.main.async {
                        if let signature = signatureResponse.signature {
                            completion(signature, nil)
                        } else {
                            completion(nil, dydxMoonPayRampError.custom("Unexpected response: \(String(decoding: data, as: UTF8.self))"))
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, dydxMoonPayRampError.custom("Failed to parse JSON: \(error)"))
                    }
                }
            } else {
                completion(nil, dydxMoonPayRampError.unableToGetSignature)
            }
        }

        task.resume()
    }
}

private struct SignatureResponse: Codable {
    let signature: String?
}
