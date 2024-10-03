//
//  CrashlyticsErrorLogging.swift
//  FirebaseStaticInjections
//
//  Created by Qiang Huang on 9/2/19.
//  Copyright © 2019 dYdX. All rights reserved.
//

import FirebaseCrashlytics
import ParticlesKit
import Utilities

public class CrashlyticsErrorLogging: NSObject & ErrorLoggingProtocol {
    public func log(_ error: Error?) {
        if let error = error {
            let errorText = "Error Logging \(error)"
            Console.shared.log(errorText)
            Crashlytics.crashlytics().record(error: error)
        }
    }

    public func e(tag: String, message: String) {
        Crashlytics.crashlytics().record(error: NSError(domain: tag, code: 0, userInfo: [NSLocalizedDescriptionKey: message]))
    }

    public func d(tag: String, message: String) {
        // Do nothing
    }

}
