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
    var contractList = [Contracts]()
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
    func initialLoads()  {
      
    setFont()
    setDesign()
    addGesture()
    fetchCoreData()
    fetchContracts()
    getAddress()
    getCountryCurrency()
//        DispatchQueue.main.async {
//            self.getMenaBalance()
//        }
       
         
      
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
    func getMenaBalance() async{
        
        try? await WalletManager.shared.getWalletBalance(walletAddress: "0xYourWalletAddress") { balance in
            if let balance = balance {
                print("Wallet balance: \(balance) ETH")
                self.lblMenaWalletBalance.text = "\(balance)"
            } else {
                print("Failed to get wallet balance")
            }
        }
    }
    func getContract(){
        
        self.loader.isHidden = false
        self.presenter?.get(api: .contract, parameters: nil)
    }
    func getMenaHistory(address: String){
        
        self.loader.isHidden = false
        let address = ["address":"\(address)"]
        self.presenter?.get(api: .menaHistory, parameters: address)
    }
    func getTokenHistory(address: String){
        
        self.loader.isHidden = false
        let address = ["address":"\(address)"]
        self.presenter?.get(api: .tokenHistory, parameters: address)
    }
    func getCountryCurrency(){
        self.loader.isHidden = false
        self.presenter?.get(api: .countryCurrency, parameters: nil)
    }
    func setTableView(){
        
        self.tableView.reloadData()
    }
    
    func fetchContracts(){
        
        if let transactions = contractManager.fetchContracts(){
            print("Transactions: \(transactions)")
            self.contractList = transactions
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
            self.collectionView.reloadData()
        }
    }
    
    func getTokenBalance(contractAddress: String, decimalCount: Double ) async{
        let localAddress = "0x\(self.address ?? "")" // Replace with your local Ethereum address
        let contractAddressHex = "0x\(contractAddress)"
        
//        try?  await WalletManager.shared.getTokenBalance(localAddress: localAddress, contractAddress: contractAddressHex, decimalCount: decimalCount, infuraProjectId: baseUrl) { result in
//            switch result {
//            case .success(let balance):
//                print("Token Balance: \(balance)")
//            case .failure(let error):
//                print("Error fetching token balance: \(error.localizedDescription)")
//            }
//        }
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
            cell.lblAmount.text = self.dataSource[indexPath.row].from_address == self.address ? "-\(String(describing: self.dataSource[indexPath.row].amount ?? 0.0))" : "+\(String(describing: self.dataSource[indexPath.row].amount ?? 0.0))"
            cell.lblDate.text = "\(String(describing: Formatter.shared.formatISO8601Date(self.dataSource[indexPath.row].date ?? "")))"
            cell.lblHolderName.text = self.dataSource[indexPath.row].from_address == self.address ? "\(String(describing: self.dataSource[indexPath.row].receive_address ?? ""))" : "\(String(describing: self.dataSource[indexPath.row].from_address ?? ""))"
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
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionCell", for: indexPath) as? HomeCollectionCell {
           
         return cell
        }
        return UICollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

extension HomeViewController: PostViewProtocol{
    
    func onError(api: Base, message: String, statusCode code: Int) {
        
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
    
    func getContract(api: Base, data: [Contracts]) {
        contractList = data
        if contractManager.createContracts(self.contractList) {
            print("Transactions created successfully")
            Task{
                try? await self.getTokenBalance(contractAddress:contractList.first?.address ?? "", decimalCount: Double(data.first?.decimalCount ?? 0))
            }
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
        }
        else {
            print("Error creating transactions")
        }
    }
    
    func getCurrencyCountry(api: Base, data: CountryCurrency?) {
        // Create Country objects
        let countryJSONs = data?.countries
        if countryManager.createCountries(countryJSONs ?? []){
            print("Countries created successfully")
        }
        else {
            print("Error creating Countries")
        }
        

        // Create Currency objects
        let currencyJSONs = data?.currencies
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
