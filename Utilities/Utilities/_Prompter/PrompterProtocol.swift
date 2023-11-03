//
//  PrompterProtocol.swift
//  Utilities
//
//  Created by Qiang Huang on 7/18/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import Foundation

public enum PrompterActionStyle {
    case normal
    case cancel
    case destructive
}

public enum PrompterStyle {
    case error
    case selection
}

public typealias PrompterSelection = () -> Void

open class PrompterAction: NSObject {
    public var title: String?
    public var style: PrompterActionStyle = .normal
    public var enabled: Bool = true
    public var selection: PrompterSelection?

    public static func cancel(title: String? = "Cancel", selection: PrompterSelection? = nil) -> PrompterAction {
        return PrompterAction(title: title, style: .cancel, selection: selection)
    }

    public init(title: String?, style: PrompterActionStyle = .normal, enabled: Bool = true, selection: PrompterSelection? = nil) {
        self.title = title
        self.style = style
        self.enabled = enabled
        self.selection = selection
    }
}

public protocol PrompterProtocol: NSObjectProtocol {
    var title: String? { get set }
    var message: String? { get set }
    var style: PrompterStyle { get set }
    func set(title: String?, message: String?, style: PrompterStyle)
    func prompt(_ actions: [PrompterAction])
    func dismiss()
}

public typealias TextEntrySelection = (_ text: String?, _ ok: Bool) -> Void

public protocol TextPrompterProtocol: PrompterProtocol {
    var placeholder: String? { get set }
    var text: String? { get set }

    func prompt(title: String?, message: String?, text: String?, placeholder: String?, completion: @escaping TextEntrySelection)
}

public protocol PrompterFactoryProtocol: NSObjectProtocol {
    func prompter() -> PrompterProtocol
    func textPrompter() -> TextPrompterProtocol
}
