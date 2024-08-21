//
//  SearchViewController.swift
//  PresenterLib
//
//  Created by Qiang Huang on 10/27/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import ParticlesKit
import RoutingKit
import UIKit
import UIToolkits
import Utilities

open class SearchViewController: ListPresenterViewController {
    public var savedSearchManager: SavedSearchesProtocol? {
        didSet {
            changeObservation(from: oldValue, to: savedSearchManager, keyPath: #keyPath(SavedSearchesProtocol.savedSearches)) { [weak self] _, _, _, _ in
                self?.configureSearchBar()
            }
        }
    }

    @IBOutlet public var viewButton: ButtonProtocol?
    @IBOutlet public var filtersButton: ButtonProtocol? {
        didSet {
            if filtersButton !== oldValue {
                oldValue?.removeTarget()
                filtersButton?.addTarget(self, action: #selector(filters(_:)))
            }
        }
    }

    @IBOutlet public var likesButton: ButtonProtocol? {
        didSet {
            if likesButton !== oldValue {
                oldValue?.removeTarget()
                likesButton?.addTarget(self, action: #selector(likes(_:)))
            }
        }
    }

    open var leftButtons: [UIBarButtonItem]? {
        return nil
    }

    open var rightButtons: [UIBarButtonItem]? {
        var buttons = [UIBarButtonItem]()
        if isSearching == true {
            if let searchDoneButton = searchDoneButton as? UIBarButtonItem {
                buttons.append(searchDoneButton)
            }
            if let searchSaveButton = searchSaveButton as? UIBarButtonItem {
                buttons.append(searchSaveButton)
            }
        } else {
            if let viewButton = viewButton as? UIBarButtonItem {
                buttons.append(viewButton)
            }
            if let likesButton = likesButton as? UIBarButtonItem {
                buttons.append(likesButton)
            }
            if let filtersButton = filtersButton as? UIBarButtonItem {
                buttons.append(filtersButton)
            }
        }
        return buttons
    }

    var leftBarButtonItems: [UIBarButtonItem]? {
        didSet {
            navigationItem.leftBarButtonItems = leftBarButtonItems
        }
    }

    var rightBarButtonItems: [UIBarButtonItem]? {
        didSet {
            navigationItem.rightBarButtonItems = rightBarButtonItems
        }
    }
    
    open var titleView: UIView? {
        return searchView
    }

    public var onlyShowLiked: Bool {
        get {
            return (presenterManager?.listInteractor as? FilteredListInteractorProtocol)?.onlyShowLiked ?? false
        }
        set {
            (presenterManager?.listInteractor as? FilteredListInteractorProtocol)?.onlyShowLiked = newValue
            self.updateLikedButton()
        }
    }

    open var filtersRoute: String? { return nil }

    override open func viewDidLoad() {
        super.viewDidLoad()
        isSearching = false
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateLikedButton()
        updateFiltersButton()
        searchingChanged(animated: false)
    }

    @IBAction func filters(_ sender: Any?) {
        if let filtersRoute = filtersRoute {
            Router.shared?.navigate(to: RoutingRequest(path: filtersRoute), animated: true, completion: nil)
        }
    }
    
    open override func searchingChanged(animated: Bool) {
        super.searchingChanged(animated: animated)
        leftBarButtonItems = leftButtons
        rightBarButtonItems = rightButtons
        navigationItem.titleView = titleView
    }

    @IBAction func likes(_ sender: Any?) {
        onlyShowLiked = !onlyShowLiked
    }

    @IBAction override open func saveSearch(_ sender: Any?) {
        PrompterFactory.shared?.textPrompter().prompt(title: "Save Search", message: "Enter a name", text: nil, placeholder: nil, completion: { [weak self] text, ok in
            if let self = self, ok {
                self.searchBar?.resignFirstResponder()
                if let text = text, let filteredInteractor = self.presenterManager?.listInteractor as? FilteredListInteractorProtocol {
                    self.savedSearchManager?.add(name: text, search: filteredInteractor.filterText, filters: filteredInteractor.filters?.data)
                }
            }
        })
    }

    override open func configureSearchBar() {
        super.configureSearchBar()
        #if _iOS
            searchBar?.showsBookmarkButton = (savedSearchManager?.savedSearches?.count != 0)
        #endif
    }

    open func updateLikedButton() {
        let imageName = onlyShowLiked ? "action_liked" : "action_like"
        likesButton?.buttonImage = UIImage.named(imageName, bundles: Bundle.particles)
    }

    open func updateFiltersButton() {
        let data = (presenterManager?.listInteractor as? FilteredListInteractorProtocol)?.filters?.data
        let filtersCount = data?.count ?? 0
        let imageName = filtersCount > 0 ? "view_filters_on" : "view_filters"
        filtersButton?.buttonImage = UIImage.named(imageName, bundles: Bundle.particles)
//        filtersButton?.pp_addBadge(withNumber: filtersCount)
    }

    override open func searchTextChanged() {
        super.searchTextChanged()
        (presenterManager?.listInteractor as? FilteredListInteractorProtocol)?.filterText = searchText?.trim()
    }
}
