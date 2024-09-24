//
//  PaymentViewController.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 09/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import UIKit
import AVFoundation
import CryptoSwift
import BigInt

class PaymentViewController: UIViewController {
    @IBOutlet weak var viewScanQR: UIView!
    
    @IBOutlet weak var viewNFC: UIView!
    
    @IBOutlet weak var lblScanWithQR: UILabel!
    
    @IBOutlet weak var lblNFC: UILabel!
    
    //MARK: - Local variable
    var customTitle: String?
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer? = nil
    var balanceList: [BalanceEntity] = []
    let balanceManager = BalanceManager()
        
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
        fetchBalanceList()
    }
    func setFonts(){
        
    }
    func setDesign(){
      
        
    }
    func localize(){
        lblScanWithQR.text = Constants.string.scanWithQR.localize()
        lblNFC.text = Constants.string.NFC.localize()
      
    }
    func fetchBalanceList(){
        balanceList = balanceManager.fetchBalances() ?? []
    }
    
    func addGesture(){
        viewScanQR.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewScanAction)))
        viewNFC.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewNFCAction)))
    }
    
    @objc func viewScanAction() {
        captureSession.startRunning()
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
    
    func makeMultiTransaction(scanResult: [ScanResult], toAddress : String?) async{
        
        var isSucceful : Bool = false
        var hashList  = [""]
        
        let payableAmount = balanceList.first { $0.name == "USD" }?.balance ?? 0.0//Double("500")//Get usd balance 500
        
        if payableAmount <= 0.0{
            showAlert(message: "Invalid Amount")
            return
        }
        let remainingAmount = payableAmount
        var addNounce = 0 //Nounce Type
        
        for balance in balanceList{
            
            let coinBalance = balance.balance ?? 0.0
            if coinBalance > 0{
                
                let inUSD = coinBalance / (balance.conversionRate ?? 0)
                
                if (remainingAmount) - inUSD >= 0{
                    
                    addNounce  = addNounce + 1
                    await WalletManager.shared.getTransactionHash(password: "123", toAddress: toAddress ?? "", contractAddress: balance.contratAddress ?? "", tokenAmount: coinBalance, decimalCount: Int(Double(balance.decimalCount ??  0)), addNonce: BigInteger(addNounce), completion: { txHash in
                        
                        hashList.append("\(txHash ?? "0.0")")
                        
                    })

                }
                else{
                    let remainingAmount = remainingAmount
                    let conversionRate = balance.conversionRate ?? 1.0
                    let originalBalance = remainingAmount * conversionRate
                    addNounce  = addNounce + 1
                    await WalletManager.shared.getTransactionHash(password: "123", toAddress: toAddress ?? "", contractAddress: balance.contratAddress ?? "", tokenAmount: originalBalance, decimalCount: Int(Double(balance.decimalCount ??  0)), addNonce: BigInteger(addNounce), completion: { txHash in
            
                        hashList.append("\(txHash ?? "0.0")")
                        
                    })
                    
                }
                
                if remainingAmount == 0.0 {
                    isSucceful = true
                    setTxHashToServer(txHash: hashList)
                    break
                }
            }
        }
         
        if !isSucceful{
            showAlert(message: "Insufiicent Balances!")
        }
        
        
    }
    
    func setTxHashToServer(txHash: [String]){
        let sendCoinRequest = SendCoinRequest(data: Transactions(transactions: txHash))
        let encoder = JSONEncoder()
        let data = try? encoder.encode(sendCoinRequest)
        self.presenter?.post(api: .tokenTransactionSend, data: data)
        
    }
    
    func parseInput(input: String) -> (toAddress: String, results: [ScanResult]) {
        // Split the input string based on the comma
        let components = input.split(separator: ",", maxSplits: 1, omittingEmptySubsequences: true)
        
        // Ensure there are exactly two components after splitting
        guard components.count == 2 else {
            fatalError("Invalid input format")
        }
        
        // First component is the toAddress
        let toAddress = String(components[0])
        
        // Second component is the JSON-like string
        let jsonString = String(components[1])
        
        // Parse the JSON-like string to extract currency and balance pairs
        var results = [ScanResult]()
        
        // Use regular expressions to extract the key-value pairs
        let regex = try! NSRegularExpression(pattern: "\"?([A-Za-z]+)\"?:\"?([0-9]+)\"?", options: [])
        let matches = regex.matches(in: jsonString, options: [], range: NSRange(jsonString.startIndex..., in: jsonString))
        
        for match in matches {
            if let keyRange = Range(match.range(at: 1), in: jsonString),
               let valueRange = Range(match.range(at: 2), in: jsonString) {
                let key = String(jsonString[keyRange])
                let value = String(jsonString[valueRange])
                
                let result = ScanResult(currency: key, balance: value)
                results.append(result)
            }
        }
        
        return (toAddress, results)
    }
    
    func setTransaction(qrCodeString: String) async{
        var isSuccess = false
        var decryptedString = ""
        
        //Algorithum Encryption
        //
        do{
             decryptedString = try AESCrypt.driver(text: qrCodeString)// for decryption
            
        }catch{
            print("Something went wrong with decryption!!")
        }
        //Parsing
        let parsedData = parseInput(input: decryptedString)
        let toAddress = parsedData.toAddress
       
        //List Scan Result
        let scanRsultList = parsedData.results

        //Loop on balance list
        
        for balance in balanceList {
            for scanResult in scanRsultList {
                if balance.symbol == scanResult.currency {
                    if Double(balance.balance ?? 0.0) >= Double(scanResult.balance ?? "0.0") ?? 0.0 {
                        let tokenBalance = Double(scanResult.balance ?? "0.0") ?? 0.0
//                                        // getTxHash
                        await WalletManager.shared.getTransactionHash(password: "123" as String, toAddress: toAddress, contractAddress: balance.contratAddress ?? "" as String, tokenAmount: tokenBalance, decimalCount: balance.decimalCount ?? 1 as Int, addNonce: BigInteger(BigInt(0)), completion: { txHash in
                                if let txHash = txHash {
                                    // use txHash
                                    self.setTxHashToServer(txHash: [txHash])
                                    isSuccess = true
                                } else {
                                    // handle nil txHash
                                }
                            
                        })
                
                        break
                    }
                }
            }
        }
        if !isSuccess{
            showToast(message: "Switching to multi currency mode")
            await self.makeMultiTransaction(scanResult: scanRsultList, toAddress: toAddress)

        }

    }
    
}

extension PaymentViewController: AVCaptureMetadataOutputObjectsDelegate {
    private func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) async  {
        // Check if the metadata object is a QR code
        if let metadataObject = metadataObjects.first {
            if let qrCodeObject = metadataObject as? AVMetadataMachineReadableCodeObject {
                if qrCodeObject.type == .qr {
                    // Get the QR code string
                    if let qrCodeString = qrCodeObject.stringValue {
                        print("QR code string: \(qrCodeString)")
                        // Stop the capture session
                        captureSession.stopRunning()
                        
                        await self.setTransaction(qrCodeString: qrCodeString)
                        
                    }
                }
            }
        }
    }
}

extension PaymentViewController: PostViewProtocol{
    func onError(api: Base, message: String, statusCode code: Int) {
        
    }
    
    func transactionResponse(api: Base, data: TrransactionResponse?) {
        if data?.error == nil {
            showAlert(message: data?.success ?? "")
        }
        else{
            showAlert(message: "Error", title: data?.error ?? "")
        }
        
    }
}
