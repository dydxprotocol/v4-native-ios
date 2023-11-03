//
//  Bundle+UIBundle.swift
//  Utilities
//
//  Created by John Huang on 10/27/18.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Foundation

#if _macOS
    extension Bundle {
        open func loadNibNamed(_ name: String, owner: Any?, options: [Any]? = nil) -> [Any]? {
            var nibContents: NSArray?
            if Bundle.ui().loadNibNamed(name, owner: owner, topLevelObjects: &nibContents) {
                return nibContents as? [Any]
            }
            return nil
        }
    }
#endif

public extension Bundle {
    @objc static var particles: [Bundle] = {
        var bundles = [Bundle]()
        bundles.append(Bundle.main)
        if let json = JsonLoader.load(bundle: Bundle.main, fileName: "ui.json") as? [String] {
            let names = json.map({ (name) -> String in
                name.lowercased()
            })
            let set = Set(names)
            var map = [String: Bundle]()
            let frameworks = Bundle.allFrameworks
            for framework in frameworks {
                let name = framework.bundlePath.lastPathComponent.stringByDeletingPathExtension.lowercased()
                if set.contains(name) {
                    map[name] = framework
                }
            }
            var uiBundle: Bundle?
            for name in names {
                if let bundle = map[name] {
                    bundles.append(bundle)
                    if uiBundle == nil {
                        uiBundle = bundle
                    }
                }
            }
            if let downloaded = downloaded(bundle: uiBundle) {
                bundles.append(downloaded)
            }
        }
        return bundles
    }()
    
    @objc static func load(xib name: String, owner: Any?, options: [UINib.OptionsKey : Any]? = nil) -> [Any]? {
        var result: [Any]? = nil
        for bundle in particles {
            result = bundle.safeLoad(xib: name, owner: owner, options: options)
        }
        return result
    }

    @objc class func downloaded(bundle: Bundle?) -> Bundle? {
        if let bundleName = bundle?.bundlePath.lastPathComponent.stringByDeletingPathExtension, let document = FolderService.shared?.documents() {
            let bundlePath = URL(fileURLWithPath: document).appendingPathComponent(bundleName).absoluteString
            return Bundle(path: bundlePath)
        }
        return nil
    }
}

public extension Bundle {
    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
            object(forInfoDictionaryKey: "CFBundleName") as? String
    }

    @objc func safeLoad(xib: String, owner: Any? = nil, options: [UINib.OptionsKey : Any]? = nil) -> [Any]? {
        let file = path(forResource: xib, ofType: "nib")
        if File.exists(file) {
            return loadNibNamed(xib, owner: owner, options: options)
        }
        return nil
    }
}

public extension Bundle {
    var version: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var build: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
    
    var versionAndBuild: String? {
        if let version = version {
            if let build = build {
                return "\(version).\(build)"
            } else {
                return version
            }
        }
        return nil
    }

    var versionPretty: String? {
        if let version = version {
            return "v\(version)"
        }
        return nil
    }
    
    func versionCompare(otherVersion: String) -> ComparisonResult {
        guard let version = version else {
            return .orderedAscending
        }

        let versionDelimiter = "."

        var versionComponents = version.components(separatedBy: versionDelimiter) // <1>
        var otherVersionComponents = otherVersion.components(separatedBy: versionDelimiter)

        let zeroDiff = versionComponents.count - otherVersionComponents.count // <2>

        if zeroDiff == 0 { // <3>
            // Same format, compare normally
            return version.compare(otherVersion, options: .numeric)
        } else {
            let zeros = Array(repeating: "0", count: abs(zeroDiff)) // <4>
            if zeroDiff > 0 {
                otherVersionComponents.append(contentsOf: zeros) // <5>
            } else {
                versionComponents.append(contentsOf: zeros)
            }
            return versionComponents.joined(separator: versionDelimiter)
                .compare(otherVersionComponents.joined(separator: versionDelimiter), options: .numeric) // <6>
        }
    }
}
