//
//  TransactionCell.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 09/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import UIKit

class TransactionCell: UITableViewCell {

    @IBOutlet weak var viewBg: UIView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblHolderName: UILabel!
    
  override func awakeFromNib() {
    viewBg.layer.cornerRadius = 15
  }

}
