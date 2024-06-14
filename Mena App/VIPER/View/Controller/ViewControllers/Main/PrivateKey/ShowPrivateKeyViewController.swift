//
//  ShowPrivateKeyViewController.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 12/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import UIKit

class ShowPrivateKeyViewController: UIViewController {
    //MARK: - @IBOutlet
    
    @IBOutlet weak var viewPrivacy: UIView!
    
    @IBOutlet weak var lblWarning: UILabel!
    
    @IBOutlet weak var lblIfYouHaveBeen: UILabel!
    
    @IBOutlet weak var btnShowKey: UIButton!
    
    @IBOutlet weak var lblPrivateKey: UILabel!
    
    @IBOutlet weak var viewPrivateKey: UIView!
    
    @IBOutlet weak var viewPublicKey: UIView!
    
    @IBOutlet weak var lblTapTpCopy: UILabel!
    
    @IBOutlet weak var lblPrivateKeyValue: UILabel!
    
    @IBOutlet weak var lblPublicKeyValue: UILabel!
    
    
    @IBOutlet weak var stackViewKeys: UIStackView!
    
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
            viewPrivacy.isHidden = false
            stackViewKeys.isHidden = true
        }
    
    
    @IBAction func btnShowKey(_ sender: Any) {
        viewPrivacy.isHidden = true
        stackViewKeys.isHidden = false
    }
    
}

//MARK: - extension
extension ShowPrivateKeyViewController{
    func initialLoads(){
        
        addCrossButton()
        localize()
        setDesign()
        setFonts()
        
    }
    func setFonts(){
        
    }
    func setDesign(){
        
        viewPrivacy.layer.cornerRadius = 15
        viewPublicKey.layer.cornerRadius = 15
        viewPrivateKey.layer.cornerRadius = 15
        btnShowKey.layer.cornerRadius = 15
//        btnQRCode.layer.cornerRadius = 11.05
    }
    func localize(){
        
//        lblSendCoin.text = Constants.string.sendCoin.localize()
//        lblAddress.text = Constants.string.address.localize()
//        lblSelectCoin.text = Constants.string.selectCoin.localize()
//        lblAmount.text = Constants.string.amount.localize()
//        
//        txtAddress.placeholder = Constants.string.enterYourAddress.localize()
//        txtSelectYourCoin.placeholder = Constants.string.selectYourCoin.localize()
//        txtAmount.placeholder = Constants.string.enterYourAmount.localize()
//        
//        self.btnSend.setTitle(Constants.string.send.localize(), for: .normal)
        
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
