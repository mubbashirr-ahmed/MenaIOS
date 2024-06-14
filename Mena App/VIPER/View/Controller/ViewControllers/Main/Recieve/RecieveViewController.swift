//
//  RecieveViewController.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 12/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import UIKit

class RecieveViewController: UIViewController {
    //MARK: - @IBOutlet
    @IBOutlet weak var viewQR: UIView!
    
    @IBOutlet weak var lblWalletAddress: UILabel!
    
    @IBOutlet weak var imgQR: UIImageView!
    
    @IBOutlet weak var lblRecieveNow: UILabel!
    
    
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
extension RecieveViewController{
    func initialLoads(){
        
        addCrossButton()
        setFonts()
        setDesign()
        localize()
    }
    func setFonts(){
        
    }
    func setDesign(){
        viewQR.layer.cornerRadius = 15
        
    }
    func localize(){
        lblRecieveNow.text = Constants.string.recieveNowBySharing.localize()
       
      
    }
    
    func addCrossButton(){
                let headerView = CustomHeaderView()
               headerView.translatesAutoresizingMaskIntoConstraints = false
               headerView.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        headerView.title = Constants.string.recieveWithQR.localize() // Set the title dynamically
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
