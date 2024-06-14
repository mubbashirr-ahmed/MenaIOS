//
//  ChangePasswordViewController.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 11/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import UIKit

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
        backButtonTapped()
    }
    
}
//MARK: - extension
extension ChangePasswordViewController{
    func initialLoads(){
        
        addCrossButton()
        setFonts()
        setDesign()
        localize()
    }
    func setFonts(){
        
    }
    func setDesign(){
        viewCurrentPassword.layer.cornerRadius = 15
        viewNewPassword.layer.cornerRadius = 15
        viewConfirmPassword.layer.cornerRadius = 15
        btnConfirm.layer.cornerRadius = 15
    }
    func localize(){
        
        lblChangePassword.text = Constants.string.changePassword.localize()
        lblCurrentPassword.text = Constants.string.currentPassword.localize()
        lblNewPassword.text = Constants.string.newPassword.localize()
        lblConfirmPassword.text = Constants.string.confirmPassword.localize()
        
        txtCurrentPassword.placeholder = Constants.string.enterYourCurrentPassword.localize()
        txtNewPassword.placeholder = Constants.string.enterYourNewPassword.localize()
        txtConfirmPassword.placeholder = Constants.string.enterConfirmPassword.localize()
        
        self.btnConfirm.setTitle(Constants.string.confirm.localize(), for: .normal)
        
    }
    func addCrossButton(){
                let headerView = CustomHeaderView()
               headerView.translatesAutoresizingMaskIntoConstraints = false
               headerView.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
               headerView.title = customTitle // Set the title dynamically
               view.addSubview(headerView)

               // Add constraints to the header view
               NSLayoutConstraint.activate([
                   headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                   headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                   headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                   headerView.heightAnchor.constraint(equalToConstant: 60)
               ])
    }
    
    @objc func backButtonTapped() {
            self.dismiss(animated: true, completion: nil)
    }
}
