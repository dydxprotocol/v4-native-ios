//
//  Double+Ext.swift
//  dydxPresenters
//
//  Created by Michael Maguire on 10/1/24.
//

import Abacus


extension Double {
    var asKotlinDouble: KotlinDouble {
        KotlinDouble(value: self)
    }
}

extension Bool {
    var asKotlinBoolean: KotlinBoolean {
        KotlinBoolean(value: self)
    }
}

extension Int {
    var asKotlinInt: KotlinInt {
        KotlinInt(value: Int32(self))
    }
}
