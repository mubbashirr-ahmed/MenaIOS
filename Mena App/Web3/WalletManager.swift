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

//      let bip32Keystore = try BIP32Keystore(
//        mnemonics: mnemonics, password: password, prefixPath: "m/44'/60'/0'/0")
//      guard let bip32Keystore = bip32Keystore else {
//        throw NSError(
//          domain: "WalletManager", code: -1,
//          userInfo: [NSLocalizedDescriptionKey: "Unable to create keystore"])
//      }
//
//      guard let address = bip32Keystore.addresses?.first else {
//        throw NSError(
//          domain: "WalletManager", code: -1,
//          userInfo: [NSLocalizedDescriptionKey: "Unable to retrieve wallet address"])
//      }

      let keystoreV3 = createEthereumKeystoreV3WithRandomPrivateKey(password: password)

      guard let keystoreV3 = keystoreV3 else {
        throw NSError(
          domain: "WalletManager", code: -1,
          userInfo: [NSLocalizedDescriptionKey: "Unable to create Ethereum Keystore V3"])
      }

      guard let address = keystoreV3.addresses?.first else {
        throw NSError(
            domain: "WalletManager", code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Unable to retrieve wallet address"])
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
    
    
    func getKeystore() -> EthereumKeystoreV3? {
        // Ensure the keystore exists
        guard let authKey = KeychainWrapper.standard.string(forKey: "keychain_auth_key"),
              !authKey.isEmpty,
              let email = KeychainWrapper.standard.string(forKey: "keychain_email"),
              !email.isEmpty
        else {
            print("Keychain values for auth key or email do not exist.")
            return nil
        }

        // Define the path to the keystore file
        let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let keystorePath = userDir + "/keystore/key.json"
        let keystoreURL = URL(fileURLWithPath: keystorePath)

        // Check if the keystore file exists
        if FileManager.default.fileExists(atPath: keystorePath) {
            print("Keystore file exists at path: \(keystorePath)")

            do {
                // Load the keystore data from the file
                let keystoreData = try Data(contentsOf: keystoreURL)
                print("Keystore data loaded successfully from file.")

                // Initialize the keystore object
                if let bip32Keystore = EthereumKeystoreV3(keystoreData) {
                    print("Keystore initialized successfully.")
                    return bip32Keystore
                } else {
                    print("Failed to initialize BIP32Keystore from loaded data.")
                    return nil
                }
            } catch {
                print("Failed to load keystore data from file: \(error.localizedDescription)")
                return nil
            }
        } else {
            print("Keystore file does not exist at path: \(keystorePath)")
            return nil
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
    func generateNewEthereumAccount() -> (privateKey: String, publicKey: String, address: String, keyStore:EthereumKeystoreV3)? {
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

      return (privateKey, publicKey, address.address, keystore)
        as? (privateKey: String, publicKey: String, address: String, keyStore:EthereumKeystoreV3)
    } catch {
      print("Error: \(error)")
      return nil
    }
  }
    
    
    // with infaura id
//  //MARK: -getTokenBalance
//    func getTokenBalance(localAddress: String, contractAddress: String, decimalCount: Double) async throws -> Double {
//    // Ensure valid Ethereum addresses
//    guard let userAddress = EthereumAddress(localAddress),
//      let tokenAddress = EthereumAddress(contractAddress, type: .contractDeployment)
//    else {
//        throw NSError(domain: "Invalid Ethereum address", code: -1, userInfo: nil)
//      
//    }
//
//    // Initialize Web3 instance
//    guard let web3 = try? await Web3.InfuraMainnetWeb3(accessToken: infuraProjectId) else {
//        throw NSError(domain: "Failed to create Web3 instance", code: -1, userInfo: nil)
//    }
//
//    // Define the ERC-20 Token Contract ABI
//    let erc20ABI = """
//      [
//          {"constant": true, "inputs": [{"name": "_owner", "type": "address"}], "name": "balanceOf", "outputs": [{"name": "balance", "type": "uint256"}], "payable": false, "stateMutability": "view", "type": "function"}
//      ]
//      """
//
//    // Create the Contract Instance
//    guard let contract = web3.contract(erc20ABI, at: tokenAddress, abiVersion: 2) else {
//        throw NSError(domain: "Failed to create contract instance", code: -1, userInfo: nil)
//   
//    }
//
//    // Prepare the Transaction Options
//    var transactionOptions = contract.transaction
//    transactionOptions.from = userAddress
//    transactionOptions.callOnBlock = .latest
//
//    // Parameters for balanceOf function
//    let parameters: [AnyObject] = [userAddress as AnyObject]
//
//    // Fetch Token Balance
//    Task {
//      do {
//        guard let readOperation = contract.createReadOperation("balanceOf", parameters: parameters)
//        else {
//            throw NSError(domain: "Failed to create read operation", code: -1, userInfo: nil)
//          
//        }
//
//        let result = try await readOperation.callContractMethod()
//
//        if let balanceBigUInt = result["0"] as? BigUInt {
//          // Assuming token has 18 decimals (common for most ERC-20 tokens)
//          let decimals: Double = decimalCount
//          let balance = Double(balanceBigUInt) / pow(10.0, decimals)
//            return balance
//         
//        } else {
//            throw NSError(domain: "Failed to fetch balance", code: -1, userInfo: nil)
//        }
//      } catch {
//          throw NSError(domain: error.localizedDescription, code: -1)
//      }
//    }
//        return 0
//  }

    
    
    //with chain id
    
    //MARK: -getTokenBalance
    
    func getTokenBalance(localAddress: String, contractAddress: String, decimalCount: Double) async throws -> Double {
        // Ensure valid Ethereum addresses
       
        guard let userAddress = EthereumAddress(localAddress),
              let tokenAddress = EthereumAddress(contractAddress) else {
            throw NSError(domain: "Invalid Ethereum address", code: -1, userInfo: nil)
        }

        // Define a dictionary to map Chain ID to RPC URLs
        let rpcUrls: [Int: String] = [
            appDataChainId: "\(baseUrl)", // Ethereum Mainnet
//            3: "https://ropsten.infura.io/v3/YOUR_INFURA_PROJECT_ID", // Ropsten Testnet
//            4: "https://rinkeby.infura.io/v3/YOUR_INFURA_PROJECT_ID", // Rinkeby Testnet
//            5: "https://goerli.infura.io/v3/YOUR_INFURA_PROJECT_ID",  // Goerli Testnet
//            42: "https://kovan.infura.io/v3/YOUR_INFURA_PROJECT_ID",  // Kovan Testnet
            // Add more RPC URLs for different chains as needed
        ]

        // Get the RPC URL from the dictionary
         guard let rpcUrl = rpcUrls[appDataChainId], let web3ProviderURL = URL(string: rpcUrl) else {
             throw NSError(domain: "Unsupported Chain ID or invalid RPC URL", code: -1, userInfo: nil)
         }

         // Initialize Web3 instance with the selected RPC URL
        guard let web3Provider = await Web3HttpProvider(web3ProviderURL, network: .Mainnet) else {
             throw NSError(domain: "Failed to create Web3 provider", code: -1, userInfo: nil)
         }

         let web3 = Web3(provider: web3Provider)

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

      
        // Parameters for balanceOf function
        let parameters: [AnyObject] = [userAddress as AnyObject]

        // Fetch Token Balance
        do {
            guard let readOperation = contract.createReadOperation("balanceOf", parameters: parameters) else {
                throw NSError(domain: "Failed to create read operation", code: -1, userInfo: nil)
            }

            let result = try await readOperation.callContractMethod()
            print("result:", result)
        
            if let balanceValue = result["balance"] {
                let balanceBigUInt = BigUInt("\(balanceValue)")//BigUInt(balanceValue) // Convert Int to BigUInt
                
                let balance = Double(balanceBigUInt!) / pow(10.0, decimalCount)
                
                return balance
            } else {
                // Handle other possible cases or throw an error if type conversion fails
                throw NSError(domain: "Failed to fetch balance: Unexpected type", code: -1, userInfo: nil)
            }
        

        } catch {
            throw NSError(domain: error.localizedDescription, code: -1)
        }
    }

   //With infaura id
//  func getWalletBalance(walletAddress: String, completion: @escaping (Double?) -> Void) async {
//    do {
//      guard let web3 = try? await Web3.InfuraMainnetWeb3(accessToken: infuraProjectId) else {
//        completion(nil)
//        return
//      }
//      let balance = try await web3.eth.getBalance(
//        for: EthereumAddress(walletAddress)!, onBlock: .latest)
//      let balanceInEther = Double(balance) / pow(10, 18)
//      completion(balanceInEther)
//    } catch {
//      completion(nil)
//    }
//  }

    //with chain id
    func getWalletBalance(walletAddress: String, completion: @escaping (Double?) -> Void) async {
        do {
            // Define a dictionary to map Chain ID to RPC URLs
            let rpcUrls: [Int: String] = [
                appDataChainId: "\(baseUrl)", // Ethereum Mainnet
//                3: "https://ropsten.infura.io/v3/YOUR_INFURA_PROJECT_ID", // Ropsten Testnet
//                4: "https://rinkeby.infura.io/v3/YOUR_INFURA_PROJECT_ID", // Rinkeby Testnet
//                5: "https://goerli.infura.io/v3/YOUR_INFURA_PROJECT_ID",  // Goerli Testnet
//                42: "https://kovan.infura.io/v3/YOUR_INFURA_PROJECT_ID",  // Kovan Testnet
                // Add more RPC URLs for different chains as needed
            ]

            // Get the RPC URL from the dictionary
            guard let rpcUrl = rpcUrls[appDataChainId], let web3ProviderURL = URL(string: rpcUrl) else {
                completion(nil)
                return
            }

            // Initialize Web3 instance with the selected RPC URL
            guard let web3Provider = await Web3HttpProvider(web3ProviderURL, network: .Mainnet) else {
                completion(nil)
                return
            }

            let web3 = Web3(provider: web3Provider)

            // Get the balance of the wallet address
            guard let walletEthereumAddress = EthereumAddress(walletAddress) else {
                completion(nil)
                return
            }

            let balance = try await web3.eth.getBalance(for: walletEthereumAddress, onBlock: .latest)
            
            let balanceInEther = Double(balance) / pow(10, 18)
            
            completion(balanceInEther)
        } catch {
            completion(nil)
        }
    }

 
//    
//    func getTransactionHash(password: String, toAddress: String, contractAddress: String, tokenAmount: Double, decimalCount: Int, addNonce: BigInteger, completion: @escaping (String?) -> Void) async {
//        // your implementation
//
//    do {
//     
//      guard let web3j = try? await Web3.InfuraMainnetWeb3(accessToken: infuraProjectId) else {
//          completion(nil)
//          return
//      }
//      let value = BigUInt("\(tokenAmount)", .ether)!
//      let gas = BigUInt("20000", .wei)!
//      let gasPrice = BigUInt("20", .gwei)!
//      var address = KeychainWrapper.standard.string(forKey: "keychain_address") ?? ""
//        
//      let nonce =
//        await getNonce(walletAddress: address, web3j: web3j) + BigUInt(addNonce.description)!
//
//      let formattedAmount = BigDecimal(floatLiteral: tokenAmount).multiply(
//        BigDecimal.ten.pow(decimalCount)
//      )
//            .setScale(0, roundingMode: .halfUp)
//      let uint256 = BigUInt(BigInt(formattedAmount.integerValue))
//      let function = Function(
//        name: "transfer",
//        parameters: [Address(toAddress), uint256],
//        emptyParameters: [])
//        
//        let bigIntValue = BigInt(value)
//        let bigUIntValue = bigIntValue.magnitude
//        if let uintValue = UInt(bigUIntValue.description) {
//            let data = try! ABIEncoder.abiEncode(uintValue)
//            print(data)
//        } else {
//            print("BigUInt value is too large for UInt")
//        }
//
//
//      let txCount = try await web3j.eth.getTransactionCount(for: EthereumAddress(address)!)
//      let transaction = Web3Core.CodableTransaction(
//        // from: EthereumAddress(address)!,
//        to: EthereumAddress(toAddress)!,
//        nonce: nonce, value: value,
//        // gas: gas,
//        data: Data(), gasPrice: gasPrice  // no data payload for this example
//      )
//      let provider = web3j.provider
//      let eth = Web3.Eth(provider: provider)
//
//      let result = try await eth.send(transaction)
//      completion(result.hash.addHexPrefix())
//
//    } catch {
//      print("Error sending transaction: \(error)")
//        completion(nil)
//    }
//  }

    
    func getTransactionHash(
        password: String,
        toAddress: String,
        contractAddress: String,
        tokenAmount: Double,
        decimalCount: Int,
        addNonce: BigInteger,
        completion: @escaping (String?) -> Void
    ) async {
        do {
            // Initialize Web3 with the provided RPC URL
            guard let web3Provider = await Web3HttpProvider(URL(string: baseUrl)!, network: .Mainnet) else {
                completion(nil)
                return
            }

            let web3 = Web3(provider: web3Provider)
            // Multiply tokenAmount by 10^decimalCount
            let amountInBaseUnits = tokenAmount * pow(10.0, Double(decimalCount))

            // Convert to BigUInt by first converting to a string without decimals
            let valueString = String(format: "%.0f", amountInBaseUnits) // Convert to string without decimals
            guard let value = BigUInt(valueString) else {
                fatalError("Failed to convert value to BigUInt")
            }
            

            // Get wallet address
            if let account = WalletManager.shared.generateNewEthereumAccount() {
                print("Private Key: \(account.privateKey)")
                print("Public Key: \(account.publicKey)")
                print("Ethereum Address: \(account.address)")
                KeychainWrapper.standard.set(account.address, forKey: "keychain_address")
                
                
                // Calculate nonce
                let nonce = await getNonce(walletAddress: account.address, web3j: web3) + BigUInt(addNonce.description)!
                
                print("Nounce:", nonce)
                // Format token amount
                let formattedAmount = BigDecimal(floatLiteral: tokenAmount).multiply(
                    BigDecimal.ten.pow(decimalCount)
                )
                    .setScale(0, roundingMode: .halfUp)
                let uint256 = BigUInt(BigInt(formattedAmount.integerValue))
                
                // Create transaction function
                let function = Function(
                    name: "transfer",
                    parameters: [Address(toAddress), uint256],
                    emptyParameters: []
                )
                
                
                // Prepare transaction data
                //  let txData = try ABIEncoder.abiEncode(function)
                let txData = try createTransactionData(toAddress: toAddress, uint256: uint256)
                
                print("txData", txData.toHexString())
                // Create transaction
                var transaction = Web3Core.CodableTransaction(
                   // from: EthereumAddress(account.address)!,
                    type: .eip1559,
                    to: EthereumAddress(contractAddress)!,
                    nonce: nonce,
                    chainID: BigUInt(appDataChainId),
                    value: 0,//value,
                    data: txData,
                    gasLimit: "80000",
                    maxFeePerGas: "10000000000",
                    maxPriorityFeePerGas: "1000000000"
                    
                )
                
                
                guard let privateKeyData = Data.fromHex(account.privateKey) else {
                       print("Error: Invalid private key")
                       return
                   }

                let keystore = try EthereumKeystoreV3(privateKey: privateKeyData, password: "12345678")
                let keyStoreManager = KeystoreManager([keystore!])
                
                try Web3Signer.signTX(transaction: &transaction, keystore: keystore!, account: EthereumAddress(account.address)!, password: "12345678")

                let signedMessage =  transaction.encode()
                var hexValue = signedMessage?.toHexString()
                print(hexValue)
                hexValue = "0x" + (hexValue ?? "")
                print(hexValue)

                // Return the transaction hash
                completion(hexValue)
            }

        } catch {
            print("Error sending transaction: \(error)")
            completion(nil)
        }
    }
   


    
    func createTransactionData(toAddress: String, uint256: BigUInt) throws -> Data {
        // Define the function signature: "transfer(address,uint256)"
        let functionSignature = "transfer(address,uint256)"
        
        // Get the function selector (first 4 bytes of the hash of the signature)
        guard let functionSelector = functionSignature.data(using: .ascii)?.sha3(.keccak256).prefix(4) else {
            throw NSError(domain: "Invalid function signature", code: 0, userInfo: nil)
        }
        
        // Encode the address parameter (left-padded to 32 bytes)
        guard let addressData = Data(hexString: toAddress.stripHexPrefix()) else {
            throw NSError(domain: "Invalid Ethereum address", code: 0, userInfo: nil)
        }
        let paddedAddress = addressData.leftPadding(toLength: 32)
        
        // Encode the uint256 parameter (left-padded to 32 bytes)
        let valueData = uint256.serialize()
        let paddedValue = valueData.leftPadding(toLength: 32)
        
        // Combine function selector and encoded parameters
        var txData = Data()
        txData.append(functionSelector)
        txData.append(paddedAddress)
        txData.append(paddedValue)
        
        return txData
    }
    
//    func getMenaHash(
//        password: String,
//        toAddress: String,
//        tokenAmount: Double,
//        addNonce: BigUInt = 0
//    ) async -> String? {
//        do {
//            guard let web3j = try? await Web3.InfuraMainnetWeb3(accessToken: infuraProjectId) else {
//                return nil
//            }
//            let value = BigUInt("\(tokenAmount)", .ether)!
//            let gas = BigUInt("20000", .wei)!
//            let gasPrice = BigUInt("20", .gwei)!
//            let address = KeychainWrapper.standard.string(forKey: "keychain_address") ?? ""
//            
//            let nonce = await getNonce(walletAddress: address, web3j: web3j) + addNonce
//            
//            let formattedAmount = BigDecimal(floatLiteral: tokenAmount)
//            let uint256 = BigUInt(BigInt(formattedAmount.integerValue))
//            
//            let transaction = Web3Core.CodableTransaction(
//                to: EthereumAddress(toAddress)!,
//                nonce: nonce, value: value,
//              //  gas: gas,
//                data: Data(), gasPrice: gasPrice
//            )
//            let provider = web3j.provider
//            let eth = Web3.Eth(provider: provider)
//            
//            let result = try await eth.send(transaction)
//            return result.hash.addHexPrefix()
//            
//        } catch {
//            print("Error sending transaction: \(error)")
//            return nil
//        }
//    }
    
    func getMenaHash(
        password: String,
        toAddress: String,
        tokenAmount: Double,
        addNonce: BigUInt = 0
    ) async -> String? {
        do {
            // Initialize Web3 with the provided RPC URL
            guard let web3Provider = await Web3HttpProvider(URL(string: baseUrl)!, network: .Mainnet) else {
                
                return nil
            }

            let web3 = Web3(provider: web3Provider)

            // Convert tokenAmount to BigUInt
            let formattedAmount = tokenAmount * pow(10.0, 18) // Assuming 18 decimals for a token like ETH
            let valueString = String(format: "%.0f", formattedAmount)
            guard let value = BigUInt(valueString) else {
                fatalError("Failed to convert value to BigUInt")
            }

//            let gas = BigUInt("20000", .wei)!
//            let gasPrice = BigUInt("20", .gwei)!
            let address = KeychainWrapper.standard.string(forKey: "keychain_address") ?? ""

            // Calculate nonce
            let nonce = await getNonce(walletAddress: address, web3j: web3) + addNonce
            print("nounce:", nonce)
            // Create the transaction
            var transaction = Web3Core.CodableTransaction(
                type: .eip1559,
               // from: EthereumAddress(address)!,
                to: EthereumAddress(toAddress)!,
                nonce: nonce,
                chainID: BigUInt(appDataChainId),
                value: value,
                gasLimit: "80000",
                maxFeePerGas: "10000000000",
                maxPriorityFeePerGas: "1000000000"
                
            )
            // Get wallet address
            if let account = WalletManager.shared.generateNewEthereumAccount() {
                print("Private Key: \(account.privateKey)")
                print("Public Key: \(account.publicKey)")
                print("Ethereum Address: \(account.address)")
                KeychainWrapper.standard.set(account.address, forKey: "keychain_address")
                
                
                print("transaction.hash?.toHexString()",transaction.hash?.toHexString())
                guard let privateKeyData = Data.fromHex(account.privateKey) else {
                    print("Error: Invalid private key")
                    return nil
                }
                
                let keystore = try EthereumKeystoreV3(privateKey: privateKeyData, password: "12345678")
                let keyStoreManager = KeystoreManager([keystore!])
                
                try Web3Signer.signTX(transaction: &transaction, keystore: keystore!, account: EthereumAddress(account.address)!, password: "12345678")
                
                let signedMessage =  transaction.encode()
                var hexValue = signedMessage?.toHexString()
                print(hexValue)
                hexValue = "0x" + (hexValue ?? "")
                print(hexValue)
                return hexValue
            }
            return nil

        } catch {
            print("Error sending transaction: \(error)")
            return nil
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
   
        // Left-pad data to a specified length with zeroes
        func leftPadding(toLength length: Int, withPad pad: UInt8 = 0) -> Data {
            if self.count >= length {
                return self
            }
            return Data(repeating: pad, count: length - self.count) + self
        }
        
        // Convert a hexadecimal string to Data
        init?(hexString: String) {
            let hex = hexString.stripHexPrefix()
            var data = Data()
            var temp = ""
            for (index, char) in hex.enumerated() {
                temp.append(char)
                if index % 2 == 1 {
                    if let byte = UInt8(temp, radix: 16) {
                        data.append(byte)
                    }
                    temp = ""
                }
            }
            if temp.isEmpty {
                self = data
            } else {
                return nil
            }
        }
}

