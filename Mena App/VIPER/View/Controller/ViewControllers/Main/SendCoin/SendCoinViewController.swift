//
//  SendCoinViewController.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 11/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import UIKit
import AVFoundation
import CryptoSwift
import BigInt

class SendCoinViewController: UIViewController {
    //MARK: - @IBOutlet
        
    @IBOutlet weak var lblSendCoin: UILabel!
    
    @IBOutlet weak var lblAddress: UILabel!
    
    @IBOutlet weak var lblSelectCoin: UILabel!
    
    @IBOutlet weak var lblAmount: UILabel!
    
    @IBOutlet weak var txtAddress: UITextField!
    
    @IBOutlet weak var txtSelectYourCoin: DropDown!
    
    @IBOutlet weak var txtAmount: UITextField!
    
    @IBOutlet weak var btnQRCode: UIButton!
    
    @IBOutlet weak var btnSend: UIButton!
    
    @IBOutlet weak var viewAddress: UIView!
    
    @IBOutlet weak var viewSelectCoin: UIView!
    
    @IBOutlet weak var viewAmount: UIView!
    
    
    //MARK: - Local variable
    var customTitle: String?
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer? = nil
    let currencyManager = CurrencyManager()
    let contractManager = ContractManager()
    var contractList : [Contracts]?
    var selectedCoinIndex = Int()
   
        
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
    @IBAction func btnScanQRCodeAction(_ sender: UIButton) {
        // Create a capture session
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high

        // Create a video capture device
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("No video capture device found")
            showAlert(message: "No video capture device found")
            return
        }

        // Create a video input
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                print("Could not add video input to capture session")
                return
            }
        } catch {
            print("Error creating video input: \(error)")
            return
        }

        // Create a metadata output
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            print("Could not add metadata output to capture session")
            return
        }

        // Create a video preview layer
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = .resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)

        // Start the capture session
        captureSession.startRunning()
    }
    
    
    @IBAction func btnSendAction(_ sender: Any) {
        Task { @MainActor in
            
            
            guard let address = txtAddress.text, !address.isEmpty else {
                showAlert(message: "Enter Address Or Scan QR")
                return
            }
            
            guard let selectedCoin = txtSelectYourCoin.text, !selectedCoin.isEmpty else {
                showAlert(message: "Please select coin")
                return
            }
            
            guard let amount = txtAmount.text, !amount.isEmpty else {
                showAlert(message: "Enter amount")
                return
            }
            
            guard let contractList = self.contractList else{
                showAlert(message: "Coins are empty!!")
                return
            }
           
                do {
                    let balance = try await WalletManager.shared.getTokenBalance(localAddress: "0xd5467C73a4d842a7bCAE5dDE03950059DE628bEb", contractAddress: contractList[self.selectedCoinIndex].address ?? "", decimalCount: Double(contractList[self.selectedCoinIndex].decimalCount ?? Int(0.0)))
                    
                    print("Token balance: \(balance)")
                    
                    if balance == Double(amount) || balance > Double(amount) ?? 0 {
                       // let txHash = try await WalletManager.shared.getTransactionHash(password: "123", toAddress: "0x7c3A4FFEF707049B9E921593f87a9110C6Def738", contractAddress: contractList[selectedCoinIndex].address ?? "", tokenAmount: Double(amount) ?? 0, decimalCount: Int(Double(contractList[selectedCoinIndex].decimalCount ??  0)))
                        //Here we call server API
                        await WalletManager.shared.getTransactionHash(password: "123", toAddress: "0x7c3A4FFEF707049B9E921593f87a9110C6Def738", contractAddress: contractList[selectedCoinIndex].address ?? "", tokenAmount: Double(amount) ?? 0, decimalCount: Int(Double(contractList[selectedCoinIndex].decimalCount ?? 0)), addNonce: BigInteger(BigInt(0)), completion: { txHash in
                                if let txHash = txHash {
                                    // use txHash
                                    self.setTxHashToServer(txHash: txHash)
                                
                                } else {
                                    // handle nil txHash
                                }
                            
                        })
                        
                    }
                    else{
                        showToast(message: "Low Balance")
                    }
                } catch {
                    showToast(message: "\(error.localizedDescription)")
                    print("Error: \(error.localizedDescription)")
                }
        }
    }
    
}

//MARK: - extension
extension SendCoinViewController{
    func initialLoads(){
        
        addCrossButton()
        localize()
        setDesign()
        setFonts()
        setDropDown()
        
    }
    func setFonts(){
        
    }
    func setDesign(){
        
        viewAddress.layer.cornerRadius = 15
        viewSelectCoin.layer.cornerRadius = 15
        viewAmount.layer.cornerRadius = 15
        btnSend.layer.cornerRadius = 15
        btnQRCode.layer.cornerRadius = 11.05
    }
    func localize(){
        
        lblSendCoin.text = Constants.string.sendCoin.localize()
        lblAddress.text = Constants.string.address.localize()
        lblSelectCoin.text = Constants.string.selectCoin.localize()
        lblAmount.text = Constants.string.amount.localize()
        
        txtAddress.placeholder = Constants.string.enterYourAddress.localize()
        txtSelectYourCoin.placeholder = Constants.string.selectYourCoin.localize()
        txtAmount.placeholder = Constants.string.enterYourAmount.localize()
        
        self.btnSend.setTitle(Constants.string.send.localize(), for: .normal)
        
    }
    func setTxHashToServer(txHash: String){
        let sendCoinRequest = SendCoinRequest(data: Transactions(transactions: [txHash]))
        let encoder = JSONEncoder()
        let data = try? encoder.encode(sendCoinRequest)
        self.presenter?.post(api: .transactionSend, data: data)
        
    }
    func addCrossButton(){
                let headerView = CustomHeaderView()
               headerView.translatesAutoresizingMaskIntoConstraints = false
               headerView.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
               headerView.title = customTitle // Set the title dynamically
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
    func setDropDown(){
        let currencyList = currencyManager.fetchCurrencies()
        contractList = contractManager.fetchContracts()
        txtSelectYourCoin.optionArray = currencyList?.compactMap({
            $0.fiatCurrency
        }) ?? [""]
        
        txtSelectYourCoin.didSelect{(selectedText , index ,id) in
            self.selectedCoinIndex = index
        }
    }
}

extension SendCoinViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadata object is a QR code
        if let metadataObject = metadataObjects.first {
            if let qrCodeObject = metadataObject as? AVMetadataMachineReadableCodeObject {
                if qrCodeObject.type == .qr {
                    // Get the QR code string
                    if let qrCodeString = qrCodeObject.stringValue {
                        print("QR code string: \(qrCodeString)")
                        
                        // Stop the capture session
                        captureSession.stopRunning()
                        
                        // Handle the QR code string as needed
                        // For example, you can display it in a label
                        DispatchQueue.main.async {
                            self.txtAddress.text = "\(qrCodeString.dropFirst(9))"
                        }
                    }
                }
            }
        }
    }
}

extension SendCoinViewController: PostViewProtocol{
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
