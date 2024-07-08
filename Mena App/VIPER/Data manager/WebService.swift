//
//  WebService.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 08/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation
import Foundation
import Alamofire

class Webservice : PostWebServiceProtocol {
   
    
    var interactor: PostInteractorOutputProtocol?
    var completion : ((CustomError?, Data?)->())?
    
    
    //MARK:- SEND WEBSERVICE REQUEST TO BACKEND
    func retrieve(api: Base,url : String?, data: Data?, imageData: [String:Data]?, paramters: [String : Any]?, type: HttpType, completion : ((CustomError?, Data?)->())?) {
        
        print("To url + + + \(Date()) ", api.rawValue)
        
        if data != nil {
            

            print("\nAt Webservice Request \(Date()) ",String(data: data!, encoding: .utf8) ?? .Empty)
          //  bfprint("\nAt Webservice Request  ",String(data: data!, encoding: .utf8) ?? .Empty)
        }
        if paramters != nil {
            
            print("\nAt Webservice Request \(Date()) ",paramters!)
         //   bfprint("\nAt Webservice Request  ",paramters!)

        }
        
        if imageData != nil {
            

            print("\nImage Data Request  \(Date())",imageData!)
           // bfprint("\nImage Data Request  ",imageData!)

        }
        
        self.completion = completion

     
        
        // If ImageData is available send in multipart

        if url != nil && api == .signUp || api == .createTrade || api == .bankDetail{ // send normal GET POST call
            self.send(api: api, imageData: nil, parameters: paramters)
           // self.send(api: api,url : url!, data: data, parameters: paramters, type: type)
        } else {
           // self.send(api: api, imageData: nil, parameters: paramters)
            self.send(api: api,url : nil, data: data, parameters: paramters, type: type)
        }
    }
    
    //MARK:- Send Response to Interactor
    
    fileprivate func send(_ response: (AFDataResponse<Any>)?) {
        
        let apiKey = response?.request?.value(forHTTPHeaderField: WebConstants.string.secretKey)
        
        let apiType = Base.valueFor(Key: apiKey)
        
        guard let response = response else {
            

            print("\nAt Webservice Response  \(Date())",response)
          
            self.completion?(CustomError(description: ErrorMessage.list.serverError, code : StatusCode.notreachable.rawValue), nil)
            self.interactor?.on(api: apiType, error: CustomError(description: ErrorMessage.list.serverError, code : StatusCode.notreachable.rawValue))
            return
        }
        
         if response.response?.statusCode != StatusCode.success.rawValue  {  //  Validation for Error Log
            
              if response.data != nil  { // Retrieving error from Server
                
                var errMessage : String = .Empty
                
                do {
                    
                    if let errValue = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as? [String : [Any]] {
                        
                        for err in errValue.values where err.count>0 {
                            
                            errMessage.append("\n\(err.first ?? String.Empty)")
                            
                        }
                        
                    }
                    else if let errValue = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as? NSDictionary {
                        
                        for err in errValue.allValues{
                            
                            errMessage.append("\n\(err)")
                        }
                    }
                    print("errMessage: \(errMessage)")
                }
                catch let err {
                    print("Err  ",err.localizedDescription)
                 //   bfprint("Err  ",err.localizedDescription)
                }
                
                if errMessage.isEmpty {
                    errMessage = ErrorMessage.list.serverError
                }
                
                self.completion?(CustomError(description:errMessage, code: response.response?.statusCode ?? StatusCode.ServerError.rawValue), nil)
                self.interactor?.on(api: apiType, error: CustomError(description:errMessage, code: response.response?.statusCode ?? StatusCode.ServerError.rawValue))
            }
            else {
                
                self.completion?(CustomError(description: response.error!.localizedDescription, code: response.response?.statusCode ?? StatusCode.ServerError.rawValue), nil)
                self.interactor?.on(api: apiType, error: CustomError(description: response.error!.localizedDescription, code: response.response?.statusCode ?? StatusCode.ServerError.rawValue))
            }
            
        }
        else if let data = response.data  {  // Validation For Server Data
            
            self.completion?(nil, data)
            self.interactor?.on(api: apiType, response: data)
            
        }
        else { // Validation for Exceptional Cases
            
            self.completion?(CustomError(description: ErrorMessage.list.serverError, code: StatusCode.ServerError.rawValue), nil)
            self.interactor?.on(api: apiType, error: CustomError(description: ErrorMessage.list.serverError, code: StatusCode.ServerError.rawValue))
            
        }
    }
    
    // MARK:- Send Api Normal Request
    
    func send(api: Base, url appendingUrl : String?, data: Data?, parameters : [String : Any]?, type : HttpType) {
        
        var url : URL?
        var urlRequest : URLRequest?

        var getParams : String = .Empty
        
        switch type {
            
        case .GET:
            
            if appendingUrl != nil {
                getParams = appendingUrl!
            }
            else {
                for (index,param) in (parameters ?? [:]).enumerated() {
                    getParams.append((index == 0 ? "?" : "&")+"\(param.key)=\(param.value)")
                }
                getParams = api.rawValue+getParams
            }
            
        case .POST:
            
            if appendingUrl == nil {
                getParams = api.rawValue.trimmingCharacters(in: .whitespaces)
            } else {
                getParams = appendingUrl!
            }
            
        case .DELETE, .PATCH, .PUT :
            getParams = appendingUrl ?? .Empty
            
        }
        
        // Setting Base url as FCM incase of FCM Push
        let urlString = baseUrl + getParams
        
        
    print(urlString)
        //let urlRemove =  urlString.removingWhitespaces()
//        if api == .estimateFare{
//            let urlEncoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
//
//            url = URL(string: urlEncoded ?? "")
//        }
//        else{
//            url = URL(string: urlString)
//        }
        
        let urlEncoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) // for query parameters
        
       
        url = URL(string: urlEncoded ?? "")
        if url != nil {
            urlRequest = URLRequest(url: url!)
        }
        else{
            print("URL is Null")
        }
        print("urlEncoded: \(urlEncoded) ")
        urlRequest?.httpBody = data
        urlRequest?.httpMethod = type.rawValue
        
        guard urlRequest != nil else { // Flow validation in url request
            interactor?.on(api: api, error: CustomError(description: ErrorMessage.list.serverError, code: StatusCode.ServerError.rawValue))
            return
        }
        
        // Setting Secret Key to Identify the response Api
        
        urlRequest?.addValue(api.rawValue, forHTTPHeaderField: WebConstants.string.secretKey)
        urlRequest?.addValue(WebConstants.string.application_json, forHTTPHeaderField: WebConstants.string.Content_Type)
        urlRequest?.addValue(WebConstants.string.XMLHttpRequest, forHTTPHeaderField: WebConstants.string.X_Requested_With)
        urlRequest?.addValue(WebConstants.string.Content_Type, forHTTPHeaderField: WebConstants.string.multipartFormData)
        
        
        AF.request(urlRequest!).validate(statusCode: StatusCode.success.rawValue..<StatusCode.multipleResponse.rawValue).responseJSON { (response) in
            let api = response.request?.value(forHTTPHeaderField: WebConstants.string.secretKey) ?? .Empty
            switch response.result{
                
            case .failure(let err):
                
                print("At Webservice Response  at ",api,"   ",err, response.response?.statusCode ?? 0)

            case .success(let val):
                print(response.response.debugDescription)
                
                print("At Webservice Response ",api,"   ",val, response.response?.statusCode ?? 0)
                
            }
            
            self.send(response)
        }
    }
  

    private func send(api: Base, imageData: [String: Data]?, parameters: [String: Any]?) {
        
        guard let url = URL(string: baseUrl + api.rawValue) else {  // Validating Url
            print("Invalid Url")
            return
        }
        
        var headers: HTTPHeaders = [
            WebConstants.string.secretKey:api.rawValue,
            "Content-Type": WebConstants.string.multipartFormData,
            "X-Requested-With": WebConstants.string.application_json,
          
        ]
        
        AF.upload(multipartFormData: { multipartFormData in
            
            for (key, value) in parameters ?? [:] {
                if let data = "\(value)".data(using: .utf8) {
                    multipartFormData.append(data, withName: key)
                }
            }
            
            if let imageArray = imageData {
                for (key, value) in imageArray {
                    multipartFormData.append(value, withName: key, fileName: "image.png", mimeType: "image/png")
                }
            }
            
        }, to: url, method: .post, headers: headers).responseJSON { response in
            switch response.result {
                
            case .success(let value):
                print("At Webservice Response ",api,"   ",value, response.response?.statusCode ?? 0)
                self.send(response)
            case .failure(let error):
                self.send(nil)
                print("Error in upload: \(error.localizedDescription)")
            }
        }
    }

    
}


