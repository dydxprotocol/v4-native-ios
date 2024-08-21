//
//  Debouncer+View.swift
//  UIToolkits
//
//  Created by Qiang Huang on 1/19/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import Utilities

public extension Debouncer {
    func layout(view: UIView?, animated: Bool, run: @escaping DebouncedFunction) {
        if animated {
            if let handler = debounce() {
                handler.run({
                    run()
                    handler.run({
                        UIView.animate(withDuration: UIView.defaultAnimationDuration) {
                            view?.layoutIfNeeded()
                        }
                    }, delay: nil)
                }, delay: nil)
            }
        } else {
            run()
        }
    }
}
