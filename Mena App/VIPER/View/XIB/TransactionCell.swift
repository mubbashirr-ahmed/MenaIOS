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

  override func awakeFromNib() {
    viewBg.layer.cornerRadius = 15
  }

}
