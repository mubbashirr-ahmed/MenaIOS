//
//  HomeViewController.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 09/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

  //MARK: - @IBOutlet

  @IBOutlet weak var tableView: UITableView!

  @IBOutlet weak var viewRecieve: UIView!

  @IBOutlet weak var viewSend: UIView!

  @IBOutlet weak var viewRefill: UIView!

  //MARK: - Local variables

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.register(
      UINib(nibName: XIB.Names.TransactionCell, bundle: nil),
      forCellReuseIdentifier: XIB.Names.TransactionCell)
    initialLoads()

    // Do any additional setup after loading the view.
  }

}
extension HomeViewController {
  func initialLoads() {
    setFont()
    setDesign()
  }
  func setFont() {

  }
  func setDesign() {
    self.tableView.delegate = self
    self.tableView.dataSource = self
    viewSend.layer.cornerRadius = 12
    viewRecieve.layer.cornerRadius = 12
    viewRefill.layer.cornerRadius = 12
  }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3  // Replace with your data count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard
      let cell = tableView.dequeueReusableCell(
        withIdentifier: XIB.Names.TransactionCell, for: indexPath) as? TransactionCell
    else {
      fatalError("Unable to dequeue TransactionCell")
    }
    // Configure your cell
    cell.viewBg.backgroundColor = .textFieldBackground  // Example configuration
    return cell
  }
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 80
  }

}
