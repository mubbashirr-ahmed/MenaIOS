//
//  Presenter.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 08/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation

class Presenter  {
    
    var interactor: PostInteractorInputProtocol?
    var controller: PostViewProtocol?
}

//MARK:- Implementation PostPresenterInputProtocol

extension Presenter : PostPresenterInputProtocol {

    func put(api: Base, url: String, data: Data?) {
        interactor?.send(api: api, url: url, data: data, type: .PUT)
    }
    
    func delete(api: Base, url: String, data: Data?) {
        interactor?.send(api: api, url: url, data: data, type: .DELETE)
    }
    
    func patch(api: Base, url: String, data: Data?) {
        interactor?.send(api: api, url: url, data: data,type: .PATCH)
    }
    
    func post(api: Base, data: Data?) {
        interactor?.send(api: api, data: data, paramters: nil, type: .POST)
    }
    
    func get(api: Base, parameters: [String : Any]?) {
        interactor?.send(api: api, data: nil, paramters: parameters, type: .GET)
    }
    
    func get(api : Base, url : String){
        interactor?.send(api: api, url: url, data: nil, type: .GET)
    }
    
    func post(api: Base, imageData: [String : Data]?, parameters: [String : Any]?) {
        interactor?.send(api: api, imageData: imageData, parameters: parameters)
    }
    
    func post(api: Base, url: String, data: Data?) {
        interactor?.send(api: api, url: url, data: data,type: .POST)
    }
    
}

//MARK:- Implementation PostPresenterOutputProtocol

extension Presenter : PostPresenterOutputProtocol {
    func onError(api: Base, message: String, statusCode code: Int) {
        controller?.onError(api: api, message: message, statusCode: code)
    }
    
    func sendCountryCurrency(api: Base, data: Data) {
        controller?.getCurrencyCountry(api: api, data: PresenterProcessor.shared.getCurrencyCountry(api: api, data: data))
    }
    
    func sendContract(api: Base, data: Data) {
        controller?.getContract(api: api, data: PresenterProcessor.shared.getContract(api: api, data: data))
    }
    
    
    func sendTransactionHistory(api: Base, data: Data) {
        controller?.getTransactionHistory(api: api, data: PresenterProcessor.shared.getTransactionHistory(api: api, data: data))
    }
    
    func signUp(api: Base, data: Data) {
        controller?.getSignUp(api: api, data: PresenterProcessor.shared.signUp(api: api, data: data))
    }
    
    
    func onError(api: Base, error: CustomError) {
        controller?.onError(api: api, message: error.localizedDescription , statusCode: error.statusCode)
    }
    func sendBankRefillResponse(api: Base, data: Data) {
        controller?.getBankRefillResponse(api: api, data: PresenterProcessor.shared.getBankRefillResponse(api: api, data: data))
    }
    
}
