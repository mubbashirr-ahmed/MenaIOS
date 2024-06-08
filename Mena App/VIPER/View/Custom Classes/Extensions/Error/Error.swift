//
//  Error.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 08/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation

// Custom Error Protocol
protocol CustomErrorProtocol : Error {
    var localizedDescription : String {get set}
}


// Custom Error Struct for User Defined Error Messages

struct CustomError : CustomErrorProtocol {
   
    var localizedDescription: String
    var statusCode : Int
    
    init(description : String, code : Int){
        self.localizedDescription = description
        self.statusCode = code
    }
}
