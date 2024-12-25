//
//  dydxOnboardScanViewBuilder.swift
//  dydxPresenters
//
//  Created by Rui Huang on 3/13/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import CameraParticles
import dydxStateManager
import dydxCartera

public class dydxOnboardScanViewBuilder: NSObject, ObjectBuilderProtocol {
    public func build<T>() -> T? {
        let qrCodeViewController = QRCodeViewController()
        let preview = UIView()
        qrCodeViewController.preview = preview
        let presenter = dydxOnboardScanViewPresenter(preview: preview, qrCodePublisher: qrCodeViewController.$qrcode)
        let view = presenter.viewModel?.createView() ?? PlatformViewModel().createView()
        let viewController = dydxOnboardScanViewController(presenter: presenter, view: view, configuration: .default)
        viewController.qrCodeViewController = qrCodeViewController
        return viewController as? T
    }
}

private class dydxOnboardScanViewController: HostingViewController<PlatformView, dydxOnboardScanViewModel> {
    var qrCodeViewController: QRCodeViewController?

    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == "/onboard/scan" {
            return true
        }
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        embed(qrCodeViewController, in: view)
    }
}

private protocol dydxOnboardScanViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: dydxOnboardScanViewModel? { get }
}

private class dydxOnboardScanViewPresenter: HostedViewPresenter<dydxOnboardScanViewModel>, dydxOnboardScanViewPresenterProtocol {
    private let qrCodePublisher: Published<String?>.Publisher

    private var cameraPermission: CameraPermission? {
        didSet {
            changeObservation(from: oldValue, to: cameraPermission, keyPath: #keyPath(CameraPermission.authorization)) { [weak self] _, _, _, _ in
                self?.updateCameraPermission()
            }
        }
    }

    private var showingError: Bool = false {
        didSet {
            if showingError != oldValue {
                viewModel?.showingError = showingError
                if showingError {
                    DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(2))) { [weak self] in
                        self?.showingError = false
                    }
                }
            }
        }
    }

    init(preview: UIView, qrCodePublisher: Published<String?>.Publisher) {
        self.qrCodePublisher = qrCodePublisher
        super.init()

        viewModel = dydxOnboardScanViewModel()
        viewModel?.cameraPreview = preview
        viewModel?.enableCameraAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/authorization/camera"), animated: true, completion: nil)
        }
        viewModel?.backAction = {
            Router.shared?.navigate(to: RoutingRequest(path: "/onboard/scan/instructions"), animated: true, completion: nil)
        }
    }

    override func start() {
        super.start()

        qrCodePublisher
            .removeDuplicates()
            .compactMap { $0 }
            .sink { [weak self] qrCode in
                self?.process(qrcode: qrCode)
            }
            .store(in: &subscriptions)

        cameraPermission = CameraPermission.shared
    }

    private func updateCameraPermission() {
        if let cameraPermission = cameraPermission {
            switch cameraPermission.authorization {
            case .authorized:
                viewModel?.cameraPermitted = true
            default:
                viewModel?.cameraPermitted = false
            }
        } else {
            viewModel?.cameraPermitted = false
        }
    }

    private func process(qrcode: String) {
        if let data = qrcode.data(using: .utf8) {
            if let string = String(data: data, encoding: .utf8) {
                getDescriptionkey {[weak self] key in
                    if let self = self {
                        self.decrypt(encryptedText: string, password: key) { [weak self] decrypted in
                            if let decrypted = decrypted, decrypted != "undefined" {
                                self?.process(decrypted: decrypted)
                            } else {
                                self?.showingError = true
                            }
                        }
                    }
                }
            }
        }
    }

    private func getDescriptionkey(completed: @escaping (_ key: String) -> Void) {
        if let decriptionKey = decriptionKey {
            completed(decriptionKey)
        } else {
            let prompter = PrompterFactory.shared?.textPrompter()
            prompter?.prompt(title: DataLocalizer.localize(path: "APP.ONBOARDING.ENTER_CODE"),
                             message: nil, text: nil, placeholder: nil, completion: { text, ok in
                if ok, let text = text {
                    completed(text)
                }
            })
        }
    }

    private func process(decrypted: String?) {
        if let json = decode(string: decrypted) {
            showingError = false
            if let address = parser.asString(json["cosmosAddress"]), let mnemonic = parser.asString(json["mnemonic"]) {
                // TODO: parse ethereum address when it becomes available in the Sync with Desktop QR Scan flow
                AbacusStateManager.shared.setV4(ethereumAddress: nil,
                                                walletId: nil,
                                                cosmoAddress: address,
                                                mnemonic: mnemonic)
                Router.shared?.navigate(to: RoutingRequest(path: "/action/post_onboarding",
                                                           params: ["cosmoAddress": address, "mnemonic": mnemonic]),
                                        animated: true, completion: nil)
            } else {
                showingError = true
            }
        } else {
            showingError = true
        }
    }

    private func decode(string: String?) -> [String: Any]? {
        if let data = string?.data(using: .utf8) {
            return try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } else {
            return nil
        }
    }

    private var decriptionKey: String? {
        nil
    }

    private func decrypt(encryptedText: String, password: String, completion: @escaping AESDecryptCompletionBlock) {
        StarkJavascript.shared.aesDecrypt(string: encryptedText, password: password) { result in
            completion(result as? String)
        }
    }

    private typealias AESDecryptCompletionBlock = (_ decrypted: String?) -> Void
}

private class V3WalletConnectionParser {
    struct Result {
        let ethereumAddress: String
        let apiKey: String
        let secret: String
        let passPhrase: String
    }

    static func parse(json: [String: Any]?) -> Result? {
        let parser = Parser()
        if let json = json {
            if let starkKeyPair = json["starkKeyPair"] as? [String: Any], let apiKeyPair = json["apiKeyPair"] as? [String: Any], let ethereumAddress = parser.asString(starkKeyPair["walletAddress"]) {
                if let secret = parser.asString(apiKeyPair["secret"]),
                   let key = parser.asString(apiKeyPair["key"]),
                   let passphrase = parser.asString(apiKeyPair["passphrase"]) {
                    return Result(ethereumAddress: ethereumAddress, apiKey: key, secret: secret, passPhrase: passphrase)
                }
            }
        }
        return nil
    }
}
