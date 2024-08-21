//
//  UIViewController+Search.swift
//  UIToolkits
//
//  Created by Qiang Huang on 8/29/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import UIKit
import Utilities

@objc public protocol SearchUIProtocol {
    var searchButton: UIBarButtonItem? { get set }
    var cancelSearchButton: UIBarButtonItem? { get set }
    var searchView: UIView? { get set }
    var searchBar: UISearchBar? { get set }
    var isSearching: Bool { get set }
    var searchText: String? { get set }

    func search(_ sender: Any?)
    func cancelSearch(_ sender: Any?)
}

extension UIViewController: SearchUIProtocol {
    private struct SearchKey {
        static var search = "viewController.search.search"
        static var cancel = "viewController.search.cancel"
        static var save = "viewController.search.save"
        static var done = "viewController.search.done"
        static var view = "viewController.search.view"
        static var bar = "viewController.search.bar"
        static var searching = "viewController.search.searching"
        static var text = "viewController.search.text"
    }

    @IBOutlet open var searchButton: UIBarButtonItem? {
        get {
            return associatedObject(base: self, key: &SearchKey.search)
        }
        set {
            let oldValue = searchButton
            if oldValue !== newValue {
                retainObject(base: self, key: &SearchKey.search, value: newValue)
                oldValue?.removeTarget()
                searchButton?.addTarget(self, action: #selector(search(_:)))
            }
        }
    }

    @IBOutlet open var cancelSearchButton: UIBarButtonItem? {
        get {
            return associatedObject(base: self, key: &SearchKey.cancel)
        }
        set {
            let oldValue = cancelSearchButton
            if oldValue !== newValue {
                retainObject(base: self, key: &SearchKey.cancel, value: newValue)
                oldValue?.removeTarget()
                cancelSearchButton?.addTarget(self, action: #selector(cancelSearch(_:)))
            }
        }
    }

    @IBOutlet open var searchSaveButton: ButtonProtocol? {
        get {
            return associatedObject(base: self, key: &SearchKey.save)
        }
        set {
            let oldValue = searchSaveButton
            if oldValue !== newValue {
                retainObject(base: self, key: &SearchKey.save, value: newValue)
                oldValue?.removeTarget()
                searchSaveButton?.addTarget(self, action: #selector(saveSearch(_:)))
            }
        }
    }

    @IBOutlet open var searchDoneButton: ButtonProtocol? {
        get {
            return associatedObject(base: self, key: &SearchKey.done)
        }
        set {
            let oldValue = searchDoneButton
            if oldValue !== newValue {
                retainObject(base: self, key: &SearchKey.done, value: newValue)
                oldValue?.removeTarget()
                searchDoneButton?.addTarget(self, action: #selector(doneSearch(_:)))
            }
        }
    }

    @IBOutlet open var searchView: UIView? {
        get {
            return associatedObject(base: self, key: &SearchKey.view)
        }
        set {
            let oldValue = searchButton
            if oldValue !== newValue {
                retainObject(base: self, key: &SearchKey.view, value: newValue)
            }
        }
    }

    @IBOutlet open var searchBar: UISearchBar? {
        get {
            return associatedObject(base: self, key: &SearchKey.bar)
        }
        set {
            let oldValue = searchButton
            if oldValue !== newValue {
                retainObject(base: self, key: &SearchKey.bar, value: newValue)
                searchBar?.delegate = self
                configureSearchBar()
            }
        }
    }

    private var _isSearching: NSNumber? {
        get {
            return associatedObject(base: self, key: &SearchKey.searching)
        }
        set {
            let oldValue = _isSearching
            if oldValue?.boolValue ?? false != newValue?.boolValue ?? false {
                retainObject(base: self, key: &SearchKey.searching, value: newValue)
            }
        }
    }

    open var isSearching: Bool {
        get {
            return _isSearching?.boolValue ?? false
        }
        set {
            let oldValue = isSearching
            if oldValue != newValue {
                _isSearching = NSNumber(booleanLiteral: newValue)
                searchingChanged(animated: true)
            }
        }
    }

    open var searchText: String? {
        get {
            return associatedObject(base: self, key: &SearchKey.text)
        }
        set {
            let oldValue = searchText
            if oldValue != newValue {
                retainObject(base: self, key: &SearchKey.text, value: newValue)
                searchTextChanged()
            }
        }
    }

    @objc open func searchingChanged(animated: Bool) {
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

    @objc @IBAction open func search(_ sender: Any?) {
        isSearching = true
    }

    @objc @IBAction open func cancelSearch(_ sender: Any?) {
        isSearching = false
    }

    @objc @IBAction open func saveSearch(_ sender: Any?) {
    }

    @objc @IBAction open func doneSearch(_ sender: Any?) {
        searchBar?.resignFirstResponder()
    }

    @objc open func configureSearchBar() {
        #if _iOS
            searchBar?.showsCancelButton = false
        #endif
        searchBar?.returnKeyType = .done
    }
}

extension UIViewController: UISearchBarDelegate {
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
