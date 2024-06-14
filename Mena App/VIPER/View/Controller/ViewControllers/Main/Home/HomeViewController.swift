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
    
    @IBOutlet weak var collectionView: UICollectionView!
    

  //MARK: - Local variables

  //MARK: - viewDidLoad
  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.register(
      UINib(nibName: XIB.Names.TransactionCell, bundle: nil),
      forCellReuseIdentifier: XIB.Names.TransactionCell)
    initialLoads()

    // Do any additional setup after loading the view.
  }

}

//MARK: - extension
extension HomeViewController {
  func initialLoads() {
    setFont()
    setDesign()
    addGesture()
  }
  func setFont() {

  }
  func setDesign() {
    self.tableView.delegate = self
    self.tableView.dataSource = self
      self.collectionView.delegate = self
      self.collectionView.dataSource = self
      
    viewSend.layer.cornerRadius = 12
    viewRecieve.layer.cornerRadius = 12
    viewRefill.layer.cornerRadius = 12
  }
  func addGesture() {
      viewSend.isUserInteractionEnabled = true
      viewRefill.isUserInteractionEnabled = true
      viewRecieve.isUserInteractionEnabled = true
    viewSend.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(viewSendAction)))
    viewRefill.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(viewRefillAction)))
    viewRecieve.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(viewRecieveAction)))
  }
  @objc func viewSendAction() {
      
      if let vc = self.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.SendCoinViewController) as? SendCoinViewController{
          vc.modalPresentationStyle = .fullScreen
          vc.customTitle = Constants.string.send.localize()
          self.present(vc, animated: true, completion: nil)
      }

  }
  @objc func viewRefillAction() {
      if let vc = self.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.RefillViewController) as? RefillViewController{
          vc.modalPresentationStyle = .fullScreen
          vc.customTitle = Constants.string.refill.localize()
          self.present(vc, animated: true, completion: nil)
      }
  }
  @objc func viewRecieveAction() {
      if let vc = self.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.RecieveViewController) as? RecieveViewController{
          vc.modalPresentationStyle = .fullScreen
          vc.customTitle = Constants.string.recieveWithQR.localize()
          self.present(vc, animated: true, completion: nil)
      }
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

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionCell", for: indexPath) as? HomeCollectionCell {
         return cell
        }
        return UICollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

class HomeCollectionCell: UICollectionViewCell{
    @IBOutlet weak var imgCurrency: UIImageView!
    
    @IBOutlet weak var lblCurrencyName: UILabel!
    
    @IBOutlet weak var lblCurrency: UILabel!
    
}
