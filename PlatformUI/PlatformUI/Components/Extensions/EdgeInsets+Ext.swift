//
//  EdgeInsets+ext.swift
//  PlatformUI
//
//  Created by Michael Maguire on 6/4/24.
//

import SwiftUI

public extension EdgeInsets {
    init(all: CGFloat) {
        self.init(top: all, leading: all, bottom: all, trailing: all)
    }

    init(horizontal: CGFloat, vertical: CGFloat) {
        self.init(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
    }
}
