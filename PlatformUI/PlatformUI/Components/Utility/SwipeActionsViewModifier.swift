//
//  SwipeActionsViewModifier.swift
//  PlatformUI
//
//  Created by Michael Maguire on 9/18/23.
//

import SwiftUI

public enum CellSwipeAccessoryPosition: Int {
    case left, right, both
}

public enum CellSwipeAccessoryVisibility: String {
    case showRight, showLeft, showNone
}

public struct CellSwipeAccessory {
    public let accessoryView: AnyView?
    public let action: (() -> Void)?
    public static let appearAnimation = Animation.easeOut(duration: 0.5)

    public init(
        accessoryView: AnyView?,
        action: (() -> Void)? = nil
    ) {
        self.accessoryView = accessoryView
        self.action = action
    }
}

struct SwipeActionsModifier: ViewModifier {
    @State var cellSwipeAccessoryPosition: CellSwipeAccessoryPosition
    let leftCellSwipeAccessory: CellSwipeAccessory?
    let rightCellSwipeAccessory: CellSwipeAccessory?

    @State var shouldResetStatusOnAppear = true

    @State var accessoryVisibility: CellSwipeAccessoryVisibility = .showNone

    @State var offset: CGFloat = 0.0

    @State var frameWidth: CGFloat = .greatestFiniteMagnitude
    @State var leftOffset: CGFloat = .leastNormalMagnitude
    @State var rightOffset: CGFloat = .greatestFiniteMagnitude
    @State var spaceWidth: CGFloat = 0

    let cellID = UUID()

    @State var currentCellID: UUID?
    @State var resetNotice = NotificationCenter.default.publisher(for: .cellSwipeAccessoryVisibilityReset)

    let cellSwipeAccessoryWidth: CGFloat = 60

    init(
        leftCellSwipeAccessory: CellSwipeAccessory?,
        rightCellSwipeAccessory: CellSwipeAccessory?
    ) {
        let cellSwipeAccessoryPosition: CellSwipeAccessoryPosition
        if leftCellSwipeAccessory != nil && rightCellSwipeAccessory == nil {
            cellSwipeAccessoryPosition = .left
        } else if leftCellSwipeAccessory == nil && rightCellSwipeAccessory != nil {
            cellSwipeAccessoryPosition = .right
        } else {
            cellSwipeAccessoryPosition = .both
        }
        _cellSwipeAccessoryPosition = State(wrappedValue: cellSwipeAccessoryPosition)
        self.leftCellSwipeAccessory = leftCellSwipeAccessory
        self.rightCellSwipeAccessory = rightCellSwipeAccessory
    }

    func accessoryView(accessory: CellSwipeAccessory, position: CellSwipeAccessoryPosition) -> some View {
        return Rectangle()
            .fill(Color.clear)
            .overlay(
                ZStack(alignment: position == .left ? .trailing : .leading) {
                    Color.clear
                    accessory.accessoryView
                        .contentShape(Rectangle())
                        .frame(width: cellSwipeAccessoryWidth)
                }
            )
            .contentShape(Rectangle())
            .onTapGesture {
                accessory.action?()
                resetStatus()
            }
    }

    @ViewBuilder func loadAccessory(_ accessory: CellSwipeAccessory, position: CellSwipeAccessoryPosition, frame: CGRect)
    -> some View {
        accessoryView(accessory: accessory, position: position)
            .offset(
                x: cellOffset(
                    position: position,
                    width: frame.width,
                    accessory: accessory
                )
            )
    }

    func cellOffset(
        position: CellSwipeAccessoryPosition,
        width: CGFloat,
        accessory: CellSwipeAccessory
    ) -> CGFloat {

        if frameWidth == .greatestFiniteMagnitude {
            DispatchQueue.main.async {
                frameWidth = width
            }
        }

        if position == .left {
            return -width + offset
        } else {
            return width + offset
        }

    }

    func resetAccessoryOffset(position: CellSwipeAccessoryPosition, accessory: CellSwipeAccessory?) {

        if position == .left {
            withAnimation(CellSwipeAccessory.appearAnimation) {
                leftOffset = -frameWidth
            }
        } else {
            withAnimation(CellSwipeAccessory.appearAnimation) {
                rightOffset = frameWidth
            }
        }
        return
    }

    func body(content: Content) -> some View {

        return ZStack(alignment: .topLeading) {
            Color.clear.zIndex(0)
            ZStack {

                GeometryReader { proxy in
                    ZStack {
                        if let accessory = leftCellSwipeAccessory {
                            loadAccessory(accessory, position: .left, frame: proxy.frame(in: .local))
                        }
                    }
                }.zIndex(1)
                GeometryReader { proxy in
                    ZStack {
                        if let accessory = rightCellSwipeAccessory {
                            loadAccessory(accessory, position: .right, frame: proxy.frame(in: .local))
                        }
                    }
                }.zIndex(2)

                ZStack(alignment: .center) {
                    Color.clear
                    content
                        .environment(\.cellSwipeAccessoryVisibility, accessoryVisibility)
                }
                .zIndex(3)
                .highPriorityGesture(
                    TapGesture(count: 1),
                    including: currentCellID == nil ? .subviews : .none
                )
                .contentShape(Rectangle())
//                .onTapGesture(
//                    count: currentCellID != nil ? 1 : 4,
//                    perform: {
//                        resetStatus()
//                        dismissNotification()
//                    }
//                )
                .offset(x: offset)
            }
        }
        .contentShape(Rectangle())
        .gesture(getGesture())
        .onAppear {
            // Always reset... otherwise, the onTapGesture above (commented out) causes
            // significant UI delay
            accessoryVisibility = .showNone
            shouldResetStatusOnAppear = true
            
            self.set(accessoryVisibility: accessoryVisibility)
            switch accessoryVisibility {
            case .showLeft:
                offset = cellSwipeAccessoryWidth
            case .showRight:
                offset = cellSwipeAccessoryWidth
            case .showNone:
                break
            }
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                if shouldResetStatusOnAppear {
                    resetStatus()
                }
            }
        }
        .clipShape(Rectangle())
        .onReceive(resetNotice) { notice in
            if cellID != notice.object as? UUID {
                resetStatus()
                currentCellID = notice.object as? UUID ?? nil
            }

        }
        .listRowInsets(EdgeInsets())

    }

    func set(accessoryVisibility: CellSwipeAccessoryVisibility) {
        self.accessoryVisibility = accessoryVisibility
    }

    func resetStatus() {
        accessoryVisibility = .showNone
        withAnimation(.easeInOut) {
            offset = 0
            leftOffset = -frameWidth
            rightOffset = frameWidth
            spaceWidth = 0
        }
        currentCellID = nil
        shouldResetStatusOnAppear = false
    }

    func dismissNotification() {
        NotificationCenter.default.post(name: .cellSwipeAccessoryVisibilityReset, object: nil)
    }

    func getGesture() -> _EndedGesture<_ChangedGesture<DragGesture>> {
        let minimumDistance: CGFloat
        if #available(iOS 18.0, *) {
            // 0 feels bad on iOS 18.0
            minimumDistance = 35
        } else {
            minimumDistance = 0
        }
        return DragGesture(minimumDistance: minimumDistance)
        .onChanged { value in
            var dragWidth = value.translation.width

            self.shouldResetStatusOnAppear = false

            if currentCellID != cellID {
                currentCellID = cellID
                NotificationCenter.default.post(Notification(name: .cellSwipeAccessoryVisibilityReset, object: cellID))
            }

            switch accessoryVisibility {

            case .showNone:
                if cellSwipeAccessoryPosition == .left { dragWidth = max(0, dragWidth) }
                if cellSwipeAccessoryPosition == .right { dragWidth = min(0, dragWidth) }

                if dragWidth > cellSwipeAccessoryWidth {
                    dragWidth = cellSwipeAccessoryWidth + dragWidth / 10
                }

                if dragWidth < -cellSwipeAccessoryWidth {
                    dragWidth = -cellSwipeAccessoryWidth + dragWidth / 10
                }

                withAnimation(.easeInOut) {
                    offset = dragWidth
                }
                resetAccessoryOffset(position: .left, accessory: leftCellSwipeAccessory)
                resetAccessoryOffset(position: .right, accessory: leftCellSwipeAccessory)

            case .showLeft:
                if dragWidth < 0 {
                    withAnimation(.easeInOut) {
                        offset = cellSwipeAccessoryWidth + max(dragWidth, -cellSwipeAccessoryWidth)
                        resetAccessoryOffset(position: .left, accessory: leftCellSwipeAccessory)
                        resetAccessoryOffset(position: .right, accessory: rightCellSwipeAccessory)
                    }
                } else {
                    withAnimation(.easeInOut) {
                        offset = cellSwipeAccessoryWidth + dragWidth / 10
                        resetAccessoryOffset(position: .left, accessory: leftCellSwipeAccessory)
                        resetAccessoryOffset(position: .right, accessory: rightCellSwipeAccessory)
                    }
                }
            case .showRight:
                if dragWidth > 0 {
                    withAnimation(.easeInOut) {
                        offset = -cellSwipeAccessoryWidth + min(dragWidth, cellSwipeAccessoryWidth)
                        resetAccessoryOffset(position: .left, accessory: leftCellSwipeAccessory)
                        resetAccessoryOffset(position: .right, accessory: rightCellSwipeAccessory)
                    }
                } else {
                    withAnimation(.easeInOut) {
                        offset = -cellSwipeAccessoryWidth + dragWidth / 10
                        resetAccessoryOffset(position: .left, accessory: leftCellSwipeAccessory)
                        resetAccessoryOffset(position: .right, accessory: rightCellSwipeAccessory)
                    }
                }
            }
        }
        .onEnded { value in
            if currentCellID != cellID {
                currentCellID = cellID
                NotificationCenter.default.post(Notification(name: .cellSwipeAccessoryVisibilityReset, object: cellID))
            }
            let dragWidth = value.translation.width

            let swipeCommitDistance: CGFloat = 30

            switch accessoryVisibility {
            case .showNone:
                if abs(dragWidth) < swipeCommitDistance {
                    resetStatus()
                    return
                }

                if (cellSwipeAccessoryPosition == .left || cellSwipeAccessoryPosition == .both) && dragWidth >= swipeCommitDistance {
                    withAnimation(CellSwipeAccessory.appearAnimation) {
                        offset = cellSwipeAccessoryWidth
                        resetAccessoryOffset(position: .left, accessory: leftCellSwipeAccessory)
                        resetAccessoryOffset(position: .right, accessory: rightCellSwipeAccessory)
                        set(accessoryVisibility: .showLeft)
                    }
                    return
                }

                if (cellSwipeAccessoryPosition == .right || cellSwipeAccessoryPosition == .both) && dragWidth <= -swipeCommitDistance {
                    withAnimation(CellSwipeAccessory.appearAnimation) {
                        offset = -cellSwipeAccessoryWidth
                        resetAccessoryOffset(position: .left, accessory: leftCellSwipeAccessory)
                        resetAccessoryOffset(position: .right, accessory: rightCellSwipeAccessory)
                        set(accessoryVisibility: .showRight)
                    }
                    return
                }

            case .showLeft:
                if dragWidth > -swipeCommitDistance {
                    withAnimation(CellSwipeAccessory.appearAnimation) {
                        offset = cellSwipeAccessoryWidth
                        resetAccessoryOffset(position: .left, accessory: leftCellSwipeAccessory)
                        resetAccessoryOffset(position: .right, accessory: rightCellSwipeAccessory)
                        set(accessoryVisibility: .showRight)
                    }
                } else {
                    resetStatus()
                }
            case .showRight:
                if dragWidth < swipeCommitDistance {
                    withAnimation(CellSwipeAccessory.appearAnimation) {
                        offset = -cellSwipeAccessoryWidth
                        resetAccessoryOffset(position: .left, accessory: leftCellSwipeAccessory)
                        resetAccessoryOffset(position: .right, accessory: rightCellSwipeAccessory)
                        set(accessoryVisibility: .showRight)
                    }
                } else {
                    resetStatus()
                }
            }
        }
    }
}

extension View {
    /// Similar to SwiftUI's `swipeActions`, this `swipeAction` modifier enables swipe actions for views which are not contained in a SwiftUI `List`
    /// - Parameters:
    ///   - leftCellSwipeAccessory: the specifications for the left swipe accessory
    ///   - rightCellSwipeAccessory: the specifications for the left swipe accessory
    @ViewBuilder public func swipeActions(
        leftCellSwipeAccessory: CellSwipeAccessory?,
        rightCellSwipeAccessory: CellSwipeAccessory?
    ) -> some View {
        self.modifier(
            SwipeActionsModifier(
                leftCellSwipeAccessory: leftCellSwipeAccessory,
                rightCellSwipeAccessory: rightCellSwipeAccessory
            )
        )

    }
}

private extension Notification.Name {
    static let cellSwipeAccessoryVisibilityReset = Notification.Name(UUID().uuidString)
}

public struct CellSwipeAccessoryVisibilityKey: EnvironmentKey {
    public static var defaultValue: CellSwipeAccessoryVisibility = .showNone
}

extension EnvironmentValues {
    public var cellSwipeAccessoryVisibility: CellSwipeAccessoryVisibility {
        get { self[CellSwipeAccessoryVisibilityKey.self] }
        set {
            self[CellSwipeAccessoryVisibilityKey.self] = newValue
        }
    }
}
