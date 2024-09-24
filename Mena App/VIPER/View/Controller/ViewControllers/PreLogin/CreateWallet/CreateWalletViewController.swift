//
//  CreateWalletViewController.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 08/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import SwiftKeychainWrapper
import UIKit
import Web3Core

class CreateWalletViewController: UIViewController {
  //MARK: - @IBOutlet

  @IBOutlet weak var lblMenaWallet: UILabel!

  @IBOutlet weak var lblNowItsOpen: UILabel!

  @IBOutlet weak var lblWalletPassword: UILabel!

  @IBOutlet weak var txtWalletPassword: UITextField!

  @IBOutlet weak var lblConfirmPassword: UILabel!

  @IBOutlet weak var txtConfirmPassword: UITextField!

  @IBOutlet weak var btnCreate: UIButton!

  @IBOutlet weak var btnPasswordEyeToggle: UIButton!

  @IBOutlet weak var btnConfirmPasswordEyeToggle: UIButton!

  @IBOutlet weak var viewWalletPassword: UIView!

  @IBOutlet weak var viewConfirmPassword: UIView!

  @IBOutlet weak var btnImport: UIButton!
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var viewScroll: UIView!
    

  //MARK: - LocalVariable
  var isPasswordVisible: Bool = false
  var isConfirmPasswordVisible: Bool = false
  private lazy var loader: UIView = {
    return createActivityIndicator(UIApplication.shared.keyWindow ?? self.view)
  }()

  //MARK: -viewDidLoad
  override func viewDidLoad() {
    super.viewDidLoad()

    initialLoads()

  }
  //MARK: -viewWillAppear
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    self.navigationController?.isNavigationBarHidden = true
    txtWalletPassword.text = ""
    txtConfirmPassword.text = ""

  }
//MARK: -viewWillLayoutSubviews
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.setFrame()
    }

  @IBAction func btnPasswordEyeToggleAction(_ sender: Any) {
    isPasswordVisible.toggle()  // Toggle the state

    if isPasswordVisible {
      btnPasswordEyeToggle.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
      txtWalletPassword.isSecureTextEntry = false
    } else {
      btnPasswordEyeToggle.setImage(UIImage(systemName: "eye.fill"), for: .normal)
      txtWalletPassword.isSecureTextEntry = true
    }
  }

  @IBAction func btnConfirmPasswordEyeToogleAction(_ sender: Any) {
    isConfirmPasswordVisible.toggle()  // Toggle the state

    if isConfirmPasswordVisible {
      btnConfirmPasswordEyeToggle.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
      txtConfirmPassword.isSecureTextEntry = false
    } else {
      btnConfirmPasswordEyeToggle.setImage(UIImage(systemName: "eye.fill"), for: .normal)
      txtConfirmPassword.isSecureTextEntry = true
    }

  }

  @IBAction func btnCreateAction(_ sender: Any) {

    guard let password = txtWalletPassword.text, !password.isEmpty else {
      print("Password cannot be empty")
      showAlert(message: "Password cannot be empty")
      return
    }

    guard let confirmPassword = txtConfirmPassword.text, !confirmPassword.isEmpty else {
      print("Confirm Password cannot be empty")
      showAlert(message: "Confirm Password cannot be empty")
      return
    }

    guard password == confirmPassword else {
      print("Passwords do not match")
      showAlert(message: "Passwords do not match")
      return
    }
    guard password.count >= 8 else {
      print("Password must be at least 8 characters long")
      showAlert(message: "Password must be at least 8 characters long")
      return
    }

    self.loader.isHidden = false

    let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let keystorePath = userDir + "/keystore/key.json"
    print("Path login wallet: \(keystorePath)")

    let keystoreURL = URL(fileURLWithPath: keystorePath)
      


    WalletManager.shared.initializeWallet(password: password) { result in

      switch result {
      case .success(let address):
        print("Wallet created with address: \(address)")

        if FileManager.default.fileExists(atPath: keystorePath) {
          print("Keystore file exists at path: \(keystorePath)")

          do {
            let keystoreData = try Data(contentsOf: keystoreURL)
            print("Keystore data loaded successfully from file.")
            if let bip32Keystore = EthereumKeystoreV3(keystoreData) {
            let checkSumAddress = EthereumAddress.toChecksumAddress(address)
                print("CheckSum Address : \(checkSumAddress)")
              self.setWalletToServer(
                adress: checkSumAddress, path: "path", ecKeyPair: bip32Keystore, password: password)
            }
          } catch {

          }
        }

      case .failure(let error):
        print("Error creating wallet: \(error)")
      }
    }

  }
  @IBAction func btnImportAction(_ sender: Any) {
    guard
      let importController = Router.main.instantiateViewController(
        withIdentifier: Storyboard.Ids.ImportWalletViewController) as? ImportWalletViewController
    else { return }
    importController.modalPresentationStyle = .fullScreen
    present(importController, animated: true)
  }

}
//MARK: - extension
extension CreateWalletViewController {
  func initialLoads() {
    localize()
    setFont()
    setDesign()
  }
  func setFont() {

    //    Common.setFont(to: lblMenaWallet!, size: 32, font: .SemiBold)
    //    Common.setFont(to: lblNowItsOpen!, size: 16, font: .Medium)
    //    Common.setFont(to: lblWalletPassword!, size: 16, font: .Medium)
    //    Common.setFont(to: lblConfirmPassword!, size: 16, font: .Medium)

  }
  func localize() {

    self.lblMenaWallet.text = Constants.string.menaWallet.localize()
    self.lblNowItsOpen.text = Constants.string.nowItsEasyToOpen.localize()
    self.lblWalletPassword.text = Constants.string.walletPassword.localize()
    self.lblConfirmPassword.text = Constants.string.confirmPassword.localize()
    self.btnCreate.setTitle(Constants.string.create.localize(), for: .normal)
    self.btnImport.setTitle(Constants.string.importt.localize(), for: .normal)

  }
  func setDesign() {
   // self.view.dismissKeyBoardonTap()
    viewWalletPassword.layer.cornerRadius = 15
    viewConfirmPassword.layer.cornerRadius = 15
    btnCreate.layer.cornerRadius = 15
    btnImport.layer.cornerRadius = 15
    txtWalletPassword.isSecureTextEntry = true
    txtConfirmPassword.isSecureTextEntry = true

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
    //154.198.70.6
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

      print("parameters : ", parameters)
    self.presenter?.post(api: .signUp, imageData: nil, parameters: parameters)
    //self.presenter?.post(api: .signUp, data: data)

  }
  func getMessageBytes(from message: String) -> [UInt8]? {
    guard let data = message.data(using: .utf8) else {
      return nil
    }
    return [UInt8](data)
  }
    private func setFrame() {
        
        self.scrollView.frame = self.scrollView.frame
        self.scrollView.addSubview(viewScroll)
        self.viewScroll.frame = self.scrollView.bounds
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height * 1.5)

    }
}
extension CreateWalletViewController: PostViewProtocol {

  func onError(api: Base, message: String, statusCode code: Int) {
    self.loader.isHidden = true
    showAlert(message: message)
  }

  func getSignUp(api: Base, data: SignUpResponse?) {
    self.loader.isHidden = true
      if data?.error == nil{
          if KeychainWrapper.standard.set(data?.auth_key ?? "", forKey: "keychain_auth_key")
                && KeychainWrapper.standard.set(data?.email ?? "", forKey: "keychain_email")
          {
              self.push(id: Storyboard.Ids.PasswordViewController, animation: true)
          }
      }
      else{
          print("Something went wrong to create wallet")
      }
  }

}
