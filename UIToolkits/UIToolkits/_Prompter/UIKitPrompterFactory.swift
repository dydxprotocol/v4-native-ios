//
//  UIKitPrompterFactory.swift
//  UIToolkits
//
//  Created by Qiang Huang on 6/1/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import Utilities

open class UIKitPrompterFactory: NSObject, PrompterFactoryProtocol {
    public func prompter() -> PrompterProtocol {
        return AlertPrompter()
    }

    public func textPrompter() -> TextPrompterProtocol {
        return TextEntryPrompter()
    }
}
