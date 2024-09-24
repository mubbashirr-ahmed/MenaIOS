//
//  TransactionHistoryViewController.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 09/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class TransactionHistoryViewController: UIViewController {

    //MARK: - @IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    //MARK: - localVariables
    let transactionManager = TransactionManager()
    let contractManager = ContractManager()
    var address : String?
    var isMenaResponse: Bool = false
    var isTokenResponse: Bool = false
    var menaDatasource : History?
    var tokenDatasource : History?
    var dataSource = [HistoryData]()
    var contractList = [Contracts]()
    private lazy var loader: UIView = {
      return createActivityIndicator(UIApplication.shared.keyWindow ?? self.view)
    }()
    
    
    //MARK: - @viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        initialLoads()
        // Do any additional setup after loading the view.
    }
   

}
extension TransactionHistoryViewController{
    func initialLoads() {
       
        tableView.register(UINib(nibName: XIB.Names.TransactionCell, bundle: nil), forCellReuseIdentifier: XIB.Names.TransactionCell)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        fetchCoreData()
        getAddress()
        fetchContracts()
    }
    func getAddress(){
        
        if KeychainWrapper.standard.string(forKey: "keychain_address") != nil{
            
            address = KeychainWrapper.standard.string(forKey: "keychain_address")?.stripHexPrefix()
            self.getMenaHistory(address: address ?? "")
          //  self.getContract()
        }
        else{
            if let account = WalletManager.shared.generateNewEthereumAccount() {
                print("Private Key: \(account.privateKey)")
                print("Public Key: \(account.publicKey)")
                print("Ethereum Address: \(account.address)")
                
                address = account.address.stripHexPrefix()
                self.getMenaHistory(address: address ?? "")
                
            }
        }
    }
    
    func fetchContracts(){
        
        if let transactions = contractManager.fetchContracts(){
            
            self.contractList = transactions
            
        }
    }
    func fetchCoreData(){
        if let transactions = transactionManager.fetchTransactions() {
            print("Transactions: \(transactions)")
            self.dataSource = transactions
            self.tableView.reloadData()
        }
    }
    func getMenaHistory(address: String){
        self.loader.isHidden = false
        var address = ["address":"\(address.addHexPrefix())"]
        self.presenter?.get(api: .menaHistory, parameters: address)
    }
    func getTokenHistory(address: String){
        self.loader.isHidden = false
        var address = ["address":"\(address.addHexPrefix())"]
        self.presenter?.get(api: .tokenHistory, parameters: address)
    }
    func setTableView(){
        self.tableView.reloadData()
    }
    
    func convertToCustomFormat(dateString: String) -> String? {
        // 1. Parse the ISO 8601 date string into a Date object
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = isoFormatter.date(from: dateString) {
            // 2. Format the Date object into the desired format
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC time zone
            dateFormatter.dateFormat = "dd.MM.yy HH:mm:ss" // Desired format
            
            return dateFormatter.string(from: date)
        } else {
            // Return nil if the date string couldn't be parsed
            return nil
        }
    }
}

extension TransactionHistoryViewController: PostViewProtocol{
    func onError(api: Base, message: String, statusCode code: Int) {
        self.loader.isHidden = true
    }
    func getTransactionHistory(api: Base, data: History?) {
        
        if api == .menaHistory{
            isMenaResponse = true
            menaDatasource = data
        }
        if api == .tokenHistory{
            self.loader.isHidden = true
            isTokenResponse = true
            tokenDatasource = data
        }
        if isMenaResponse && isTokenResponse{
            self.dataSource = (menaDatasource?.result ?? []) + (tokenDatasource?.result ?? [])
          
            self.setTableView()
        }
        else{
            getTokenHistory(address: self.address ?? "")
        }
    }
}


extension TransactionHistoryViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: XIB.Names.TransactionCell, for: indexPath) as? TransactionCell, self.dataSource.count > indexPath.row{
            // Configure your cell
            DispatchQueue.main.async {
                
                cell.viewBg.backgroundColor = .textFieldBackground  // Example configuration
//                cell.lblAmount.text = self.dataSource[indexPath.row].from_address == self.address?.addHexPrefix() ? "-\(String(describing: self.dataSource[indexPath.row].amount ?? 0.0))" : "+\(String(describing: self.dataSource[indexPath.row].amount ?? 0.0))"
                
                
                cell.lblAmount.text = {
                    let historyItem = self.dataSource[indexPath.row]
                    
                    // Find the corresponding contract for the contract_address in HistoryData
                    if let contract = self.contractList.first(where: { $0.address == historyItem.contract_address }) {
                        // Ensure amount and conversionRate are available
                        if let amount = historyItem.amount, let conversionRate = contract.decimalCount, conversionRate != 0 {
                            
                            // Calculate the amount in the converted currency
                            let adjustedAmount = amount / pow(10.0, Double(conversionRate))
                            
                            // Format the amount based on from_address condition
                            let prefix = historyItem.from_address == self.address?.addHexPrefix() ? "-" : "+"
                            return "\(prefix)\(String(format: "%.2f", adjustedAmount))"
                        }
                    }
                    
                    // Default behavior if contract is not found or invalid data
                    return "N/A"
                }()
                
                
                if let formattedDate = self.convertToCustomFormat(dateString: self.dataSource[indexPath.row].date ?? "") {
                    print("Formatted Date: \(formattedDate)")
                    cell.lblDate.text = formattedDate
                } else {
                    print("Failed to format date.")
                    cell.lblDate.text = "Failed to format date."
                }
                let address = self.dataSource[indexPath.row].from_address == self.address ? "\(String(describing: self.dataSource[indexPath.row].receive_address ?? ""))" : "\(String(describing: self.dataSource[indexPath.row].from_address ?? ""))"
                cell.lblHolderName.text = String(address.suffix(6))
            }
            return cell
            }
          return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

