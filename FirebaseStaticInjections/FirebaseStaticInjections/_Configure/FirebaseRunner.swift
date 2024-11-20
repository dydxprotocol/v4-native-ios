//
//  FirebaseRunner.swift
//  FirebaseInjections
//
//  Created by Qiang Huang on 12/20/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import FirebaseCore
import FirebaseCrashlytics
import Utilities

public final class FirebaseRunner: NSObject {

    public let enabled: Bool

    public static var shared: FirebaseRunner?

    public init(optionsFile: String?) {
        if let optionsFile = optionsFile,
           let filePath = Bundle.main.path(forResource: optionsFile, ofType: "plist"),
           let options = FirebaseOptions(contentsOfFile: filePath),
           !options.googleAppID.isEmpty {
            // do not configure firebase if using placeholder config file, otherwise app will crash due to startup runtime exception
            FirebaseApp.configure(options: options)
            Console.shared.log("analytics log | Firebase initialized")
            FirebaseConfiguration.shared.setLoggerLevel(.min)
            enabled = true
        } else {
            NSLog("Unable to initialize Firebase for options file: \(optionsFile ?? "")")
            enabled = false
        }
        super.init()
    }
}
