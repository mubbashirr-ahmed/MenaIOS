//
//  ImportPrivateKeyViewController.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 11/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import UIKit

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
    }
    
}
//MARK: - extension
extension ImportPrivateKeyViewController{
    func initialLoads(){
        localize()
        setFonts()
        setDesign()
        addCrossButton()
    }
    func setFonts(){
        
    }
    func setDesign(){
        btnImport.layer.cornerRadius = 15
        viewImport.layer.cornerRadius = 15
        viewPublic.layer.cornerRadius = 15
        viewWalletPassword.layer.cornerRadius = 15
        viewWalletConfirmPassword.layer.cornerRadius = 15
        
    }
    func localize(){
        lblImportUsing.text = Constants.string.importUsingPrivateKey.localize()
        self.txtImport.placeholder = Constants.string.enterPrivateKey.localize()
        self.txtPublic.placeholder = Constants.string.enterPublicKey.localize()
        self.txtPassword.placeholder = Constants.string.enterYourWalletPassword.localize()
        self.txtConfirmPassword.placeholder = Constants.string.enterConfirmPassword.localize()
    }
    
    func addCrossButton(){
                let headerView = CustomHeaderView()
               headerView.translatesAutoresizingMaskIntoConstraints = false
               headerView.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        headerView.title = Constants.string.privateKey.localize() // Set the title dynamically
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
