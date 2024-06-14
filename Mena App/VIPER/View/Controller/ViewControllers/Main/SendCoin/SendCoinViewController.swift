//
//  SendCoinViewController.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 11/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import UIKit

class SendCoinViewController: UIViewController {
    //MARK: - @IBOutlet
        
    @IBOutlet weak var lblSendCoin: UILabel!
    
    @IBOutlet weak var lblAddress: UILabel!
    
    @IBOutlet weak var lblSelectCoin: UILabel!
    
    @IBOutlet weak var lblAmount: UILabel!
    
    @IBOutlet weak var txtAddress: UITextField!
    
    @IBOutlet weak var txtSelectYourCoin: UITextField!
    
    @IBOutlet weak var txtAmount: UITextField!
    
    @IBOutlet weak var btnQRCode: UIButton!
    
    @IBOutlet weak var btnSend: UIButton!
    
    @IBOutlet weak var viewAddress: UIView!
    
    @IBOutlet weak var viewSelectCoin: UIView!
    
    @IBOutlet weak var viewAmount: UIView!
    
    
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
extension SendCoinViewController{
    func initialLoads(){
        
        addCrossButton()
        localize()
        setDesign()
        setFonts()
        
    }
    func setFonts(){
        
    }
    func setDesign(){
        
        viewAddress.layer.cornerRadius = 15
        viewSelectCoin.layer.cornerRadius = 15
        viewAmount.layer.cornerRadius = 15
        btnSend.layer.cornerRadius = 15
        btnQRCode.layer.cornerRadius = 11.05
    }
    func localize(){
        
        lblSendCoin.text = Constants.string.sendCoin.localize()
        lblAddress.text = Constants.string.address.localize()
        lblSelectCoin.text = Constants.string.selectCoin.localize()
        lblAmount.text = Constants.string.amount.localize()
        
        txtAddress.placeholder = Constants.string.enterYourAddress.localize()
        txtSelectYourCoin.placeholder = Constants.string.selectYourCoin.localize()
        txtAmount.placeholder = Constants.string.enterYourAmount.localize()
        
        self.btnSend.setTitle(Constants.string.send.localize(), for: .normal)
        
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
