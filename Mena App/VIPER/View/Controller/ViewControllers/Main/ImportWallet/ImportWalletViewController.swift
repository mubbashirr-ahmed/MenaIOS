//
//  ImportWalletViewController.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 11/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import UIKit

class ImportWalletViewController: UIViewController {

    //MARK: - @IBOutlet
        
    
    @IBOutlet weak var lblImportExistingWallet: UILabel!
    
    @IBOutlet weak var lblNowItsOpen: UILabel!
    
    @IBOutlet weak var btnMenamonicWord: UIButton!
    
    @IBOutlet weak var btnPrivateKey: UIButton!
    
        
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
    @IBAction func btnMenamonicAction(_ sender: Any) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.ImportMnemonicViewController) as? ImportMnemonicViewController else{return}
        vc.modalPresentationStyle = .fullScreen
       
        present(vc, animated: true)
    }
    
    
    @IBAction func btnPrivateKeyAction(_ sender: Any) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.ImportPrivateKeyViewController) as? ImportPrivateKeyViewController else{return}
        vc.modalPresentationStyle = .fullScreen
       
        present(vc, animated: true)
    }
    
}
//MARK: - extension
extension ImportWalletViewController{
    func initialLoads(){
        
        localize()
        setFonts()
        setDesign()
        addCrossButton()
        
    }
    func setFonts(){
        
    }
    func setDesign(){
       
        btnMenamonicWord.layer.cornerRadius = 15
        btnPrivateKey.layer.cornerRadius = 15
        
    }
    func localize(){
        self.lblImportExistingWallet.text = Constants.string.importExistingWallet.localize()
        self.lblNowItsOpen.text = Constants.string.nowItsOpenToYourExisting.localize()
        self.btnPrivateKey.setTitle(Constants.string.privateKey.localize(), for: .normal)
        self.btnMenamonicWord.setTitle(Constants.string.mnemonicWords.localize(), for: .normal)
    }
    func addCrossButton(){
                let headerView = CustomHeaderView()
                headerView.translatesAutoresizingMaskIntoConstraints = false
                headerView.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
                headerView.title = Constants.string.importExistingWallet.localize() // Set the title dynamically
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
