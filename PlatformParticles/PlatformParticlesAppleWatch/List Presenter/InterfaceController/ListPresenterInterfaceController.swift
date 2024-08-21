//
//  ListPresenterInterfaceController.swift
//  PlatformParticlesAppleWatch
//
//  Created by Qiang Huang on 12/9/18.
//  Copyright © 2018 dYdX. All rights reserved.
//

import ParticlesKit
import PlatformRouting

open class ListPresenterInterfaceController: RoutingInterfaceController {
    open var interactor: ListInteractor? {
        didSet {
            if interactor !== oldValue {
                presenter?.interactor = interactor
            }
        }
    }

    open var presenter: TableViewListPresenter? {
        didSet {
            if presenter !== oldValue {
                presenter?.interactor = interactor
            }
        }
    }

    open override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        if table === presenter?.tableView {
            presenter?.select(index: rowIndex, completion: nil)
        }
    }
}
