//
//  PresenterProcessor.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 08/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation

class PresenterProcessor {
    
    static let shared = PresenterProcessor()
    
    func signUp(api : Base , data : Data)-> SignUpResponse{
        return data.getDecodedObject(from: SignUpResponse.self)!
    }
}
