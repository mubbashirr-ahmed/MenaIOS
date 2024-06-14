//
//  ImportMnemonicViewController.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 12/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import UIKit

class ImportMnemonicViewController: UIViewController {
    //MARK: - @IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var btnImport: UIButton!
    
    //MARK: - Local variable
    var customTitle: String?
    var counter = 0
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
extension ImportMnemonicViewController{
    func initialLoads(){
        
        addCrossButton()
        setFonts()
        setDesign()
        localize()
        tableView.delegate = self
        tableView.dataSource = self
    }
    func setFonts(){
        
    }
    func setDesign(){
        btnImport.layer.cornerRadius = 15
        
    }
    func localize(){
        
        self.btnImport.setTitle(Constants.string.importt.localize(), for: .normal)
      
    }
    
    func addCrossButton(){
                let headerView = CustomHeaderView()
               headerView.translatesAutoresizingMaskIntoConstraints = false
               headerView.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        headerView.title = Constants.string.importUsingMnemonicWords.localize() // Set the title dynamically
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

extension ImportMnemonicViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 12
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MnemonicCell") as? MnemonicCell{
            
            counter = counter + 1
            cell.lblFirst.text = "\(counter)."
            counter = counter + 1
            cell.lblSecond.text = "\(counter)."
            if counter == 24 {
                counter = 0
            }
            
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

class MnemonicCell: UITableViewCell{
    
    @IBOutlet weak var lblFirst: UILabel!
    
    @IBOutlet weak var lblSecond: UILabel!
    
    @IBOutlet weak var txtFirst: UITextField!
    
    @IBOutlet weak var txtSecond: UITextField!
}
