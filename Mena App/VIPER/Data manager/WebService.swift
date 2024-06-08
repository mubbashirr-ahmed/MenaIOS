//
//  WebService.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 08/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation


class Webservice : PostWebServiceProtocol {
    
    var interactor: PostInteractorOutputProtocol?
    var completion : ((CustomError?, Data?)->())?
    
    func retrieve(api: Base, url: String?, data: Data?, imageData: [String : Data]?, paramters: [String : Any]?, type: HttpType, completion: ((CustomError?, Data?) -> ())?) {
        
    }
}
