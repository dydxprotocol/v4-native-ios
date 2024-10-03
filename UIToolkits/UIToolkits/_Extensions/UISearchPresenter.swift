//
//  UISearchPresenter.swift
//  UIToolkits
//
//  Created by Qiang Huang on 11/2/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import UIKit
import Utilities

@objc open class UISearchPresenter: NSObject, SearchUIProtocol {
    @IBInspectable var xib: String?

    @IBOutlet open dynamic var searchButton: UIBarButtonItem? {
        didSet {
            if searchButton !== oldValue {
                oldValue?.removeTarget()
                searchButton?.addTarget(self, action: #selector(search(_:)))
            }
        }
    }

    @IBOutlet open dynamic var cancelSearchButton: UIBarButtonItem? {
        didSet {
            if cancelSearchButton !== oldValue {
                oldValue?.removeTarget()
                cancelSearchButton?.addTarget(self, action: #selector(cancelSearch(_:)))
            }
        }
    }

    @IBOutlet open dynamic var searchSaveButton: ButtonProtocol? {
        didSet {
            if searchSaveButton !== oldValue {
                oldValue?.removeTarget()
                searchSaveButton?.addTarget(self, action: #selector(saveSearch(_:)))
            }
        }
    }

    @IBOutlet open dynamic var searchDoneButton: ButtonProtocol? {
        didSet {
            if searchDoneButton !== oldValue {
                oldValue?.removeTarget()
                searchDoneButton?.addTarget(self, action: #selector(doneSearch(_:)))
            }
        }
    }

    @IBOutlet open dynamic var searchView: UIView?

    @IBOutlet open dynamic var searchBar: UISearchBar? {
        didSet {
            if searchBar !== oldValue {
                oldValue?.delegate = nil
                searchBar?.delegate = self
            }
        }
    }

    @objc open dynamic var isSearching: Bool = false {
        didSet {
            if isSearching != oldValue {
                searchingChanged()
            }
        }
    }

    @objc open dynamic var searchText: String?

    @objc open func searchingChanged() {
        if isSearching {
            searchBar?.becomeFirstResponder()
            searchText = searchBar?.text
        } else {
            searchBar?.resignFirstResponder()
            searchText = nil
        }
    }

    @objc open func searchTextChanged() {
    }

    @IBAction open func search(_ sender: Any?) {
        isSearching = true
    }

    @IBAction open func cancelSearch(_ sender: Any?) {
        isSearching = false
    }

    @IBAction open func saveSearch(_ sender: Any?) {
    }

    @IBAction open func doneSearch(_ sender: Any?) {
        searchBar?.resignFirstResponder()
    }
}

extension UISearchPresenter: UISearchBarDelegate {
    open func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        isSearching = true
        return true
    }

    open func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearching = false
    }

    open func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
    }

    open func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
    }

    open func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
