//
//  ChangeBankingDetailViewController.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 11/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import UIKit

class ChangeBankingDetailViewController: UIViewController {
    //MARK: - @IBOutlet
        
    @IBOutlet weak var lblAccountName: UILabel!
    
    @IBOutlet weak var txtAccountName: UITextField!
    
    @IBOutlet weak var lblSortCard: UILabel!
    
    @IBOutlet weak var txtSortCard: UITextField!
    
    @IBOutlet weak var lblAccountNumber: UILabel!
    
    @IBOutlet weak var txtAccountNumber: UITextField!
    
    @IBOutlet weak var lblAccountCountry: UILabel!
    
    @IBOutlet weak var txtAccountCountry: UITextField!
    
    @IBOutlet weak var btnUpdate: UIButton!
    
    @IBOutlet weak var viewAccountName: UIView!
    
    @IBOutlet weak var viewSortCard: UIView!
    
    @IBOutlet weak var viewAccountNumber: UIView!
    
    @IBOutlet weak var viewAccountCountry: UIView!
    
    
    
    
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
extension ChangeBankingDetailViewController{
    func initialLoads(){
        
        addCrossButton()
        setFonts()
        setDesign()
        localize()
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
}
