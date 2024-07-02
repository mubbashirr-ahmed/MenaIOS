//
//  Router.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 08/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation
import UIKit

typealias ViewController = (UIViewController & PostViewProtocol)
var presenterObject :PostPresenterInputProtocol?
class Router {
    
    static let main = UIStoryboard(name: "Main", bundle: Bundle.main)
    static let preLogin = UIStoryboard(name: "PreLogin", bundle: Bundle.main)
    
    class func setWireFrame()->(UIViewController){
        
        let presenter : PostPresenterInputProtocol&PostPresenterOutputProtocol = Presenter()
        let interactor : PostInteractorInputProtocol&PostInteractorOutputProtocol = Interactor()
        let webService : PostWebServiceProtocol = Webservice()
        if let view : (PostViewProtocol & UIViewController) = preLogin.instantiateViewController(withIdentifier: Storyboard.Ids.LaunchViewController) as? ViewController {
          
            presenter.controller = view
            view.presenter = presenter
            presenterObject = view.presenter
            
        }
        
        webService.interactor = interactor
        interactor.webService = webService
        interactor.presenter = presenter
        presenter.interactor = interactor
        
        if WalletManager.shared.doesKeystoreExist(){
            let vc = preLogin.instantiateViewController(withIdentifier: Storyboard.Ids.PasswordViewController)
            let navigationController = UINavigationController(rootViewController: vc)
            navigationController.isNavigationBarHidden = true
            return navigationController
        }
        else{
            let vc = preLogin.instantiateViewController(withIdentifier: Storyboard.Ids.LaunchViewController)
            let navigationController = UINavigationController(rootViewController: vc)
            navigationController.isNavigationBarHidden = true
            return navigationController
        }
                
    
    }
    
    
}
