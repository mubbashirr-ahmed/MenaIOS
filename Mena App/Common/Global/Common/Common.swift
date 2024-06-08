//
//  Common.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 08/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation
import UIKit

class Common {
    
    class func addCornersToView(_ view : UIView){
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        view.layer.masksToBounds = false
        view.clipsToBounds = true

    }
    
    // MARK:- Set Font
    
    class func setFont(to field :Any, isTitle : Bool = false, size : CGFloat = 0, textAlingment: NSTextAlignment = .left, font : FontCustom = .Regular ) {
    
        let customSize = size > 0 ? size : (isTitle ? 18 : 16)
        let font = UIFont(name: isTitle ? FontCustom.Bold.rawValue : font.rawValue, size: customSize)
        switch (field.self) {
        case is UITextField:
            (field as? UITextField)?.font = font
            if [NSTextAlignment.left, .right].contains((field as! UITextField).textAlignment) {
                (field as? UITextField)?.textAlignment = textAlingment
            }
        case is UILabel:
            (field as? UILabel)?.font = font//UIFont(name: isTitle ? FontCustom.avenier_Heavy.rawValue : FontCustom.avenier_Medium.rawValue, size: customSize)
            if [NSTextAlignment.left, .right].contains((field as! UILabel).textAlignment) {
                (field as? UILabel)?.textAlignment = textAlingment
            }
            
        case is UIButton:
            (field as? UIButton)?.titleLabel?.font = font
            
            if [UIControl.ContentHorizontalAlignment.left, .right].contains((field as! UIButton).contentHorizontalAlignment) {
                (field as! UIButton).contentHorizontalAlignment = textAlingment == .left ? .left : .center
            }
        case is UITextView:
            (field as? UITextView)?.font = font//UIFont(name: isTitle ? FontCustom.avenier_Heavy.rawValue : FontCustom.avenier_Medium.rawValue, size: customSize)
            //(field as? UITextView)?.textAlignment = (selectedLanguage == .arabic && (field as! UITextView).textAlignment == .left) ? .right : .left
        default:
            break
        }
    }
}
