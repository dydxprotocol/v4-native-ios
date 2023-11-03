//
//  UISearchBar+Icons.swift
//  UIToolkits
//
//  Created by Qiang Huang on 10/30/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import UIKit

public extension UISearchBar {
    #if _iOS
        var bookmarkIcon: UIImage? {
            get { return image(for: .bookmark, state: .normal) }
            set { setImage(newValue, for: .bookmark, state: .normal) }
        }

        var clearIcon: UIImage? {
            get { return image(for: .clear, state: .normal) }
            set { setImage(newValue, for: .clear, state: .normal) }
        }

        var resultsIcon: UIImage? {
            get { return image(for: .resultsList, state: .normal) }
            set { setImage(newValue, for: .resultsList, state: .normal) }
        }
    #endif

    var searchIcon: UIImage? {
        get { return image(for: .search, state: .normal) }
        set { setImage(newValue, for: .search, state: .normal) }
    }
}
