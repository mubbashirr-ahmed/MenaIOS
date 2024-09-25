//
//  HomeViewController.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 09/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import UIKit
import Web3Core
import SwiftKeychainWrapper

class HomeViewController: UIViewController {

  //MARK: - @IBOutlet

  @IBOutlet weak var tableView: UITableView!

  @IBOutlet weak var viewRecieve: UIView!

  @IBOutlet weak var viewSend: UIView!

  @IBOutlet weak var viewRefill: UIView!
    
  @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var lblMenaWalletBalance: UILabel!
    
  //MARK: - Local variables
    let balanceManager = BalanceManager()
    let countryManager = CountryManager()
    let currencyManager = CurrencyManager()
    let transactionManager = TransactionManager()
    let contractManager = ContractManager()
    var address : String?
    var isMenaResponse: Bool = false
    var isTokenResponse: Bool = false
    var menaDatasource : History?
    var tokenDatasource : History?
    var dataSource = [HistoryData]()
    var balanceList = [BalanceEntity]()
    var contractList = [Contracts]()
   // var menaBalance = 0.0
    private lazy var loader: UIView = {
      return createActivityIndicator(UIApplication.shared.keyWindow ?? self.view)
    }()

  //MARK: - viewDidLoad
    override func viewDidLoad()   {
    super.viewDidLoad()

    tableView.register(
      UINib(nibName: XIB.Names.TransactionCell, bundle: nil),
      forCellReuseIdentifier: XIB.Names.TransactionCell)
         initialLoads()

    // Do any additional setup after loading the view.
  }

}

//MARK: - extension
extension HomeViewController {
    func initialLoads()   {
      
    setFont()
    setDesign()
    addGesture()
    fetchCoreData()
    fetchContracts()
    fetchBalanceList()
    getAddress()
    getCountryCurrency()
    Task { @MainActor in
        await self.getMenaBalance()
    }
         
  }

  func setFont() {

  }
  func setDesign() {
      
    viewSend.layer.cornerRadius = 12
    viewRecieve.layer.cornerRadius = 12
    viewRefill.layer.cornerRadius = 12
  }
  
  func addGesture() {
      
      viewSend.isUserInteractionEnabled = true
      viewRefill.isUserInteractionEnabled = true
      viewRecieve.isUserInteractionEnabled = true
      viewSend.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(viewSendAction)))
      viewRefill.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(viewRefillAction)))
      viewRecieve.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(viewRecieveAction)))
  }
  @objc func viewSendAction() {
      
      if let vc = self.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.SendCoinViewController) as? SendCoinViewController{
          vc.modalPresentationStyle = .fullScreen
          vc.customTitle = Constants.string.send.localize()
          self.present(vc, animated: true, completion: nil)
      }

  }
  @objc func viewRefillAction() {
      
      if let vc = self.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.RefillViewController) as? RefillViewController{
          vc.modalPresentationStyle = .fullScreen
          vc.customTitle = Constants.string.refill.localize()
          self.present(vc, animated: true, completion: nil)
      }
  }
  @objc func viewRecieveAction() {
      
      if let vc = self.storyboard?.instantiateViewController(withIdentifier: Storyboard.Ids.RecieveViewController) as? RecieveViewController{
          vc.modalPresentationStyle = .fullScreen
          vc.customTitle = Constants.string.recieveWithQR.localize()
          self.present(vc, animated: true, completion: nil)
      }
  }
    func fetchCoreData(){
        
        if let transactions = transactionManager.fetchTransactions() {
            print("Transactions: \(transactions)")
            self.dataSource = transactions
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.reloadData()
        }
    }
    func getAddress(){
        
        if KeychainWrapper.standard.string(forKey: "keychain_address") != nil{
            
            address = KeychainWrapper.standard.string(forKey: "keychain_address")?.stripHexPrefix()
            self.getMenaHistory(address: address ?? "")
            self.getContract()
        }
        else{
            
            if let account = WalletManager.shared.generateNewEthereumAccount() {
                print("Private Key: \(account.privateKey)")
                print("Public Key: \(account.publicKey)")
                print("Ethereum Address: \(account.address)")
                KeychainWrapper.standard.set(account.address, forKey: "keychain_address")
                address = account.address.stripHexPrefix()
                self.getMenaHistory(address: address ?? "")
                self.getContract()
                
            }
        }
    }
    func getMenaBalance() async {
        let localAddress = "0x\(self.address ?? "")"
        try? await WalletManager.shared.getWalletBalance(walletAddress: localAddress) { balance in
            if let balance = balance {
                print("Wallet balance: \(balance) ETH")
                DispatchQueue.main.async {
                    menaBalance = balance
                    let totalMenaBalance = self.calculateMenaBalance(from: self.balanceList)
                    print("Total MENA Balance: \(totalMenaBalance)")
                    let roundedAmount = String(format: "%.2f", menaBalance)
                    
                    self.lblMenaWalletBalance.text = "\(roundedAmount) ETH"
                    
                }
              
            }
            else {
                DispatchQueue.main.async {
                    
                    self.lblMenaWalletBalance.text = "0 ETH"
                }
      
                print("Failed to get wallet balance")
            }
        }
    }
    
    
    func calculateMenaBalance(from balanceList: [BalanceEntity]) -> Double {
        
        
        for balance in balanceList {
            if let balanceAmount = balance.balance,
               let conversionRate = balance.conversionRate,
               conversionRate != 0, balanceAmount > 0 {  // Ensure the conversion rate is not zero to avoid division by zero
                
                // Convert balance to USD
                let currencyInUSD = balanceAmount / conversionRate
                
                // Convert USD to MENA (assuming 1.55 conversion rate to MENA)
                let currencyInMena = currencyInUSD / conversionRate
                
                // Add to menaBalance
                menaBalance += currencyInMena
            }
        }
        
        return menaBalance
        
    }
    
    func getContract(){
        
       // self.loader.isHidden = false
        self.presenter?.get(api: .contract, parameters: nil)
    }
    func getMenaHistory(address: String){
        
     //   self.loader.isHidden = false
        let address = ["address":"\(address.addHexPrefix())"]
        self.presenter?.get(api: .menaHistory, parameters: address)
    }
    func getTokenHistory(address: String){
        
     //   self.loader.isHidden = false
        let address = ["address":"\(address.addHexPrefix())"]
        self.presenter?.get(api: .tokenHistory, parameters: address)
    }
    func getCountryCurrency(){
       // self.loader.isHidden = false
        self.presenter?.get(api: .countryCurrency, parameters: nil)
    }
    func setTableView(){
        
        self.tableView.reloadData()
    }
    
    func fetchContracts(){
        
        if let transactions = contractManager.fetchContracts(){
            
            self.contractList = transactions
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
            self.collectionView.reloadData()
        }
    }
    
    func fetchBalanceList(){
 
        if let balances = balanceManager.fetchBalances(){
       
            self.balanceList = balances
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
            self.collectionView.reloadData()
        }
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
    
//    func getTokenBalance(contractAddress: String, decimalCount: Double )async ->Double {
//        let localAddress = "0x\(self.address ?? "")" // Replace with your local Ethereum address
//        let contractAddressHex = "0x\(contractAddress)"
//        
//        //return 0.0
//        try?  await WalletManager.shared.getTokenBalance(localAddress: localAddress, contractAddress: contractAddressHex) { result in
//            switch result {
//            case .success(let balance):
//                print("Token Balance: \(balance)")
//                return balance
//            case .failure(let error):
//                print("Error fetching token balance: \(error.localizedDescription)")
//                return 0.0
//            }
//        }
//    }
    
    
    func getTokenBalance(contractAddress: String, decimalCount: Double) async -> Double {
        let localAddress = "0x\(self.address ?? "")" // Replace with your local Ethereum address
        let contractAddressHex = "\(contractAddress)"

        do {
            let balance = try await WalletManager.shared.getTokenBalance(localAddress: localAddress, contractAddress: contractAddressHex, decimalCount: decimalCount)
            print("Token Balance: \(balance)")
            return balance
        } catch {
            print("Error fetching token balance: \(error.localizedDescription)")
            return 0.0
        }
    }
    
    
    
    // Helper method to fetch balances in parallel using Task
    private func fetchBalancesInParallel(for contracts: [Contracts]) async -> [BalanceEntity] {
        var balances: [BalanceEntity] = []
        
        // Process balances in parallel using TaskGroup for concurrency
        await withTaskGroup(of: BalanceEntity?.self) { group in
            for (index, contract) in contracts.enumerated() {
                group.addTask {
                    if contract.currencyName == "MENA"{
                        Task { @MainActor in
                            await self.getMenaBalance()
                        }
                        return BalanceEntity(id: index, name: contract.currencyName, symbol: contract.currency, balance: menaBalance, contratAddress: contract.address, decimalCount: contract.decimalCount, conversionRate: Double(contract.currencyRate ?? "0.0"))
                    }
                    else{
                        let walletBalance = await self.getTokenBalance(contractAddress: contract.address ?? "", decimalCount: Double(contract.decimalCount ?? 0))
                        return BalanceEntity(id: index, name: contract.currencyName, symbol: contract.currency, balance: walletBalance, contratAddress: contract.address, decimalCount: contract.decimalCount, conversionRate: Double(contract.currencyRate ?? "0.0"))
                    }
                }
            }
            
            // Collect the results from all tasks
            for await balance in group {
                if let balance = balance {
                    balances.append(balance)
                }
            }
        }
        
        return balances
    }

}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3  // Replace with your data count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
    if let cell = tableView.dequeueReusableCell(withIdentifier: XIB.Names.TransactionCell, for: indexPath) as? TransactionCell, self.dataSource.count > indexPath.row{
        // Configure your cell
        DispatchQueue.main.async {
            
            cell.viewBg.backgroundColor = .textFieldBackground  // Example configuration
//            cell.lblAmount.text = self.dataSource[indexPath.row].from_address == self.address?.addHexPrefix() ? "-\(String(describing: self.dataSource[indexPath.row].amount ?? 0.0))" : "+\(String(describing: self.dataSource[indexPath.row].amount ?? 0.0))"
            
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
            var address = self.dataSource[indexPath.row].from_address == self.address ? "\(String(describing: self.dataSource[indexPath.row].receive_address ?? ""))" : "\(String(describing: self.dataSource[indexPath.row].from_address ?? ""))"
            cell.lblHolderName.text = String(address.suffix(6))
        }
        return cell
        }
      return UITableViewCell()
  }
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 80
  }

}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionCell", for: indexPath) as? HomeCollectionCell, self.balanceList.count > indexPath.item {
            let objBalanceList = self.balanceList[indexPath.item]
            cell.lblCurrencyName.text = objBalanceList.name
            cell.lblCurrency.text = "\(String(describing: objBalanceList.balance ?? 0.0)) \(objBalanceList.symbol ?? "")"
            
         return cell
        }
        return UICollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.balanceList.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

extension HomeViewController: PostViewProtocol{
    
    func onError(api: Base, message: String, statusCode code: Int) {
        self.loader.isHidden = true
        showAlert(message: message, title: "Error")
        
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
            self.tableView.delegate = self
            self.tableView.dataSource = self
            if transactionManager.createTransactions( self.dataSource) {
                print("Transactions created successfully")
            }
            else {
                print("Error creating transactions")
            }
            self.setTableView()
            
        }
        else{
            getTokenHistory(address: self.address ?? "")
        }
    }
    
//    func getContract(api: Base, data: [Contracts]) {
//        self.loader.isHidden = true
//        contractList = data
//        if contractManager.createContracts(self.contractList) {
//            print("Transactions created successfully")
//            Task{
//                balanceList.removeAll()
//                for contract in self.contractList{
//                    let walletBalnce =  await self.getTokenBalance(contractAddress:contract.address ?? "", decimalCount: Double(contract.decimalCount ?? 0))
//                    var i = 0
//                    balanceList.append(BalanceEntity(id: i, name: contract.currencyName, symbol: contract.currency, balance: walletBalnce, contratAddress: contract.address, decimalCount: contract.decimalCount, conversionRate: Double(contract.currencyRate ?? "0.0")))
//                    i = i + 1
//                }
//                if balanceManager.createBalances(balanceList){
//                    print(self.balanceList.count)
//                    print(self.balanceList)
//                    self.collectionView.reloadData()
//                    print("Balances created successfully")
//                }
//                else{
//                    print("Error creating balances")
//                }
//            }
//            
//        }
//        else {
//            print("Error creating transactions")
//        }
//    }
    
    
    func getContract(api: Base, data: [Contracts]) {
        self.loader.isHidden = true
        contractList = data
        contractList.append(Contracts(address: "", currency: "MENA", currencyName: "MENA", currencyRate: "1.55", decimalCount: 2))
        
        // Perform contract creation on background thread
        DispatchQueue.global(qos: .background).async {
            if self.contractManager.createContracts(self.contractList) {
                print("Contracts created successfully")
                
                Task {
                    // Process balances in parallel
                    self.balanceList = await self.fetchBalancesInParallel(for: self.contractList)
                    
                    
                    // After processing, save balances on background queue
                    DispatchQueue.global(qos: .background).async {
                        if self.balanceManager.createBalances(self.balanceList) {
                            print(self.balanceList.count)
                            print(self.balanceList)
                            
                            // Reload collection view on the main thread
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                                print("Balances created successfully")
                            }
                        } else {
                            print("Error creating balances")
                        }
                    }
                }
            } else {
                print("Error creating contracts")
            }
        }
    }
    
    func getCurrencyCountry(api: Base, data: [CountryCurrency]?) {
        // Create Country objects
        let countryJSONs = data?.first?.countries
        if countryManager.createCountries(countryJSONs ?? []){
            print("Countries created successfully")
        }
        else {
            print("Error creating Countries")
        }
        

        // Create Currency objects
        let currencyJSONs = data?.first?.currencies
        if currencyManager.createCurrencies(currencyJSONs ?? []){
            print("Currencies created successfully")
        }
        else {
            print("Error creating Currencies")
        }
    }
        
}


class HomeCollectionCell: UICollectionViewCell{
    @IBOutlet weak var imgCurrency: UIImageView!
    
    @IBOutlet weak var lblCurrencyName: UILabel!
    
    @IBOutlet weak var lblCurrency: UILabel!
    
}
