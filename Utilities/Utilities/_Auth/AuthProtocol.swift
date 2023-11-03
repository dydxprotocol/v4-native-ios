//
//  AuthProtocol.swift
//  Utilities
//
//  Created by Qiang Huang on 9/15/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import Foundation

public typealias AuthCompletionBlock = (_ succeeded: Bool) -> Void
public typealias AuthAttachmentCompletionBlock = (_ succeeded: Bool) -> Void
public typealias TokenCompletionBlock = (_ token: String?, _ refreshToken: String?, _ provider: String?) -> Void

@objc public protocol AuthProviderAttachmentProtocol: NSObjectProtocol {
    func beforeLogin(completion: @escaping AuthAttachmentCompletionBlock)
    func afterLogin()
    func beforeLogout(token: String, completion: @escaping AuthAttachmentCompletionBlock)
    func afterLogout()
}

@objc public protocol AuthProviderProtocol: NSObjectProtocol {
    @objc var token: String? { get }
    var name: String? { get }
    var loginXib: String? { get }
    var logoutXib: String? { get }
    var attachments: [AuthProviderAttachmentProtocol]? { get set }
    func token(completion: @escaping TokenCompletionBlock)
    func reallyLogin(completion: @escaping AuthCompletionBlock)
    func reallyLogout(completion: @escaping AuthCompletionBlock)
}

public extension AuthProviderProtocol {
    func add(attachment: AuthProviderAttachmentProtocol) {
        if attachments == nil {
            attachments = [AuthProviderAttachmentProtocol]()
        }
        attachments?.append(attachment)
    }

    func login(completion: @escaping AuthCompletionBlock) {
        beforeLogin(index: 0) { [weak self] succeeded in
            if let self = self, succeeded {
                self.reallyLogin { [weak self] successful in
                    if successful {
                        self?.afterLogin()
                    }
                    completion(successful)
                }
            }
        }
    }

    func attachment(at index: Int) -> AuthProviderAttachmentProtocol? {
        if index < attachments?.count ?? 0 {
            return attachments?[index]
        }
        return nil
    }

    func beforeLogin(index: Int, completion: @escaping AuthAttachmentCompletionBlock) {
        if let attachment = self.attachment(at: index) {
            attachment.beforeLogin { [weak self] succeeded in
                if let self = self, succeeded {
                    self.beforeLogin(index: index + 1, completion: completion)
                }
            }
        } else {
            completion(true)
        }
    }

    func afterLogin() {
        if let attachments = attachments {
            for attachment in attachments {
                attachment.afterLogin()
            }
        }
    }

    func logout(token: String, completion: @escaping AuthCompletionBlock) {
        beforeLogout(token: token, index: 0) { [weak self] _ in
            if let self = self {
                self.reallyLogout(completion: completion)
            }
        }
    }

    func beforeLogout(token: String, index: Int, completion: @escaping AuthAttachmentCompletionBlock) {
        if let attachment = self.attachment(at: index) {
            attachment.beforeLogout(token: token) { [weak self] succeeded in
                if let self = self, succeeded {
                    self.beforeLogout(token: token, index: index + 1, completion: completion)
                }
            }
        } else {
            reallyLogout { [weak self] successful in
                if successful {
                    self?.afterLogout()
                }
                completion(successful)
            }
        }
    }

    func afterLogout() {
        if let attachments = attachments {
            for attachment in attachments {
                attachment.afterLogout()
            }
        }
    }
}
