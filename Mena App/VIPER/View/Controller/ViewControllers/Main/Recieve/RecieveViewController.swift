//
//  RecieveViewController.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 12/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class RecieveViewController: UIViewController {
  //MARK: - @IBOutlet
  @IBOutlet weak var viewQR: UIView!

  @IBOutlet weak var lblWalletAddress: UILabel!

  @IBOutlet weak var imgQR: UIImageView!

  @IBOutlet weak var lblRecieveNow: UILabel!

  //MARK: - Local variable
  var customTitle: String?

  //MARK: - viewDidLoad
  override func viewDidLoad() {
    super.viewDidLoad()
    initialLoads()
    // Do any additional setup after loading the view.
  }

  //MARK: - viewWillAppear

  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.isNavigationBarHidden = false
  }

}
//MARK: - extension
extension RecieveViewController {
  func initialLoads() {

    addCrossButton()
    setFonts()
    setDesign()
    localize()
    getPrivatePublic()
  }
  func setFonts() {

  }
  func setDesign() {
    viewQR.layer.cornerRadius = 15

  }
  func localize() {
    lblRecieveNow.text = Constants.string.recieveNowBySharing.localize()

  }

  func addCrossButton() {
    let headerView = CustomHeaderView()
    headerView.translatesAutoresizingMaskIntoConstraints = false
    headerView.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    headerView.title = Constants.string.recieveWithQR.localize()  // Set the title dynamically
    view.addSubview(headerView)

    // Add constraints to the header view
    NSLayoutConstraint.activate([
      headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      headerView.heightAnchor.constraint(equalToConstant: 60),
    ])
  }

  @objc func backButtonTapped() {
    self.dismiss(animated: true, completion: nil)
  }
  func getPrivatePublic() {
      if KeychainWrapper.standard.string(forKey: "keychain_address") != nil{
          
          self.lblWalletAddress.text = "\(String(describing: KeychainWrapper.standard.string(forKey: "keychain_address") ?? ""))"
          self.imgQR.image = generateQRCode(from: "address::\(String(describing: KeychainWrapper.standard.string(forKey: "keychain_address") ?? ""))")
        //  self.getContract()
      }
      else{
          if let account = WalletManager.shared.generateNewEthereumAccount() {
              print("Private Key: \(account.privateKey)")
              
              print("Public Key: \(account.publicKey)")
              
              print("Ethereum Address: \(account.address)")
              self.lblWalletAddress.text = "\(account.address)"
              self.imgQR.image = generateQRCode(from: account.address)
          }
      }
  }

  func generateQRCode(from string: String) -> UIImage? {
    let data = string.data(using: String.Encoding.ascii)

    if let filter = CIFilter(name: "CIQRCodeGenerator") {
      filter.setValue(data, forKey: "inputMessage")
      let transform = CGAffineTransform(scaleX: 3, y: 3)

      if let output = filter.outputImage?.transformed(by: transform) {
        return UIImage(ciImage: output)
      }
    }

    return nil
  }
}
