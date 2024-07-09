//
//  AllRefillViewController.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 13/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import UIKit

class AllRefillViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Local variable
    var customTitle: String?
    let bankRefillManager = RefillManager()
    var refillList = [BankRefillResponse]()
        
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
extension AllRefillViewController{
    func initialLoads(){
  
        addCrossButton()
        setFonts()
        setDesign()
        localize()
        fetchRefills()
    }
    func setFonts(){
        
    }
    func setDesign(){
      //  viewQR.layer.cornerRadius = 15
        
    }
    func localize(){
      //  lblRecieveNow.text = Constants.string.recieveNowBySharing.localize()
       
      
    }
    
    func fetchRefills(){
        
        if let refills = bankRefillManager.fetchBankRefillResponses(){
            print("Refill: \(refills)")
            self.refillList = refills
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.reloadData()
        }
    }
    
    func addCrossButton(){
                let headerView = CustomHeaderView()
               headerView.translatesAutoresizingMaskIntoConstraints = false
               headerView.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        headerView.title = Constants.string.allRefills.localize() // Set the title dynamically
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
        self.dismiss(animated: true,completion: nil)
    }
}

extension AllRefillViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.refillList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "RefillHistoryCell") as? RefillHistoryCell{
            cell.lblHolderName.text = self.refillList[indexPath.row].result
            cell.lblRefillSubTitle.text = "\(String(describing: self.refillList[indexPath.row].date ?? Date()))"
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

class RefillHistoryCell: UITableViewCell{
   
    @IBOutlet weak var lblHolderName: UILabel!
    
    @IBOutlet weak var lblRefillSubTitle: UILabel!
    
    @IBOutlet weak var viewBg: UIView!
    
    override  func awakeFromNib() {
        
        lblHolderName.text = Constants.string.holderName.localize()
        lblRefillSubTitle.text = Constants.string.purpose.localize()
        viewBg.layer.cornerRadius = 15
        viewBg.backgroundColor = UIColor.textFieldBackground
    }
}
