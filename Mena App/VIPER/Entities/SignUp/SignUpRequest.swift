//
//  SignUpRequest.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 24/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation

struct SignUpRequest: JSONSerializable, Codable{
    
    var path : String = ""
    var address : String = ""
    var signature : String = ""
    var message : String = ""
    
}

struct SignUpResponse: Codable{
    
    var email: String?
    var auth_key : String?
    var error : String?

    
}
