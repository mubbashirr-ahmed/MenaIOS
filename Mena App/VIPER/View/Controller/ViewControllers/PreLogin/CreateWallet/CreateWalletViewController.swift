//
//  CreateWalletViewController.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 08/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import UIKit

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

  //MARK: - LocalVariable
  var isPasswordVisible: Bool = false
  var isConfirmPasswordVisible: Bool = false

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

    Common.setFont(to: lblMenaWallet!, size: 32, font: .SemiBold)
    Common.setFont(to: lblNowItsOpen!, size: 16, font: .Medium)
    Common.setFont(to: lblWalletPassword!, size: 16, font: .Medium)
    Common.setFont(to: lblConfirmPassword!, size: 16, font: .Medium)

  }
  func localize() {
    self.lblMenaWallet.text = Constants.string.menaWallet.localize()
    self.lblNowItsOpen.text = Constants.string.nowItsEasyToOpen.localize()
    self.lblWalletPassword.text = Constants.string.walletPassword.localize()
    self.lblConfirmPassword.text = Constants.string.confirmPassword.localize()
    self.btnCreate.setTitle(Constants.string.create.localize(), for: .normal)

  }
  func setDesign() {
    viewWalletPassword.layer.cornerRadius = 15
    viewConfirmPassword.layer.cornerRadius = 15
    btnCreate.layer.cornerRadius = 15
    txtWalletPassword.isSecureTextEntry = true
    txtConfirmPassword.isSecureTextEntry = true

  }
}
