//
//  ChangePasswordViewController.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 11/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import SwiftKeychainWrapper
import UIKit
import Web3Core

class ChangePasswordViewController: UIViewController {

  //MARK: - @IBOutlet
  @IBOutlet weak var lblChangePassword: UILabel!

  @IBOutlet weak var lblCurrentPassword: UILabel!

  @IBOutlet weak var txtCurrentPassword: UITextField!

  @IBOutlet weak var lblNewPassword: UILabel!

  @IBOutlet weak var txtNewPassword: UITextField!

  @IBOutlet weak var lblConfirmPassword: UILabel!

  @IBOutlet weak var txtConfirmPassword: UITextField!

  @IBOutlet weak var btnConfirm: UIButton!

  @IBOutlet weak var viewCurrentPassword: UIView!

  @IBOutlet weak var viewNewPassword: UIView!

  @IBOutlet weak var viewConfirmPassword: UIView!

  //MARK: - Local variable
  var customTitle: String?
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

  @IBAction func btnConfirmAction(_ sender: Any) {
    self.loader.isHidden = false
    if txtCurrentPassword.text?.isEmpty == true || txtNewPassword.text?.isEmpty == true
      || txtConfirmPassword.text?.isEmpty == true
    {
      self.loader.isHidden = true
      showAlert(message: "All fields are required")
      return
    }

    // Check if the new password and confirmed password match
    if txtNewPassword.text != txtConfirmPassword.text {
      self.loader.isHidden = true
      showAlert(message: "New password and confirmed password do not match")
      return
    }

    // Check if the new password meets the minimum length requirement
    if txtNewPassword.text?.count ?? 0 < 8 {
      self.loader.isHidden = true
      showAlert(message: "Password must be at least 8 characters long")
      return
    }

    if let account = WalletManager.shared.generateNewEthereumAccount() {
      print("Private Key: \(account.privateKey)")

      print("Public Key: \(account.publicKey)")

      print("Ethereum Address: \(account.address)")
      let password = txtNewPassword.text

      WalletManager.shared.deleteKeystore { result in
        //    self.loader.isHidden = true
        switch result {
        case .success:
          print("Keystore deleted successfully")
            KeychainWrapper.standard.remove(forKey: "keychain_address")
          do {

            let keystore = try WalletManager.shared.importWallet(
              privateKey: account.privateKey, publicKey: account.publicKey, password: password ?? ""
            )
            
            if keystore != nil {
              KeychainWrapper.standard.set(keystore?.address ?? "", forKey: "keychain_address")
              self.login(keyStoreAddress: keystore?.address ?? "", password: password ?? "")

            }

          } catch {
            // self.loader.isHidden = true
            print("An error occurred: \(error.localizedDescription)")
          }
        case .failure(let error):
          print("Error deleting keystore: \(error)")
          self.showAlert(message: "Error deleting keystore: \(error.localizedDescription)")
        }
      }
    }

  }

}
//MARK: - extension
extension ChangePasswordViewController {
  func initialLoads() {

    addCrossButton()
    setFonts()
    setDesign()
    localize()
  }
  func setFonts() {

  }
  func setDesign() {
    viewCurrentPassword.layer.cornerRadius = 15
    viewNewPassword.layer.cornerRadius = 15
    viewConfirmPassword.layer.cornerRadius = 15
    btnConfirm.layer.cornerRadius = 15
  }
  func localize() {

    lblChangePassword.text = Constants.string.changePassword.localize()
    lblCurrentPassword.text = Constants.string.currentPassword.localize()
    lblNewPassword.text = Constants.string.newPassword.localize()
    lblConfirmPassword.text = Constants.string.confirmPassword.localize()

    txtCurrentPassword.placeholder = Constants.string.enterYourCurrentPassword.localize()
    txtNewPassword.placeholder = Constants.string.enterYourNewPassword.localize()
    txtConfirmPassword.placeholder = Constants.string.enterConfirmPassword.localize()

    self.btnConfirm.setTitle(Constants.string.confirm.localize(), for: .normal)

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

      self.present(tabBarController, animated: true, completion: nil)

    }
  }
  func addCrossButton() {
    let headerView = CustomHeaderView()
    headerView.translatesAutoresizingMaskIntoConstraints = false
    headerView.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    headerView.title = customTitle  // Set the title dynamically
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

          self.setWalletToServer(
            adress: keyStoreAddress, path: "path", ecKeyPair: bip32Keystore, password: password)
        }
      } catch {

      }
    }
  }

  func setWalletToServer(
    adress: String?, path: String?, ecKeyPair: EthereumKeystoreV3, password: String
  ) {

    let parameters: [String: Any] = [
      "path": "path",
      "address": "\(String(describing: adress ?? ""))",
      "message": "\(MessageHelper.getMessage())",
      "signature":
        "\(SignatureHelper.getSignature(messageBytes: MessageHelper.getMessage().bytes, ecKeyPair: ecKeyPair, password: password) ?? "testSignature")",
    ]

    self.presenter?.post(api: .signUp, imageData: nil, parameters: parameters)
    //self.presenter?.post(api: .signUp, data: data)

  }
}

extension ChangePasswordViewController: PostViewProtocol {

  func onError(api: Base, message: String, statusCode code: Int) {
    self.loader.isHidden = true
    showAlert(message: message)
  }

  func getSignUp(api: Base, data: SignUpResponse?) {

    self.loader.isHidden = true
    if KeychainWrapper.standard.set(data?.auth_key ?? "", forKey: "keychain_auth_key")
      && KeychainWrapper.standard.set(data?.email ?? "", forKey: "keychain_email")
    {

      self.dismiss(animated: true)

    }

  }

}
