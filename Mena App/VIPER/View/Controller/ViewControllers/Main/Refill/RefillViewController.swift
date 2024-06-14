//
//  RefillViewController.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 11/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import UIKit

class RefillViewController: UIViewController {
    //MARK: - @IBOutlet
    @IBOutlet weak var lblAmount: UILabel!
    
    @IBOutlet weak var txtAmount: UITextField!
    
    @IBOutlet weak var lblCurrencyType: UILabel!
    
    @IBOutlet weak var txtSelectCurrency: UITextField!
    
    @IBOutlet weak var lblSelectCoin: UILabel!
    
    @IBOutlet weak var txtSelectCoin: UITextField!
    
    @IBOutlet weak var lblAccountCountry: UILabel!
    
    @IBOutlet weak var txtSelectYourAccountCountry: UITextField!
    
    @IBOutlet weak var viewAmount: UIView!
    
    @IBOutlet weak var viewCurrency: UIView!
    
    @IBOutlet weak var viewSelectCoin: UIView!
    
    @IBOutlet weak var viewAccountCountry: UIView!
    
    @IBOutlet weak var btnRefill: UIButton!
    
    @IBOutlet weak var btnRefillHistory: UIButton!
    
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
    
    @IBAction func btnRefillHistoryAction(_ sender: Any) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.AllRefillViewController) as? AllRefillViewController else{return}
        vc.modalPresentationStyle = .fullScreen
       
        present(vc, animated: true)
        
    }
    
    
}

//MARK: - extension
extension RefillViewController{
    func initialLoads(){
        localize()
        setDesign()
        setFonts()
        addCrossButton()
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
}
