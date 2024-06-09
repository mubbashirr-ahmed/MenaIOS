//
//  PasswordViewController.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 08/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

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

  //MARK: - LocalVariable
  var isPasswordVisible: Bool = false

  //MARK: -viewDidLoad
  override func viewDidLoad() {
    super.viewDidLoad()

    initialLoads()

  }
  //MARK: -viewWillAppear
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    self.navigationController?.isNavigationBarHidden = true

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

    self.push(id: Storyboard.Ids.CreateWalletViewController, animation: true)
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

    Common.setFont(to: lblLogin!, size: 32, font: .SemiBold)
    Common.setFont(to: lblEnterYourDetail!, size: 16, font: .Medium)
    Common.setFont(to: lblPassword!, size: 16, font: .Medium)

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
}
