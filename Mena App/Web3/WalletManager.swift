//
//  WalletManager.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 19/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import BigInt
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
    func getTokenBalance(localAddress: String, contractAddress: String, decimalCount: Double, infuraProjectId: String, completion: @escaping (Result<Double, Error>) -> Void) async {
        // Ensure valid Ethereum addresses
        guard let userAddress = EthereumAddress(localAddress), let tokenAddress = EthereumAddress(contractAddress,type: .contractDeployment) else {
            completion(.failure(NSError(domain: "Invalid Ethereum address", code: -1, userInfo: nil)))
            return
        }

        // Initialize Web3 instance
        guard let web3 = try? await Web3.InfuraMainnetWeb3(accessToken: infuraProjectId) else {
            completion(.failure(NSError(domain: "Failed to create Web3 instance", code: -1, userInfo: nil)))
            return
        }

        // Define the ERC-20 Token Contract ABI
        let erc20ABI = """
        [
            {"constant": true, "inputs": [{"name": "_owner", "type": "address"}], "name": "balanceOf", "outputs": [{"name": "balance", "type": "uint256"}], "payable": false, "stateMutability": "view", "type": "function"}
        ]
        """
        
        // Create the Contract Instance
        guard let contract = web3.contract(erc20ABI, at: tokenAddress, abiVersion: 2) else {
            completion(.failure(NSError(domain: "Failed to create contract instance", code: -1, userInfo: nil)))
            return
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
                guard let readOperation = contract.createReadOperation("balanceOf", parameters: parameters) else {
                                completion(.failure(NSError(domain: "Failed to create read operation", code: -1, userInfo: nil)))
                                return
                            }
                
                let result = try await readOperation.callContractMethod()
                
                if let balanceBigUInt = result["0"] as? BigUInt {
                    // Assuming token has 18 decimals (common for most ERC-20 tokens)
                    let decimals: Double = decimalCount
                    let balance = Double(balanceBigUInt) / pow(10.0, decimals)
                    completion(.success(balance))
                } else {
                    completion(.failure(NSError(domain: "Failed to fetch balance", code: -1, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
       }
    }
    
    func getWalletBalance(walletAddress: String, completion: @escaping (Double?) -> Void) async   {
        do {
            guard let web3 = try? await Web3.InfuraMainnetWeb3(accessToken: "infuraProjectId") else {
                completion(nil)
                return
            }
            let balance = try await web3.eth.getBalance(for: EthereumAddress(walletAddress)!, onBlock: .latest)
            let balanceInEther = Double(balance) / pow(10, 18)
            completion(balanceInEther)
        } catch {
            completion(nil)
        }
    }

}


public enum JSONRPCError: Error {
    case encodingError
    case unknownError
   // case executionError(_ errorResult: JSONRPCErrorResult)
    case requestRejected(_ data: Data)
    case noResult
}
