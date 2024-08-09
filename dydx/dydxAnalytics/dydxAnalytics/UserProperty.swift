//
//  UserProperty.swift
//  dydxAnalytics
//
//  Created by Michael Maguire on 8/8/24.
//

// these should be added in firebase as user properties custom definitions https://firebase.google.com/docs/analytics/user-properties?platform=ios
public enum UserProperty: String {
    case walletAddress
    case walletType
    case network
    case selectedLocale
    case dydxAddress
    case subaccountNumber
    case statsigFlags
    case statsigStableId
}
