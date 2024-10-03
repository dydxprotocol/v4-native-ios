//
//  Utilities+Ext.swift
//  dydxPresenters
//
//  Created by Michael Maguire on 10/2/24.
//

import Abacus
import Utilities

//extension DataLocalizer: @retroactive LocalizerProtocol {}
extension DataLocalizerProtocol {
    var asAbacusLocalizer: (any AbacusLocalizerProtocol)? {
        self as? AbacusLocalizerProtocol
    }
}
