//
//  dydxPublicApi.swift
//  dydxWallet
//
//  Created by John Huang on 3/17/22.
//  Copyright © 2022 dYdX Trading Inc. All rights reserved.
//

import ParticlesKit
import Utilities

open class dydxPublicApi: WebApi {
    public static var sequence: Int = 0
    public static var endpointResolver: EndpointResolverProtocol = {
        JsonEndpointResolver(json: "endpoints_public.json")
    }()

    public required init(priority: Int = 10) {
        super.init(endpointResolver: type(of: self).endpointResolver, priority: priority)

        requestInjections = [dydxClientSourceInjection()]
    }

    public required init(server: String? = nil, priority: Int = 10) {
        super.init(endpointResolver: type(of: self).endpointResolver, priority: priority)

        requestInjections = [dydxClientSourceInjection()]
    }

    public required init(endpointResolver: EndpointResolverProtocol?, priority: Int = 100) {
        super.init(endpointResolver: endpointResolver, priority: priority)

        requestInjections = [dydxClientSourceInjection()]
    }
}
