//
//  GetNounceTestFile.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 14/09/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import BigDecimal
import BigInt
import CryptoSwift
import Foundation
import SwiftKeychainWrapper
import Web3Core
import web3swift

class NounceTest{
    static let shared = NounceTest()
    func getNounce(addNonce: BigInteger) async{
        guard let web3Provider = await Web3HttpProvider(URL(string: baseUrl)!, network: .Mainnet) else {
            return
        }

        let web3 = Web3(provider: web3Provider)
        // Get wallet address
        if let account = WalletManager.shared.generateNewEthereumAccount() {
            print("Private Key: \(account.privateKey)")
            print("Public Key: \(account.publicKey)")
            print("Ethereum Address: \(account.address)")
            KeychainWrapper.standard.set(account.address, forKey: "keychain_address")
            
            let nonce = await getNonce(walletAddress: account.address, web3j: web3) + BigUInt(addNonce.description)!
                                                                                              
            print(nonce)
            
        }
        
        
    }
    
    private func getNonce(walletAddress: String, web3j: Web3) async -> BigUInt {
        do {
            // Print wallet address for debugging
            print(walletAddress)
            
            // Get the transaction count for the wallet using the "pending" block parameter
            let transactionCount = try await web3j.eth.getTransactionCount(for: EthereumAddress(walletAddress)!, onBlock: .pending)
            
            // Return the transaction count directly (no need for hex processing)
            return transactionCount
        } catch {
            // Log and return 0 in case of error
            print("Error: \(error.localizedDescription)")
            return BigUInt(0)
        }
    }
}
