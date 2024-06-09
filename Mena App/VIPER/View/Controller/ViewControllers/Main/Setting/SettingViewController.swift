//
//  SettingViewController.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 09/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {
  //MARK: - @IBOutlet

  @IBOutlet weak var tableView: UITableView!
  //MARK: - Local variables

  var dataSource = [
    "Change Password",
    "View Private Key",
    "View Seed Words",
    "Delete Wallet",
    "Change Bank Details",
  ]

  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.delegate = self
    self.tableView.dataSource = self
    // Do any additional setup after loading the view.
  }

}
extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 5
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell") as? SettingCell {
      cell.lblTitle.text = self.dataSource[indexPath.row]
      return cell
    }
    return UITableViewCell()
  }
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 90
  }

}

class SettingCell: UITableViewCell {

  @IBOutlet weak var viewBg: UIView!

  @IBOutlet weak var lblTitle: UILabel!

  override func awakeFromNib() {
    viewBg.layer.cornerRadius = 15
  }

}
