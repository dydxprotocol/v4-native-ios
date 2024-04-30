//
//  AbacusPresentationImp.swift
//  dydxStateManager
//
//  Created by Rui Huang on 30/04/2024.
//

import Foundation
import Abacus
import Utilities

final public class AbacusPresentationImp: NSObject, Abacus.PresentationProtocol {
    public func showToast(toast: Toast) {
        let type: EInfoType?
        switch toast.type {
        case ToastType.info:
            type = EInfoType.info
        case ToastType.warning:
            type = EInfoType.warning
        case ToastType.error:
            type = EInfoType.error
        default:
            type = nil
        }
        ErrorInfo.shared?.info(title: toast.title,
                               message: toast.text,
                               type: type,
                               error: nil)
    }
}
