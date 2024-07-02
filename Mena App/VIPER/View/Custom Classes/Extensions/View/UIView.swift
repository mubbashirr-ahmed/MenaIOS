//
//  UIView.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 01/07/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation
import UIKit

extension UIView{
    func addPressAnimation(with  duration : TimeInterval = 0.2 , transform : CGAffineTransform = CGAffineTransform(scaleX: 0.95, y: 0.95)) {
        
        UIView.animate(withDuration: duration, animations: {
            self.transform = transform
        }) { (bool) in
            UIView.animate(withDuration: duration, animations: {
                self.transform = .identity
            })
        }
    }
}
