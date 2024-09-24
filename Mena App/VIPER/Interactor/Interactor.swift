//
//  Interactor.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 08/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation

class Interactor  {
    
    var webService: PostWebServiceProtocol?
    var presenter: PostPresenterOutputProtocol?
}

//MARK:- PostInteractorInputProtocol

extension Interactor : PostInteractorInputProtocol {
    
    func send(api: Base, url: String, data: Data?, type: HttpType) {
      
        self.webService?.retrieve(api: api,url: url, data: data, imageData: nil, paramters: nil, type: type, completion: nil)
    }
    
    func send(api: Base, data: Data?, paramters: [String : Any]?, type: HttpType) {
        
        self.webService?.retrieve(api: api,url: nil, data: data, imageData: nil, paramters: paramters, type: type, completion: nil)
    }
    
    func send(api: Base, imageData: [String : Data]?, parameters: [String : Any]?) {
        
        self.webService?.retrieve(api: api,url: nil, data: nil, imageData: imageData, paramters: parameters, type: .POST, completion: nil)
    }
}

//MARK:- PostInteractorOutputProtocol
extension Interactor : PostInteractorOutputProtocol {
    func on(api: Base, error: CustomError) {
        self.presenter?.onError(api: api, error: error)
    }
 
    func on(api: Base, response: Data) {
        
        switch api {
        case .signUp: 
            self.presenter?.signUp(api: api, data: response)
            break
        case .menaHistory, .tokenHistory:
            self.presenter?.sendTransactionHistory(api: api, data: response)
            break
        case .contract:
            self.presenter?.sendContract(api: api, data: response)
        case.countryCurrency:
            self.presenter?.sendCountryCurrency(api: api, data: response)
           
        case .bankDetail, .createTrade:
            self.presenter?.sendBankRefillResponse(api: api, data: response)
           
        case .tokenTransactionSend:
            self.presenter?.sendTransactionResponse(api: api, data: response)
        default :
            break
        }
    }
    
}
