//
//  TableViewListPresenter.swift
//  PresenterLib
//
//  Created by John Huang on 10/10/18.
//  Copyright © 2019 dYdX. All rights reserved.
//

import Differ
import ParticlesKit
import UIKit
import UIToolkits
import Utilities

open class TableViewListPresenter: XibListPresenter, UITableViewDataSource, UITableViewDelegate, ScrollingProtocol {
    @IBInspectable @objc public dynamic var upsideDown: Bool = false {
        didSet {
            if upsideDown != oldValue {
                orientTableView()
            }
        }
    }

    @IBInspectable @objc public dynamic var autoScroll: Bool = false
    @objc public dynamic var isAtEnd: Bool = true
    @objc public dynamic var hasPendingUpdate: Bool = false
    @objc public dynamic var isScrolling: Bool = false {
        didSet {
            didSetIsScrolling(oldValue: oldValue)
        }
    }

    private var atEndDebouncer: Debouncer = Debouncer()

    @IBInspectable var parallax: Bool = false {
        didSet {
            tableViewXibRegister.parallax = parallax
        }
    }

    override open var selectionHandler: SelectionHandlerProtocol? {
        didSet {
            if selectionHandler !== oldValue {
                for section in sections {
                    section.tableView = tableView
                    section.selectionHandler = selectionHandler
                }
            }
        }
    }

    @IBInspectable var pullDownToRefresh: Bool = false {
        didSet {
            if pullDownToRefresh != oldValue {
                refreshControl = pullDownToRefresh ? UIRefreshControl() : nil
            }
        }
    }

    open var refreshControl: UIRefreshControl? {
        didSet {
            if refreshControl !== oldValue {
                if let refreshControl = refreshControl {
                    refreshControl.addTarget(self, action: #selector(pullDownToRefresh(_:)), for: .valueChanged)
                }
                tableView?.refreshControl = refreshControl
            }
        }
    }

    @IBInspectable var disclosure: Bool = false {
        didSet {
            if let cells = tableView?.visibleCells {
                for cell in cells {
                    cell.accessoryType = accessory(for: cell)
                }
            }
        }
    }

    @IBInspectable public var cellBackgroundColor: UIColor?
    @IBInspectable var sectionHeaderXib: String?
    @IBInspectable var sectionFooterXib: String?
    @IBInspectable var headerXib: String?
    @IBInspectable var footerXib: String?
    @IBInspectable var intMode: Int {
        get { return mode.rawValue }
        set { mode = PresenterMode(rawValue: newValue) ?? .linear }
    }

    @IBInspectable var animatedChange: Bool = false {
        didSet {
            if animatedChange != oldValue {
                for section in sections {
                    section.animatedChange = animatedChange
                }
            }
        }
    }

    @IBInspectable var scrollToSelection: Bool = false {
        didSet {
            if scrollToSelection != oldValue {
                for section in sections {
                    section.scrollToSelection = scrollToSelection && visible
                }
            }
        }
    }

    override open var visible: Bool {
        didSet {
            if visible != oldValue {
                for section in sections {
                    section.scrollToSelection = scrollToSelection && visible
                }
            }
        }
    }

    @IBOutlet open var tableView: UITableView? {
        didSet {
            if tableView !== oldValue {
                oldValue?.dataSource = nil
                oldValue?.delegate = nil
                tableView?.dataSource = self
                tableView?.delegate = self
                tableViewXibRegister.tableView = tableView
                tableViewHeaderXibRegister.tableView = tableView
                for section in sections {
                    section.tableView = tableView
                    section.selectionHandler = selectionHandler
                }
                if interactor != nil {
                    refresh(animated: false) { [weak self] in
                        self?.updateCompleted(firstContent: true)
                    }
                }
                if let headerView: UIView = XibLoader.load(from: headerXib) {
                    headerView.autoresizingMask = .flexibleWidth
                    headerView.translatesAutoresizingMaskIntoConstraints = true
                    tableView?.tableHeaderView = headerView
                }
                if let footerView: UIView = XibLoader.load(from: footerXib) {
                    footerView.autoresizingMask = .flexibleWidth
                    footerView.translatesAutoresizingMaskIntoConstraints = true
                    tableView?.tableFooterView = footerView
                }
                tableView?.refreshControl = refreshControl
                tableView?.sectionHeaderTopPadding = 0
                orientTableView()
            }
        }
    }

    private var debouncer: Debouncer = Debouncer()

    public var mode: PresenterMode = .linear {
        didSet {
            if mode != oldValue {
                if let handler = updateDebouncer.debounce() {
                    handler.run({ [weak self] in
                        if let self = self {
                            self.current = self.pending
                            self.refresh(animated: true) { [weak self] in
                                self?.updateCompleted(firstContent: false)
                            }
                        }
                    }, delay: nil)
                }
            }
        }
    }

    private var tableViewXibRegister: TableViewXibRegister = TableViewXibRegister()
    private var tableViewHeaderXibRegister: TableViewHeaderXibRegister = TableViewHeaderXibRegister()
    
    open var sections: [TableViewSectionListPresenter] = []

    override open var title: String? {
        return "List"
    }

    override open var icon: UIImage? {
        return UIImage.named("view_list", bundles: Bundle.particles)
    }

    override open func didSetInteractor(oldValue: ListInteractor?) {
        super.didSetInteractor(oldValue: oldValue)

        if interactor != oldValue {
            switch mode {
            case .linear:
                sections.removeAll()
                if let interactor = interactor {
                    sections.append(section(for: interactor, index: 0))
                }
                refresh(animated: true) { [weak self] in
                    self?.updateCompleted(firstContent: true)
                }

            case .sections:
                break
            }
        }
    }

    internal func section(for interactor: ListInteractor, index: Int) -> TableViewSectionListPresenter {
        let section = self.section(with: interactor) ?? TableViewSectionListPresenter()
        if section.xibRegister !== tableViewXibRegister {
            section.xibRegister = tableViewXibRegister
        }
        if section.headerXibRegister !== tableViewHeaderXibRegister {
            section.headerXibRegister = tableViewHeaderXibRegister
        }
        if section.xibMap != xibMap {
            section.xibMap = xibMap
        }
        if section.sequence != index {
            section.sequence = index
        }
        if section.selectionHandler !== selectionHandler {
            section.selectionHandler = selectionHandler
        }
        if section.sectionHeaderXib != sectionHeaderXib {
            section.sectionHeaderXib = sectionHeaderXib
        }
        if section.sectionFooterXib != sectionFooterXib {
            section.sectionFooterXib = sectionFooterXib
        }
        section.animatedChange = animatedChange
        section.scrollToSelection = scrollToSelection
        section.autoScroll = autoScroll
        if section.tableView !== tableView {
            section.tableView = tableView
        }
        if section.interactor !== interactor {
            section.interactor = interactor
        }
        return section
    }

    internal func section(with interactor: ListInteractor) -> TableViewSectionListPresenter? {
        return sections.first(where: { (presenter) -> Bool in
            presenter.interactor === interactor
        })
    }

    open func object(indexPath: IndexPath) -> ModelObjectProtocol? {
        switch mode {
        case .linear:
            return sections.first?.object(at: indexPath.row)

        case .sections:
            return sections.at(indexPath.section)?.object(at: indexPath.row)
        }
    }

    override open func refresh(animated: Bool, completion: (() -> Void)?) {
        switch mode {
        case .sections:
            if let list = current as? [ListInteractor] {
                var index = 0
                sections = list.map({ (child: ListInteractor) -> TableViewSectionListPresenter in
                    let tableSection = section(for: child, index: index)
                    index += 1
                    return tableSection
                })
            } else {
                sections = []
            }

        case .linear:
            sections.first?.current = current
        }

        refreshControl?.endRefreshing()
        UIView.animate(tableView, type: animated ? .fade : .none, direction: .none, duration: UIView.defaultAnimationDuration, animations: { [weak self] in
            if let self = self {
                self.tableView?.reloadData()
                if self.autoScroll {
                    self.scrollToEnd(animated: false)
                }
                completion?()
            }
        }, completion: nil)
    }

    open func numberOfSections(in tableView: UITableView) -> Int {
        if interactor == nil {
            return 0
        } else {
            return mode == .sections ? sections.count : 1
        }
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if mode == .sections {
            let sectionPresenter = sections[section]
            return sectionPresenter.count ?? 0
        } else {
            return sections.first?.count ?? 0
        }
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let section = (mode == .sections) ? sections[indexPath.section] : sections.first {
            let cell = section.cell(indexPath: indexPath) ?? UITableViewCell()
            if tableView.estimatedRowHeight <= 0 {
                tableView.estimatedRowHeight = cell.frame.size.height
            }
            cell.accessoryType = accessory(for: cell)
            if let cellBackgroundColor = cellBackgroundColor {
                cell.backgroundColor = cellBackgroundColor
            }
            if ((cell as? ObjectPresenterTableViewCell)?.presenterView as? ObjectPresenterProtocol)?.selectable ?? false {
                cell.selectionStyle = tableView.allowsMultipleSelection ? .none : .default
            } else {
                cell.selectionStyle = .none
            }
            return cell
        } else {
            return UITableViewCell()
        }
    }

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            UserInteraction.shared.sender = cell
        }
        if let section = (mode == .sections) ? sections[indexPath.section] : sections.first {
            section.select(to: indexPath)
        }
    }

    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let section = (mode == .sections && indexPath.section < sections.count) ? sections[indexPath.section] : sections.first {
            section.deselect(indexPath: indexPath)
        }
    }

    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    open func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
//        if let section = (mode == .sections && indexPath.section < sections.count) ? sections[indexPath.section] : sections.first {
//            if let size = section.defaultSize(at: indexPath.row) {
//                return size.height
//            }
//        }
//        return 44
    }

    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let tableSection = (mode == .sections) ? sections[section] : sections.first {
            return tableSection.headerViewSize() ?? defaultSize(xib: tableSection.sectionHeaderXib)?.height ?? 0
        }
        return CGFloat.leastNormalMagnitude
    }

    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let tableSection = (mode == .sections) ? sections[section] : sections.first {
            return tableSection.headerView() ?? accessoryView(xib: tableSection.sectionHeaderXib, section: section)
        }
        return nil
    }

    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let tableSection = (mode == .sections) ? sections[section] : sections.first {
            if let footerView = tableSection.footerView() {
                return footerView.frame.size.height
            } else if let size = defaultSize(xib: tableSection.sectionFooterXib) {
                return size.height
            }
        }
        return CGFloat.leastNormalMagnitude
    }

    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let tableSection = (mode == .sections) ? sections[section] : sections.first {
            return tableSection.footerView() ?? accessoryView(xib: tableSection.sectionFooterXib, section: section)
        }
        return nil
    }

    open func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    open func accessoryView(xib: String?, section: Int) -> UIView? {
        if let view: UIView = XibLoader.load(from: xib) {
            if let presenterView: ObjectPresenterView = view as? ObjectPresenterView {
                if mode == .linear {
                    presenterView.model = interactor?.parent
                } else {
                    presenterView.model = object(at: section)
                }
            }
            return view
        }
        return nil
    }

    open func accessory(for cell: UITableViewCell) -> UITableViewCell.AccessoryType {
        return showDisclosure(cell: cell) ? .disclosureIndicator : .none
    }

    open func showDisclosure(cell: UITableViewCell) -> Bool {
        if let presentingCell = cell as? ObjectPresenterTableViewCell {
            return presentingCell.showDisclosure ?? disclosure
        }
        return disclosure
    }

    private func didSetIsScrolling(oldValue: Bool) {
        if isScrolling != oldValue {
            Console.shared.log(isScrolling ? "TableView scrolling" : "TableView not scrolling")
            if !isScrolling && hasPendingUpdate {
                hasPendingUpdate = false
                update()
            }
        }
    }

    override open func update() {
        if tableView != nil {
            if isScrolling {
                hasPendingUpdate = true
            } else {
                let firstContent = (current == nil)
                if mode == .sections {
                    current = pending
                    refresh(animated: true) { [weak self] in
                        self?.updateCompleted(firstContent: firstContent)
                    }
                } else {
                    update(move: true)
                    updateCompleted(firstContent: firstContent)
                }
            }
        } else {
            current = pending
        }
    }

    override open func update(diff: Diff, patches: [Patch<ModelObjectProtocol>], current: [ModelObjectProtocol]?) {
        tableView?.performBatchUpdates({
            for change in patches {
                switch change {
                case let .deletion(index):
                    tableView?.deleteSections(IndexSet(integer: index), with: .fade)

                case let .insertion(index: index, element: _):
                    tableView?.insertSections(IndexSet(integer: index), with: .fade)
                }
            }
        }, completion: nil)
    }

    override open func updateLayout() {
        if let handler = debouncer.debounce() {
            handler.run({ [weak self] in
                if let self = self {
                    self.tableView?.beginUpdates()
                    self.tableView?.endUpdates()
                    Console.shared.log("endUpdate/updateLayout")
                }
            }, delay: 0.5)
        }
    }

    @objc open func pullDownToRefresh(_ sender: Any?) {
    }

    override open func changed(selected: [ModelObjectProtocol]?) {
        if let tableSection = (mode == .sections) ? nil : sections.first {
            tableSection.changed(selected: selected)
        }
    }

    override open func visibleIndice() -> [Int]? {
        if let indexPaths = tableView?.indexPathsForVisibleRows, indexPaths.count > 0 {
            var indice = [Int]()
            for indexPath in indexPaths {
                if mode == .sections {
                    if !indice.contains(indexPath.section) {
                        indice.append(indexPath.section)
                    }
                } else {
                    indice.append(indexPath.row)
                }
            }
            return indice
        }
        return nil
    }

    override open func selectScrollTo(index: Int, completion: @escaping () -> Void) {
        if mode == .sections {
            tableView?.scrollToRow(at: IndexPath(row: NSNotFound, section: index), at: .top, animated: true)
        } else {
            tableView?.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: true)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + UIView.defaultAnimationDuration) {
            completion()
        }
    }
}

extension TableViewListPresenter {
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if upsideDown {
            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        }
        if parallax {
            (cell as? ParallaxObjectPresenterTableViewCell)?.parallax(animated: true)
        }
    }

    private func lastIndexPath() -> IndexPath? {
        if let lastIndex = sections.lastIndex(where: { (section) -> Bool in
            (section.current?.count ?? 0) > 0
        }), let last = sections.at(lastIndex), let count = last.current?.count, count > 0 {
            return IndexPath(item: count - 1, section: lastIndex)
        } else {
            return nil
        }
    }

    public func isTableAtEnd() -> Bool {
        if let indexPath = lastIndexPath() {
            if let visible = tableView?.indexPathsForVisibleRows {
                return visible.contains(indexPath)
            }
        }
        return true
    }

    public func scrollToEnd(animated: Bool) {
        if animated {
            DispatchQueue.main.async { [weak self] in
                if let self = self {
                    if let indexPath = self.lastIndexPath() {
                        self.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: animated)
                    }
                }
            }
        } else {
            if let indexPath = lastIndexPath() {
                tableView?.scrollToRow(at: indexPath, at: .bottom, animated: animated)
                scrollToEnd(animated: true)
            }
        }
    }
}

extension TableViewListPresenter: UIScrollViewDelegate {
    private func calculateAtEnd() {
//        let handler = atEndDebouncer.debounce()
//        handler?.run({ [weak self] in
//            if let self = self {
//                self.isAtEnd = self.isTableAtEnd()
//            }
//        }, delay: 0.25)
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if parallax {
            if let visibleCells = tableView?.visibleCells {
                for cell in visibleCells {
                    (cell as? ParallaxObjectPresenterTableViewCell)?.parallax(animated: true)
                }
            }
        }
        calculateAtEnd()
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        calculateAtEnd()
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isScrolling = true
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        calculateAtEnd()
        if !decelerate { scrollViewDidEndScrolling(scrollView) }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        calculateAtEnd()
        selectCurrent()
        scrollViewDidEndScrolling(scrollView)
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        calculateAtEnd()
        selectCurrent()
        scrollViewDidEndScrolling(scrollView)
    }

    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        calculateAtEnd()
    }

    public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        calculateAtEnd()
    }

    public func scrollViewDidEndScrolling(_ scrollView: UIScrollView) {
        isScrolling = false
    }

    private func orientTableView() {
        if upsideDown {
            tableView?.transform = CGAffineTransform(scaleX: 1, y: -1)
        }
    }
}
