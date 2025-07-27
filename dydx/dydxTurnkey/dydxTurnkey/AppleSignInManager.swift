//
//  AppleSignInManager.swift
//  dydxTurnkey
//
//  Created by Rui Huang on 26/07/2025.
//

import AuthenticationServices

public class AppleSignInManager: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private var controller: ASAuthorizationController?
    private var completion: ((String?, Error?) -> Void)?

    public func signInWithApple(nonce: String, completion: @escaping (String?, Error?) -> Void) {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.email] // [.fullName, .email]
        request.nonce = nonce

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()

        self.controller = controller
        self.completion = completion
    }

    // MARK: ASAuthorizationControllerDelegate

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // This is the identity token (a JWT string)
            if let identityTokenData = appleIDCredential.identityToken,
               let identityToken = String(data: identityTokenData, encoding: .utf8) {
                completion?(identityToken, nil)
            } else {
                completion?(nil, NSError(domain: "AppleSignInErrorDomain", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Failed to obtain identity token."]))
            }
        }
    }

    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        completion?(nil, error)
    }

    // MARK: ASAuthorizationControllerPresentationContextProviding

    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first { $0.isKeyWindow }!
    }
}
