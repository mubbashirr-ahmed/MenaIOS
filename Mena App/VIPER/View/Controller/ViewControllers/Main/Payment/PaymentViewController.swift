//
//  PaymentViewController.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 09/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import UIKit

class PaymentViewController: UIViewController {
    @IBOutlet weak var viewScanQR: UIView!
    
    @IBOutlet weak var viewNFC: UIView!
    
    @IBOutlet weak var lblScanWithQR: UILabel!
    
    @IBOutlet weak var lblNFC: UILabel!
    
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
extension PaymentViewController{
    func initialLoads(){
        
        
        setFonts()
        setDesign()
        localize()
        addGesture()
    }
    func setFonts(){
        
    }
    func setDesign(){
      
        
    }
    func localize(){
        lblScanWithQR.text = Constants.string.scanWithQR.localize()
        lblNFC.text = Constants.string.NFC.localize()
      
    }
    
    func addGesture(){
        viewScanQR.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewScanAction)))
        viewNFC.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewNFCAction)))
    }
    
    @objc func viewScanAction(){
        
    }
    
    @objc func viewNFCAction(){
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.WaitingNFCViewController) as? WaitingNFCViewController{
            vc.modalPresentationStyle = .fullScreen
           
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func addCrossButton(){
                let headerView = CustomHeaderView()
               headerView.translatesAutoresizingMaskIntoConstraints = false
               headerView.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        headerView.title = Constants.string.NFC.localize() // Set the title dynamically
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
