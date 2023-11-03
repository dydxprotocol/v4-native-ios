//
//  UIViewController+App.swift
//  UIAppToolkits
//
//  Created by Qiang Huang on 1/25/20.
//  Copyright © 2020 dYdX. All rights reserved.
//

import PanModal
import UIKit

public extension UIViewController {
    func bringEditingToView() {
        if let textInput = UIResponder.current as? (UIView & UITextInput) {
            if let cell: UITableViewCell = textInput.parent(), let tableView: UITableView = cell.parent(), let indexPath = tableView.indexPath(for: cell) {
                tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }

    func scrollToTop() {
        func scrollToTop(view: UIView?) -> Bool {
            if let view = view {
                if let tableView = view as? UITableView {
                    if hasData(tableView: tableView) {
                        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                        return true
                    } else {
                        return false
                    }
                } else {
                    var scrolled = false
                    for subView in view.subviews {
                        if !scrolled {
                            scrolled = scrollToTop(view: subView)
                        }
                    }
                    return scrolled
                }
            } else {
                return false
            }
        }

        _ = scrollToTop(view: view)
    }

    func hasData(tableView: UITableView?) -> Bool {
        if let tableView = tableView, let dataSource = tableView.dataSource {
            if (dataSource.numberOfSections?(in: tableView) ?? 1) >= 1 {
                return dataSource.tableView(tableView, numberOfRowsInSection: 0) >= 1
            }
        }
        return false
    }
}
