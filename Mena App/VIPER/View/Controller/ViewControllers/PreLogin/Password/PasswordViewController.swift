//
//  PasswordViewController.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 08/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import SwiftKeychainWrapper
import UIKit

class PasswordViewController: UIViewController {
  //MARK: - @IBOutlet

  @IBOutlet weak var lblLogin: UILabel!

  @IBOutlet weak var lblEnterYourDetail: UILabel!

  @IBOutlet weak var lblPassword: UILabel!

  @IBOutlet weak var viewTextfield: UIView!

  @IBOutlet weak var txtPassword: UITextField!

  @IBOutlet weak var btnEyeToggle: UIButton!

  @IBOutlet weak var btnUnlock: UIButton!

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var viewScroll: UIView!
    
  //MARK: - LocalVariable
  var isPasswordVisible: Bool = false
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
    txtPassword.text = ""

  }
    
    //MARK: -viewWillLayoutSubviews
        override func viewWillLayoutSubviews() {
            super.viewWillLayoutSubviews()
            self.setFrame()
        }

  @IBAction func btnEyeToggleAction(_ sender: Any) {

    isPasswordVisible.toggle()  // Toggle the state

    if isPasswordVisible {
      btnEyeToggle.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
      txtPassword.isSecureTextEntry = false
    } else {
      btnEyeToggle.setImage(UIImage(systemName: "eye.fill"), for: .normal)
      txtPassword.isSecureTextEntry = true
    }
  }

  @IBAction func btnUnlockAction(_ sender: Any) {

    guard let password = txtPassword.text, !password.isEmpty else {
      print("Password cannot be empty")
      showAlert(message: "Password cannot be empty")
      return
    }
    self.loader.isHidden = false
    WalletManager.shared.loginWithPassword(password: password) { result in
      DispatchQueue.main.async {

        self.loader.isHidden = true
        switch result {
        case .success(let address):
          print("Logged in with address: \(address)")
          KeychainWrapper.standard.set(password ?? "", forKey: "keychain_password")
          self.showTabBarController()
        case .failure(let error):
          print("Error logging in: \(error.localizedDescription)")
          self.showAlert(message: error.localizedDescription)
          self.push(id: Storyboard.Ids.CreateWalletViewController, animation: true)
        // Handle error gracefully, e.g., show alert to user
        }

      }
    }

    // self.push(id: Storyboard.Ids.CreateWalletViewController, animation: true)
  }

}

//MARK: - extension
extension PasswordViewController {
  func initialLoads() {
    localize()
    setFont()
    setDesign()
  }
  func setFont() {

    //    Common.setFont(to: lblLogin!, size: 32, font: .SemiBold)
    //    Common.setFont(to: lblEnterYourDetail!, size: 16, font: .Medium)
    //    Common.setFont(to: lblPassword!, size: 16, font: .Medium)

  }
  func localize() {
    self.lblLogin.text = Constants.string.login.localize()
    self.lblEnterYourDetail.text = Constants.string.enterYourDetail.localize()
    self.lblPassword.text = Constants.string.password.localize()
    self.btnUnlock.setTitle(Constants.string.unlock.localize(), for: .normal)

  }
  func setDesign() {
    viewTextfield.layer.cornerRadius = 15
    btnUnlock.layer.cornerRadius = 15
    txtPassword.isSecureTextEntry = true
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
    
    private func setFrame() {
        
        self.scrollView.frame = self.scrollView.frame
        self.scrollView.addSubview(viewScroll)
        self.viewScroll.frame = self.scrollView.bounds
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height * 1.5)

    }
}
