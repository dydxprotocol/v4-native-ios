//
//  Kotlin+Ext.swift
//  dydxStateManager
//
//  Created by Michael Maguire on 6/10/24.
//

import Abacus

extension KotlinDouble: Comparable {
    public static func < (lhs: KotlinDouble, rhs: KotlinDouble) -> Bool {
        return lhs.doubleValue < rhs.doubleValue
    }

    public static func == (lhs: KotlinDouble, rhs: KotlinDouble) -> Bool {
        return lhs.doubleValue == rhs.doubleValue
    }
}

extension KotlinInt: Comparable {
    public static func < (lhs: KotlinInt, rhs: KotlinInt) -> Bool {
        return lhs.intValue < rhs.intValue
    }

    public static func == (lhs: KotlinInt, rhs: KotlinInt) -> Bool {
        return lhs.intValue == rhs.intValue
    }
}
