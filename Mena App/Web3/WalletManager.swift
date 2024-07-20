//
//  WalletManager.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 19/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import BigDecimal
import BigInt
import CryptoSwift
import Foundation
import SwiftKeychainWrapper
import Web3Core
import web3swift

class WalletManager {
  static let shared = WalletManager()
  private let chainId: Int64 = 97197
  private init() {}

  //MARK: - createWallet

  func createWallet(password: String, completion: @escaping (Result<String, Error>) -> Void) {
    do {
      let mnemonics = try BIP39.generateMnemonics(bitsOfEntropy: 256, language: .english)
      guard let mnemonics = mnemonics else {
        throw NSError(
          domain: "WalletManager", code: -1,
          userInfo: [NSLocalizedDescriptionKey: "Unable to generate mnemonics"])
      }

      let bip32Keystore = try BIP32Keystore(
        mnemonics: mnemonics, password: password, prefixPath: "m/44'/60'/0'/0")
      guard let bip32Keystore = bip32Keystore else {
        throw NSError(
          domain: "WalletManager", code: -1,
          userInfo: [NSLocalizedDescriptionKey: "Unable to create keystore"])
      }

      guard let address = bip32Keystore.addresses?.first else {
        throw NSError(
          domain: "WalletManager", code: -1,
          userInfo: [NSLocalizedDescriptionKey: "Unable to retrieve wallet address"])
      }

      let keystoreV3 = createEthereumKeystoreV3WithRandomPrivateKey(password: password)

      guard let keystoreV3 = keystoreV3 else {
        throw NSError(
          domain: "WalletManager", code: -1,
          userInfo: [NSLocalizedDescriptionKey: "Unable to create Ethereum Keystore V3"])
      }

      let keystoreData = try keystoreV3.serialize()

      let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[
        0]
      let keystoreDir = userDir + "/keystore"
      let keystorePath = keystoreDir + "/key.json"

      let fileManager = FileManager.default
      if !fileManager.fileExists(atPath: keystoreDir) {
        try fileManager.createDirectory(
          atPath: keystoreDir, withIntermediateDirectories: true, attributes: nil)
      }

      try keystoreData?.write(to: URL(fileURLWithPath: keystorePath))

      completion(.success(address.address))
    } catch {
      completion(.failure(error))
    }
  }

  func createEthereumKeystoreV3WithRandomPrivateKey(password: String) -> EthereumKeystoreV3? {
    do {
      let keystoreV3 = try EthereumKeystoreV3(password: password)
      return keystoreV3
    } catch {
      print("Error creating EthereumKeystoreV3 instance: \(error)")
      return nil
    }
  }

  //MARK: - initializeWallet
  func initializeWallet(password: String, completion: @escaping (Result<String, Error>) -> Void) {
    if doesKeystoreExist() {
      completion(
        .failure(
          NSError(
            domain: "WalletManager", code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Wallet already exists"])))
    } else {
      createWallet(password: password, completion: completion)
    }
  }

  //MARK: - importWallet using private key
  func importWallet(privateKey: String, completion: @escaping (Result<String, Error>) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async {
      let formattedKey = privateKey.trimmingCharacters(in: .whitespacesAndNewlines)
      guard let dataKey = Data.fromHex(formattedKey) else {
        completion(
          .failure(
            NSError(
              domain: "WalletManager", code: -1,
              userInfo: [NSLocalizedDescriptionKey: "Invalid private key"])))
        return
      }
      do {
        // let keystore = try EthereumKeystoreV3(dataKey)
        let keystore = try BIP32Keystore(seed: dataKey, password: "")
        if let myWeb3KeyStore = keystore {
          let manager = KeystoreManager([myWeb3KeyStore])
          guard let address = manager.addresses?.first else {
            throw NSError(
              domain: "WalletManager", code: -1,
              userInfo: [NSLocalizedDescriptionKey: "Unable to retrieve wallet address"])
          }
          completion(.success(address.address))
        } else {
          throw NSError(
            domain: "WalletManager", code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Error creating keystore"])
        }
      } catch {
        completion(.failure(error))
      }
    }
  }

  //MARK: - importWallet using mnemonics
  func importWallet(mnemonics: String, completion: @escaping (Result<String, Error>) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        let keystore = try BIP32Keystore(
          mnemonics: mnemonics, password: "", prefixPath: "m/44'/60'/0'/0")
        guard let walletAddress = keystore?.addresses?.first else {
          throw NSError(
            domain: "WalletManager", code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Invalid mnemonics"])
        }
        completion(.success(walletAddress.address))
      } catch {
        completion(.failure(error))
      }
    }
  }
  //MARK: - deriveAddress
  func deriveAddress(
    fromPublicKey publicKey: String, completion: @escaping (Result<String, Error>) -> Void
  ) {
    DispatchQueue.global(qos: .userInitiated).async {
      guard let publicKeyData = Data.fromHex(publicKey) else {
        completion(
          .failure(
            NSError(
              domain: "WalletManager", code: -1,
              userInfo: [NSLocalizedDescriptionKey: "Invalid public key"])))
        return
      }
      let keystore = try? EthereumKeystoreV3(publicKeyData)
      guard let address = keystore?.addresses?.first else {
        completion(
          .failure(
            NSError(
              domain: "WalletManager", code: -1,
              userInfo: [NSLocalizedDescriptionKey: "Unable to derive address"])))
        return
      }
      completion(.success(address.address))
    }
  }

  //MARK: - Login with Password
  func loginWithPassword(password: String, completion: @escaping (Result<String, Error>) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async {
      let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[
        0]
      let keystorePath = userDir + "/keystore/key.json"
      print("Path login wallet: \(keystorePath)")

      do {
        // Load keystore from file
        let keystoreData = try Data(contentsOf: URL(fileURLWithPath: keystorePath))
        print("Keystore data loaded: \(keystoreData.count) bytes")

        // Log raw keystore data for debugging
        var string = String()
        if let keystoreString = String(data: keystoreData, encoding: .utf8) {
          print("Raw keystore data: \(keystoreString)")
          string = keystoreString
        } else {
          print("Failed to convert keystore data to string")
        }

        let bip32Keystore = try EthereumKeystoreV3(keystoreData)
        guard let keystore = bip32Keystore else {
          print("Failed to initialize BIP32Keystore from loaded data")
          return
        }

        if let privateKey = self.loginWithPassword(
          password: password, keystoreJsonData: keystoreData)
        {
          print("Logged in successfully! Private key: \(privateKey.toHexString())")
          completion(.success(privateKey.toHexString()))
        } else {
          print("Login failed")
          let error = NSError(
            domain: "WalletManager", code: 0,
            userInfo: [NSLocalizedDescriptionKey: "Invalid password"])
          completion(.failure(error))

        }

      } catch {
        print("Error loading keystore: \(error)")
        completion(.failure(error))
      }
    }
  }

  func loginWithPassword(password: String, keystoreJsonData: Data) -> Data? {
    do {
      let keystoreV3 = try EthereumKeystoreV3(keystoreJsonData)
      let privateKey = try keystoreV3?.UNSAFE_getPrivateKeyData(
        password: password, account: (keystoreV3?.address)!)
      return privateKey
    } catch {
      print("Error logging in with password: \(error)")
      return nil
    }
  }
  //MARK: - doesKeystoreExist
  func doesKeystoreExist() -> Bool {

    guard let authKey = KeychainWrapper.standard.string(forKey: "keychain_auth_key"),
      !authKey.isEmpty,
      let email = KeychainWrapper.standard.string(forKey: "keychain_email"), !email.isEmpty
    else {
      print("Keychain values for auth key or email do not exist.")
      return false
    }

    let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let keystorePath = userDir + "/keystore/key.json"
    let keystoreURL = URL(fileURLWithPath: keystorePath)

    if FileManager.default.fileExists(atPath: keystorePath) {
      print("Keystore file exists at path: \(keystorePath)")

      do {
        let keystoreData = try Data(contentsOf: keystoreURL)
        print("Keystore data loaded successfully from file.")
        if let bip32Keystore = EthereumKeystoreV3(keystoreData) {
          print("Keystore initialized successfully.")
          return true
        } else {
          print("Failed to initialize BIP32Keystore from loaded data.")
          return false
        }
      } catch {
        print("Failed to load keystore data from file: \(error.localizedDescription)")
        return false
      }
    } else {
      print("Keystore file does not exist at path: \(keystorePath)")
      return false
    }
  }
  //MARK: - deleteKeystore

  func deleteKeystore(completion: @escaping (Result<Void, Error>) -> Void) {

    let remove_keychain_auth_key: Bool = KeychainWrapper.standard.removeObject(
      forKey: "keychain_auth_key")
    let remove_keychain_email: Bool = KeychainWrapper.standard.removeObject(
      forKey: "keychain_email")
    let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let keystorePath = userDir + "/keystore/key.json"

    do {
      let fileManager = FileManager.default
      if fileManager.fileExists(atPath: keystorePath) {
        try fileManager.removeItem(atPath: keystorePath)
        completion(.success(()))
      } else {
        throw NSError(
          domain: "WalletManager", code: -1,
          userInfo: [NSLocalizedDescriptionKey: "Keystore file does not exist"])
      }
    } catch {
      completion(.failure(error))
    }
  }

  //MARK: - importWallet using private key
  func importWallet(privateKey: String, publicKey: String, password: String) throws -> (
    address: String, keystore: EthereumKeystoreV3
  )? {
    do {
      // Convert private key string to Data
      guard let privateKeyData = Data(from: privateKey) else {
        print("Invalid private key")
        throw NSError(
          domain: "WalletManager", code: -1,
          userInfo: [NSLocalizedDescriptionKey: "Invalid private key"])
        return nil
      }

      // Validate private key length
      guard privateKeyData.count == 32 else {

        print("Invalid private key length")
        throw NSError(
          domain: "WalletManager", code: -1,
          userInfo: [NSLocalizedDescriptionKey: "Invalid private key"])
        return nil
      }
      // Create a new keystore with the private key

      let keystore = try EthereumKeystoreV3(privateKey: privateKeyData, password: password)
      // Get the Ethereum address
      guard let address = keystore?.addresses?.first else {
        print("Failed to get Ethereum address")
        throw NSError(
          domain: "WalletManager", code: -1,
          userInfo: [NSLocalizedDescriptionKey: "Failed to get Ethereum address"])
        return nil
      }

      // Extract keystore parameters
      guard let keystoreParams = keystore?.keystoreParams else {
        throw NSError(
          domain: "WalletManager", code: -1,
          userInfo: [NSLocalizedDescriptionKey: "No keystore parameters found"])
      }

      // Encode keystore parameters to JSON
      let encoder = JSONEncoder()
      let keystoreData = try encoder.encode(keystoreParams)

      // Save keystore to file
      let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[
        0]
      let keystorePath = userDir + "/keystore/key.json"

      // Ensure the keystore directory exists
      try FileManager.default.createDirectory(
        atPath: userDir + "/keystore", withIntermediateDirectories: true, attributes: nil)

      // Write keystore to file
      try keystoreData.write(to: URL(fileURLWithPath: keystorePath))

      guard let address = keystore?.addresses?.first else {
        throw NSError(
          domain: "WalletManager", code: -1,
          userInfo: [NSLocalizedDescriptionKey: "Unable to retrieve wallet address"])
      }

      return (address.address, keystore) as! (address: String, keystore: EthereumKeystoreV3)
    } catch {
      print("Error: \(error)")
      return nil
    }
  }

  func createEthereumKeystoreV3WithSpecificPrivateKey(privateKey: Data, password: String) -> Data? {
    do {
      let keystoreV3 = try EthereumKeystoreV3(privateKey: privateKey, password: password)
      let jsonData = try keystoreV3?.serialize()
      return jsonData
    } catch {
      print("Error creating EthereumKeystoreV3 instance: \(error)")
      return nil
    }
  }

  //MARK: - generateNewEthereumAccount
  func generateNewEthereumAccount() -> (privateKey: String, publicKey: String, address: String)? {
    do {
      let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[
        0]
      let keystorePath = userDir + "/keystore/key.json"
      print("Path login wallet: \(keystorePath)")

      let keystoreData = try Data(contentsOf: URL(fileURLWithPath: keystorePath))
      print("Keystore data loaded: \(keystoreData.count) bytes")
      // Generate a new random private key
      guard let keystore = try EthereumKeystoreV3(keystoreData) else {
        print("Failed to create keystore")
        return nil
      }

      // Get the Ethereum address
      guard let address = keystore.addresses?.first else {
        print("Failed to get Ethereum address")
        return nil
      }
      let password = KeychainWrapper.standard.string(forKey: "keychain_password") ?? ""
      // Get the private key
      guard
        let privateKeyData = try? keystore.UNSAFE_getPrivateKeyData(
          password: password, account: address)
      else {
        print("Failed to get private key data")
        return nil
      }
      let privateKey = privateKeyData.toHexString()

      // Get the public key
      let publicKeyData = Utilities.privateToPublic(privateKeyData)
      let publicKey = publicKeyData?.toHexString()

      return (privateKey, publicKey, address.address)
        as? (privateKey: String, publicKey: String, address: String)
    } catch {
      print("Error: \(error)")
      return nil
    }
  }
  //MARK: -getTokenBalance
    func getTokenBalance(localAddress: String, contractAddress: String, decimalCount: Double) async throws -> Double {
    // Ensure valid Ethereum addresses
    guard let userAddress = EthereumAddress(localAddress),
      let tokenAddress = EthereumAddress(contractAddress, type: .contractDeployment)
    else {
        throw NSError(domain: "Invalid Ethereum address", code: -1, userInfo: nil)
      
    }

    // Initialize Web3 instance
    guard let web3 = try? await Web3.InfuraMainnetWeb3(accessToken: infuraProjectId) else {
        throw NSError(domain: "Failed to create Web3 instance", code: -1, userInfo: nil)
    }

    // Define the ERC-20 Token Contract ABI
    let erc20ABI = """
      [
          {"constant": true, "inputs": [{"name": "_owner", "type": "address"}], "name": "balanceOf", "outputs": [{"name": "balance", "type": "uint256"}], "payable": false, "stateMutability": "view", "type": "function"}
      ]
      """

    // Create the Contract Instance
    guard let contract = web3.contract(erc20ABI, at: tokenAddress, abiVersion: 2) else {
        throw NSError(domain: "Failed to create contract instance", code: -1, userInfo: nil)
   
    }

    // Prepare the Transaction Options
    var transactionOptions = contract.transaction
    transactionOptions.from = userAddress
    transactionOptions.callOnBlock = .latest

    // Parameters for balanceOf function
    let parameters: [AnyObject] = [userAddress as AnyObject]

    // Fetch Token Balance
    Task {
      do {
        guard let readOperation = contract.createReadOperation("balanceOf", parameters: parameters)
        else {
            throw NSError(domain: "Failed to create read operation", code: -1, userInfo: nil)
          
        }

        let result = try await readOperation.callContractMethod()

        if let balanceBigUInt = result["0"] as? BigUInt {
          // Assuming token has 18 decimals (common for most ERC-20 tokens)
          let decimals: Double = decimalCount
          let balance = Double(balanceBigUInt) / pow(10.0, decimals)
            return balance
         
        } else {
            throw NSError(domain: "Failed to fetch balance", code: -1, userInfo: nil)
        }
      } catch {
          throw NSError(domain: error.localizedDescription, code: -1)
      }
    }
        return 0
  }

  func getWalletBalance(walletAddress: String, completion: @escaping (Double?) -> Void) async {
    do {
      guard let web3 = try? await Web3.InfuraMainnetWeb3(accessToken: infuraProjectId) else {
        completion(nil)
        return
      }
      let balance = try await web3.eth.getBalance(
        for: EthereumAddress(walletAddress)!, onBlock: .latest)
      let balanceInEther = Double(balance) / pow(10, 18)
      completion(balanceInEther)
    } catch {
      completion(nil)
    }
  }

 
    
    func getTransactionHash(password: String, toAddress: String, contractAddress: String, tokenAmount: Double, decimalCount: Int, addNonce: BigInteger, completion: @escaping (String?) -> Void) async {
        // your implementation

    do {
     
      guard let web3j = try? await Web3.InfuraMainnetWeb3(accessToken: infuraProjectId) else {
          completion(nil)
          return
      }
      let value = BigUInt("\(tokenAmount)", .ether)!
      let gas = BigUInt("20000", .wei)!
      let gasPrice = BigUInt("20", .gwei)!
      var address = KeychainWrapper.standard.string(forKey: "keychain_address") ?? ""
        
      let nonce =
        await getNonce(walletAddress: address, web3j: web3j) + BigUInt(addNonce.description)!

      let formattedAmount = BigDecimal(floatLiteral: tokenAmount).multiply(
        BigDecimal.ten.pow(decimalCount)
      )
            .setScale(0, roundingMode: .halfUp)
      let uint256 = BigUInt(BigInt(formattedAmount.integerValue))
      let function = Function(
        name: "transfer",
        parameters: [Address(toAddress), uint256],
        emptyParameters: [])
        
        let bigIntValue = BigInt(value)
        let bigUIntValue = bigIntValue.magnitude
        if let uintValue = UInt(bigUIntValue.description) {
            let data = try! ABIEncoder.abiEncode(uintValue)
            print(data)
        } else {
            print("BigUInt value is too large for UInt")
        }


      let txCount = try await web3j.eth.getTransactionCount(for: EthereumAddress(address)!)
      let transaction = Web3Core.CodableTransaction(
        // from: EthereumAddress(address)!,
        to: EthereumAddress(toAddress)!,
        nonce: nonce, value: value,
        // gas: gas,
        data: Data(), gasPrice: gasPrice  // no data payload for this example
      )
      let provider = web3j.provider
      let eth = Web3.Eth(provider: provider)

      let result = try await eth.send(transaction)
      completion(result.hash.addHexPrefix())

    } catch {
      print("Error sending transaction: \(error)")
        completion(nil)
    }
  }

   
    func getMenaHash(
        password: String,
        toAddress: String,
        tokenAmount: Double,
        addNonce: BigUInt = 0
    ) async -> String? {
        do {
            guard let web3j = try? await Web3.InfuraMainnetWeb3(accessToken: infuraProjectId) else {
                return nil
            }
            let value = BigUInt("\(tokenAmount)", .ether)!
            let gas = BigUInt("20000", .wei)!
            let gasPrice = BigUInt("20", .gwei)!
            let address = KeychainWrapper.standard.string(forKey: "keychain_address") ?? ""
            
            let nonce = await getNonce(walletAddress: address, web3j: web3j) + addNonce
            
            let formattedAmount = BigDecimal(floatLiteral: tokenAmount)
            let uint256 = BigUInt(BigInt(formattedAmount.integerValue))
            
            let transaction = Web3Core.CodableTransaction(
                to: EthereumAddress(toAddress)!,
                nonce: nonce, value: value,
              //  gas: gas,
                data: Data(), gasPrice: gasPrice
            )
            let provider = web3j.provider
            let eth = Web3.Eth(provider: provider)
            
            let result = try await eth.send(transaction)
            return result.hash.addHexPrefix()
            
        } catch {
            print("Error sending transaction: \(error)")
            return nil
        }
    }
    
    
    
    
    
    
    
    
  private func getNonce(walletAddress: String, web3j: Web3) async -> BigUInt {
    do {
      let transactionCountHex = try await web3j.eth.getTransactionCount(
        for: EthereumAddress(walletAddress)!)
      let hexString = String(transactionCountHex)  // Convert to String
      let startIndex = hexString.index(hexString.startIndex, offsetBy: 2)  // Skip "0x"
      let hexSubstring = String(hexString[startIndex...])  // Get the substring without "0x"
      return BigUInt(hexSubstring, radix: 16)!
    } catch {
      print("Error: \(error.localizedDescription)")
      return BigUInt(0)
    }
  }

    
}

extension Array {
    func padded(to length: Int, with element: Element) -> [Element] {
        return self + Array(repeating: element, count: length - self.count)
    }
}
extension Data {
    func padded(to length: Int) -> Data {
        var paddedData = self
        let paddingCount = length - count
        if paddingCount > 0 {
            paddedData.append(Data(repeating: 0, count: paddingCount))
        }
        return paddedData
    }
}
