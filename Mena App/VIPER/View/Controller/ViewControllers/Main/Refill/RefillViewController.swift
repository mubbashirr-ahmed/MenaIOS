//
//  RefillViewController.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 11/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import UIKit
//import iOSDropDown
import SwiftKeychainWrapper

class RefillViewController: UIViewController {
    //MARK: - @IBOutlet
    @IBOutlet weak var lblAmount: UILabel!
    
    @IBOutlet weak var txtAmount: UITextField!
    
    @IBOutlet weak var lblCurrencyType: UILabel!
    
    @IBOutlet weak var txtSelectCurrency: DropDown!
    
    @IBOutlet weak var lblSelectCoin: UILabel!
    
    @IBOutlet weak var txtSelectCoin: DropDown!
    
    @IBOutlet weak var lblAccountCountry: UILabel!
    
    @IBOutlet weak var txtSelectYourAccountCountry: DropDown!
    
    @IBOutlet weak var viewAmount: UIView!
    
    @IBOutlet weak var viewCurrency: UIView!
    
    @IBOutlet weak var viewSelectCoin: UIView!
    
    @IBOutlet weak var viewAccountCountry: UIView!
    
    @IBOutlet weak var btnRefill: UIButton!
    
    @IBOutlet weak var btnRefillHistory: UIButton!
    
    @IBOutlet weak var btnCurrencyType: UIButton!
    
    
    
    
    //MARK: - Local variable
    
    var customTitle: String?
    let bankRefillManager = RefillManager()
    let countryManager = CountryManager()
    let currencyManager = CurrencyManager()
    let transactionManager = TransactionManager()
    let contractManager = ContractManager()
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
    
    @IBAction func btnRefillHistoryAction(_ sender: Any) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.AllRefillViewController) as? AllRefillViewController else{return}
        vc.modalPresentationStyle = .fullScreen
       
        present(vc, animated: true)
        
    }
   
    
    @IBAction func btnRefillAction(_ sender: Any) {
        
          guard let amount = txtAmount.text, !amount.isEmpty else {
               showAlert(message: "Enter amount")
               return
           }
           
           guard let selectedCurrency = txtSelectCurrency.text, !selectedCurrency.isEmpty else {
            showAlert(message: "Please select currency")
            return
           }
        
           guard let selectedCoin = txtSelectCoin.text, !selectedCoin.isEmpty else {
               showAlert(message: "Please select coin")
               return
           }
           
           
           guard let selectedCountry = txtSelectYourAccountCountry.text, !selectedCountry.isEmpty else {
               showAlert(message: "Please select your account country")
               return
           }
        let authKey = KeychainWrapper.standard.string(forKey: "keychain_auth_key") ?? ""
        let email = KeychainWrapper.standard.string(forKey: "keychain_email") ?? ""
        
        let params:[String:Any] = [
            "auth_key":"\(String(describing: authKey))",
            "email":"\(String(describing: email))",
            "type":"buy",
            "coin":"\(selectedCoin)",
            "amount":"\(amount)",
            "country":"\(selectedCountry)",
            "currency-type":"\(selectedCurrency)"]
        
        self.reFillBalance(refillRequest: params)
    }
    
    
}

//MARK: - extension
extension RefillViewController{
    func initialLoads(){
        localize()
        setDesign()
        setFonts()
        addCrossButton()
        setDropDown()
    }
    func setFonts(){
        
    }
    func setDesign(){
        viewAmount.layer.cornerRadius = 15
        viewCurrency.layer.cornerRadius = 15
        viewSelectCoin.layer.cornerRadius = 15
        viewAccountCountry.layer.cornerRadius = 15
        btnRefill.layer.cornerRadius = 15
    }
    func localize(){
        lblAmount.text = Constants.string.amount.localize()
        lblCurrencyType.text = Constants.string.currencyType.localize()
        lblSelectCoin.text = Constants.string.selectCoin.localize()
        lblAccountCountry.text = Constants.string.accountCountry.localize()
        
        txtAmount.placeholder = Constants.string.enterYourAmount.localize()
        txtSelectCurrency.placeholder = Constants.string.selectYourCurrency.localize()
        txtSelectCoin.placeholder = Constants.string.selectYourCoin.localize()
        txtSelectYourAccountCountry.placeholder = Constants.string.selectYourAccountCountry.localize()
        
        self.btnRefill.setTitle(Constants.string.re_Fill.localize(), for: .normal)
        
    }
    func addCrossButton(){
                let headerView = CustomHeaderView()
               headerView.translatesAutoresizingMaskIntoConstraints = false
               headerView.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
                headerView.title = Constants.string.allRefills.localize() // Set the title dynamically
               view.addSubview(headerView)
                view.addSubview(btnRefillHistory)

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
        let currencyList = currencyManager.fetchCurrencies()
        let contractList = contractManager.fetchContracts()
        
        txtSelectCurrency.optionArray = contractList?.compactMap({
            $0.currencyName
        }) ?? [""]
        
        txtSelectCurrency.didSelect{(selectedText , index ,id) in
     
        }
        
        txtSelectCoin.optionArray = currencyList?.compactMap({
            $0.fiatCurrency
        }) ?? [""]
        
        txtSelectCoin.didSelect{(selectedText , index ,id) in
       
        }
        
        txtSelectYourAccountCountry.optionArray = countryList?.compactMap({
            $0.country
        }) ?? [""]
        txtSelectYourAccountCountry.didSelect{(selectedText , index ,id) in

        }
    }
    
    func reFillBalance(refillRequest: [String:Any]){
        self.loader.isHidden = false
       
        self.presenter?.post(api: .createTrade, imageData: nil, parameters: refillRequest)
    }

}

extension RefillViewController: PostViewProtocol{
    func onError(api: Base, message: String, statusCode code: Int) {
        self.loader.isHidden = true
        showAlert(message: message)
    }
    func getBankRefillResponse(api: Base, data: BankRefillResponse?) {
        self.loader.isHidden = true
        
        if bankRefillManager.createBankRefillResponse(data!) {
            print("Bank refill response saved successfully")
        } else {
            print("Error creating bank refill response")
        }
        showAlert(message: data?.result ?? "",title: "Success")
        
        self.txtAmount.text = ""
        self.txtSelectCurrency.text = ""
        self.txtSelectCoin.text = ""
        self.txtSelectYourAccountCountry.text = ""
    }
    
}
