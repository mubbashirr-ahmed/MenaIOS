//
//  ChangeBankingDetailViewController.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 11/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import UIKit
//import iOSDropDown
import SwiftKeychainWrapper

class ChangeBankingDetailViewController: UIViewController {
    //MARK: - @IBOutlet
        
    @IBOutlet weak var lblAccountName: UILabel!
    
    @IBOutlet weak var txtAccountName: UITextField!
    
    @IBOutlet weak var lblSortCard: UILabel!
    
    @IBOutlet weak var txtSortCard: UITextField!
    
    @IBOutlet weak var lblAccountNumber: UILabel!
    
    @IBOutlet weak var txtAccountNumber: UITextField!
    
    @IBOutlet weak var lblAccountCountry: UILabel!
    
    @IBOutlet weak var txtAccountCountry: DropDown!
    
    @IBOutlet weak var btnUpdate: UIButton!
    
    @IBOutlet weak var viewAccountName: UIView!
    
    @IBOutlet weak var viewSortCard: UIView!
    
    @IBOutlet weak var viewAccountNumber: UIView!
    
    @IBOutlet weak var viewAccountCountry: UIView!
    
    
    //MARK: - Local variable
    var customTitle: String?
    let countryManager = CountryManager()
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
    
    
    @IBAction func btnUpdateAction(_ sender: Any) {
        guard let accountName = txtAccountName.text, !accountName.isEmpty else {
               showAlert(message: "Enter account name")
               return
           }
           
           guard let sortCard = txtSortCard.text, !sortCard.isEmpty else {
               showAlert(message: "Enter sort code")
               return
           }
           
           guard let accountNumber = txtAccountNumber.text, !accountNumber.isEmpty else {
               showAlert(message: "Enter account number")
               return
           }
           
           guard let selectedCountry = txtAccountCountry.text, !selectedCountry.isEmpty else {
               showAlert(message: "Please select your account country")
               return
           }
        let authKey = KeychainWrapper.standard.string(forKey: "keychain_auth_key") ?? ""
        let email = KeychainWrapper.standard.string(forKey: "keychain_email") ?? ""
        
        var bankDetail = BankDetail(auth_key: authKey, email: email, type: "update", accountName: accountName, sortCode: sortCard, accountNumber: accountNumber, accountCountry: selectedCountry)
        var params: [String: Any] = ["auth_key":"\(authKey)",
                                     "email":"\(email)",
                                     "sort-code":"\(sortCard)",
                                     "account-name":"\(accountName)",
                                     "account-country":"\(selectedCountry)",
                                     "account-number":"\(accountNumber)",
                                     "type":"update"]
        self.updateBankingDetail(params: params)
        
    }
    
}
//MARK: - extension
extension ChangeBankingDetailViewController{
    func initialLoads(){
        
        addCrossButton()
        setFonts()
        setDesign()
        localize()
        setDropDown()
    }
    func setFonts(){
        
    }
    func setDesign(){
        viewSortCard.layer.cornerRadius = 15
        viewAccountName.layer.cornerRadius = 15
        viewAccountNumber.layer.cornerRadius = 15
        viewAccountCountry.layer.cornerRadius = 15
        btnUpdate.layer.cornerRadius = 15
    }
    func localize(){
        lblAccountName.text = Constants.string.accountName.localize()
        lblSortCard.text = Constants.string.sortCard.localize()
        lblAccountNumber.text = Constants.string.accountNumber.localize()
        lblAccountCountry.text = Constants.string.accountCountry.localize()
        
        txtAccountName.placeholder = Constants.string.enterYourAccountName.localize()
        txtSortCard.placeholder = Constants.string.enterYourSortCard.localize()
        txtAccountNumber.placeholder = Constants.string.enterYourAccountNo.localize()
        txtAccountCountry.placeholder = Constants.string.selectYourAccountCountry.localize()
        
        self.btnUpdate.setTitle(Constants.string.update.localize(), for: .normal)
        
    }
    
    func addCrossButton(){
        
        let headerView = CustomHeaderView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        headerView.title = Constants.string.updateBankDetail.localize() // Set the title dynamically
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
    
    func setDropDown(){
        
        let countryList = countryManager.fetchCountries()
        txtAccountCountry.optionArray = countryList?.compactMap({
            $0.country
        }) ?? [""]
        txtAccountCountry.didSelect{(selectedText , index ,id) in
            
        }
    }
    
    func updateBankingDetail(params: [String: Any]){
        self.loader.isHidden = false
        self.presenter?.post(api: .bankDetail, imageData: nil, parameters: params)
    }
       
}
extension ChangeBankingDetailViewController: PostViewProtocol{
    func onError(api: Base, message: String, statusCode code: Int) {
        self.loader.isHidden = true
        showAlert(message: message)
    }
    func getBankRefillResponse(api: Base, data: BankRefillResponse?) {
        self.loader.isHidden = true
        showAlert(message: data?.result ?? "", title: "Success")
        self.txtSortCard.text = ""
        self.txtAccountName.text = ""
        self.txtAccountNumber.text = ""
        self.txtAccountCountry.text = ""
        self.txtSortCard.resignFirstResponder()
    
    }
    
}
