//
//  ImportPrivateKeyViewController.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 11/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import SwiftKeychainWrapper
import UIKit
import Web3Core

class ImportPrivateKeyViewController: UIViewController {
  //MARK: - @IBOutlet
  @IBOutlet weak var txtImport: UITextField!

  @IBOutlet weak var viewImport: UIView!

  @IBOutlet weak var btnImport: UIButton!

  @IBOutlet weak var lblImportUsing: UILabel!

  @IBOutlet weak var viewPublic: UIView!

  @IBOutlet weak var viewWalletPassword: UIView!

  @IBOutlet weak var viewWalletConfirmPassword: UIView!

  @IBOutlet weak var txtPublic: UITextField!

  @IBOutlet weak var txtPassword: UITextField!

  @IBOutlet weak var txtConfirmPassword: UITextField!

  //MARK: - Local variable

  private lazy var loader: UIView = {
    return createActivityIndicator(UIApplication.shared.keyWindow ?? self.view)
  }()

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

  @IBAction func btnImportAction(_ sender: Any) {
    //        guard let publicKey = txtPublic.text, !publicKey.isEmpty else {
    //                 showAlert(message: "Public key cannot be empty")
    //                 return
    //             }

    guard let privateKey = txtImport.text, !privateKey.isEmpty else {
      showAlert(message: "Private key cannot be empty")
      return
    }

    guard let password = txtPassword.text, !password.isEmpty else {
      showAlert(message: "Password cannot be empty")
      return
    }

    guard let confirmPassword = txtConfirmPassword.text, password == confirmPassword else {
      showAlert(message: "Passwords do not match")
      return
    }

    DispatchQueue.main.async {
      self.loader.isHidden = false
    }

    do {

      let keystore = try WalletManager.shared.importWallet(
        privateKey: privateKey, publicKey: "publicKey", password: password)

      if keystore != nil {

        WalletManager.shared.loginWithPassword(password: password) { result in
          DispatchQueue.main.async {

            switch result {
            case .success(let address):
              print("Logged in with address: \(address)")
              
              self.login(keyStoreAddress: keystore?.address ?? "", password: password)
            case .failure(let error):
              self.loader.isHidden = true
              print("Error logging in: \(error.localizedDescription)")
              self.showAlert(message: error.localizedDescription)
            //self.push(id: Storyboard.Ids.CreateWalletViewController, animation: true)
            // Handle error gracefully, e.g., show alert to user
            }

          }

        }
      } else {
        DispatchQueue.main.async {
          self.loader.isHidden = true
          self.showAlert(message: "Invalid private key")
        }

      }

    } catch {
      DispatchQueue.main.async {
        self.loader.isHidden = true
        self.showAlert(message: "Invalid private key")
      }
      print("An error occurred: \(error.localizedDescription)")
    }

  }

}
//MARK: - extension
extension ImportPrivateKeyViewController {
  func initialLoads() {
    localize()
    setFonts()
    setDesign()
    addCrossButton()
  }
  func setFonts() {

  }
  func setDesign() {
    btnImport.layer.cornerRadius = 15
    viewImport.layer.cornerRadius = 15
    viewPublic.layer.cornerRadius = 15
    viewWalletPassword.layer.cornerRadius = 15
    viewWalletConfirmPassword.layer.cornerRadius = 15

  }
  func localize() {
    lblImportUsing.text = Constants.string.importUsingPrivateKey.localize()
    self.txtImport.placeholder = Constants.string.enterPrivateKey.localize()
    self.txtPublic.placeholder = Constants.string.enterPublicKey.localize()
    self.txtPassword.placeholder = Constants.string.enterYourWalletPassword.localize()
    self.txtConfirmPassword.placeholder = Constants.string.enterConfirmPassword.localize()
  }

  func addCrossButton() {
    let headerView = CustomHeaderView()
    headerView.translatesAutoresizingMaskIntoConstraints = false
    headerView.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    headerView.title = Constants.string.privateKey.localize()  // Set the title dynamically
    view.addSubview(headerView)

    // Add constraints to the header view
    NSLayoutConstraint.activate([
      headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      headerView.heightAnchor.constraint(equalToConstant: 60),
    ])
  }
  func login(keyStoreAddress: String, password: String) {
    let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let keystorePath = userDir + "/keystore/key.json"
    print("Path login wallet: \(keystorePath)")

    let keystoreURL = URL(fileURLWithPath: keystorePath)

    if FileManager.default.fileExists(atPath: keystorePath) {
      print("Keystore file exists at path: \(keystorePath)")

      do {
        let keystoreData = try Data(contentsOf: keystoreURL)
        print("Keystore data loaded successfully from file.")
        if let bip32Keystore = EthereumKeystoreV3(keystoreData) {
            
            KeychainWrapper.standard.set(keyStoreAddress, forKey: "keychain_address")
            KeychainWrapper.standard.set(password, forKey: "keychain_password")
          self.setWalletToServer(
            adress: keyStoreAddress, path: "path", ecKeyPair: bip32Keystore, password: password)
        }
      } catch {

      }
    }
  }

  @objc func backButtonTapped() {
    self.dismiss(animated: true, completion: nil)
  }
  func setWalletToServer(
    adress: String?, path: String?, ecKeyPair: EthereumKeystoreV3, password: String
  ) {

      let message = MessageHelper.getMessage()
      var signatature = SignatureHelper.getSignature(messageBytes: message.bytes, ecKeyPair: ecKeyPair, password: password)
      
      signatature = signatature?.addHexPrefix() ?? ""
      
    let parameters: [String: Any] = [
      "path": "path",
      "address": "\(String(describing: adress ?? ""))",
      "message": "\(message)",
      "signature":"\(String(describing: signatature ?? ""))"
    ]

      

    self.presenter?.post(api: .signUp, imageData: nil, parameters: parameters)
    //self.presenter?.post(api: .signUp, data: data)

  }
  func showTabBarController() {
    DispatchQueue.main.async {

      guard
        let tabBarController = Router.main.instantiateViewController(
          withIdentifier:
            Storyboard.Ids.tabBarController) as? UITabBarController
      else {
        return
      }

      // Set the modal presentation style if needed
      tabBarController.modalPresentationStyle = .fullScreen

      // Present the UITabBarController
      self.present(tabBarController, animated: true, completion: nil)
    }
  }

}

extension ImportPrivateKeyViewController: PostViewProtocol {

  func onError(api: Base, message: String, statusCode code: Int) {
    self.loader.isHidden = true
    showAlert(message: message)
  }

  func getSignUp(api: Base, data: SignUpResponse?) {
    self.loader.isHidden = true

      if data?.error == nil {
          if KeychainWrapper.standard.set(data?.auth_key ?? "", forKey: "keychain_auth_key")
                && KeychainWrapper.standard.set(data?.email ?? "", forKey: "keychain_email")
          {
              showTabBarController()
          }
      }
      else{
          print("Something went wrong to create wallet")
      }

  }

}
