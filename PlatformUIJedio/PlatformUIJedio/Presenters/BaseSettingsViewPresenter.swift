//
//  BaseSettingsViewPresenter.swift
//  PlatformUIJedio
//
//  Created by Rui Huang on 3/20/23.
//

import Utilities
import dydxViews
import PlatformParticles
import RoutingKit
import ParticlesKit
import PlatformUI
import JedioKit

public class SettingsViewController: HostingViewController<PlatformView, SettingsViewModel> {
    public var requestPath = "<Replace>"
    
    override public func arrive(to request: RoutingRequest?, animated: Bool) -> Bool {
        if request?.path == requestPath {
            return true
        }
        return false
    }
}
 
public protocol SettingsViewPresenterProtocol: HostedViewPresenterProtocol {
    var viewModel: SettingsViewModel? { get }
}

open class BaseSettingsViewPresenter: HostedViewPresenter<SettingsViewModel>, SettingsViewPresenterProtocol {
    let fieldsEntity: FieldsEntityInteractor
    
    var fieldLists: [FieldListInteractor]? {
        fieldsEntity.list?.list as? [FieldListInteractor]
    }
    
    public static func newFieldsEntity(forDefinitionFile definitionFile: String) -> FieldsEntityInteractor {
        let fieldsLoader = FieldLoader()
        fieldsLoader.definitionFile = definitionFile
        
        let fieldsEntity = FieldsEntityInteractor()
        fieldsEntity.fieldLoader = fieldsLoader
        fieldsEntity.list = ListInteractor()
        fieldsEntity.entity = DictionaryEntity()
        return fieldsEntity
    }
    
    public init(definitionFile: String) {
        self.fieldsEntity = Self.newFieldsEntity(forDefinitionFile: definitionFile)
        super.init()
        viewModel = SettingsViewModel()
    }
}
