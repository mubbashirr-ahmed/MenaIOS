//
//  SignatureHelper.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 24/06/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation
import Web3Core
import web3swift

class SignatureHelper {
//    class func getSignature(messageBytes: [UInt8], ecKeyPair: EthereumKeystoreV3, password: String) -> String? {
//        do {
//            // Convert message bytes to Data
//            let data = Data(messageBytes)
//            
//            // Apply the Ethereum-specific prefix
//            let prefixedMessage = "\u{19}Ethereum Signed Message:\n\(messageBytes.count)\(String(bytes: messageBytes, encoding: .utf8) ?? "")"
//            print("Prefixed Message : ", prefixedMessage)
//            let prefixedMessageData = Data(prefixedMessage.utf8)
//            
//            // Hash the prefixed message
//            let hash = Utilities.hashPersonalMessage(prefixedMessageData)!
//            
//            // Sign the hash
//            var (r, s, v) = try ecKeyPair.signHash(hash: hash, password: password)
//            
////            // Adjust the v value (add 27)
////            v = v + 27
////            
//            // Convert r, s, and v to hex strings
//            let signatureR = r.toHexString().addHexPrefix() // Hex string of r
//            let signatureS = s.toHexString() // Hex string of s
//            let signatureV = String(format: "%02x", v) // Hex string of v
//            
//            // Print debug information
//            print("eckeyPair")
//            print(ecKeyPair)
//            print("signatureR: \(signatureR)\n signatureS: \(signatureS)\n signatureV: \(signatureV)")
//            
//            // Concatenate r, s, and v to form the final signature
//            return signatureR + signatureS + signatureV
//        } catch {
//            // Handle errors during signature generation
//            print("Error generating signature: \(error)")
//            return nil
//        }
//    }
    
    
    class func getSignature(messageBytes: [UInt8], ecKeyPair: EthereumKeystoreV3, password: String) -> String? {
          do {
              // Convert message bytes to Data
              let data = Data(messageBytes)
              
              // Apply the Ethereum-specific prefix
              let messageLength = String(messageBytes.count)
              let prefixedMessage = "\u{19}Ethereum Signed Message:\n\(messageLength)\(String(bytes: messageBytes, encoding: .utf8) ?? "")"
              let prefixedMessageData = Data(prefixedMessage.utf8)
              
              // Hash the prefixed message
              let hash = Utilities.hashPersonalMessage(prefixedMessageData)!
              
              let account = ecKeyPair.addresses?.first!
              let signatureData = try Web3Signer.signPersonalMessage(data, keystore: ecKeyPair, account: account!, password: password)
                          
              // Concatenate r, s, and v to form the final signature
              return signatureData?.toHexString()//signatureR + signatureS + signatureV
          } catch {
              // Handle errors during signature generation
              print("Error generating signature: \(error)")
              return nil
          }
      }
    
    
    
    
    
    
    class func derivePrivateKey(fromPassword password: String) -> Data {
        // This is just a placeholder. Replace it with actual logic to derive the private key
        // e.g., using PBKDF2, or any other key derivation function.
        return password.data(using: .utf8)!.sha256()
    }

   class func verifySignature(message: String, password: String) -> Bool? {
        // Derive the private key from the password
        let privateKey = derivePrivateKey(fromPassword: password)
        
        guard let keystore = try? EthereumKeystoreV3(privateKey: privateKey, password: password) else {
            return false
        }
        
        var publicKey = ""
        if let account = WalletManager.shared.generateNewEthereumAccount() {
          print("Private Key: \(account.privateKey)")
          
          print("Public Key: \(account.publicKey)")
            publicKey = account.publicKey
          print("Ethereum Address: \(account.address)")
        }
        
        // Sign the message
        guard let signature = try? Web3Signer.signPersonalMessage(message.data(using: .utf8)!, keystore: keystore, account: keystore.addresses!.first!, password: password) else {
            return false
        }

        // Recover the public key from the signature
        let prefixedMessage = Utilities.hashPersonalMessage(message.data(using: .utf8)!)
        let recoveredPublicKey = try? Utilities.hashECRecover(hash: message.data(using: .utf8)!, signature: signature)
        guard let recoveredPublicKey = SECP256K1.recoverPublicKey(hash: message.data(using: .utf8)!, signature: signature) else { return nil }
        let publicKeyData = Data(publicKey.utf8)
        // Compare the recovered public key with the derived public key
        return publicKeyData == recoveredPublicKey
    }
    



    
    
    
    
}
extension Data {
    func toHexString() -> String {
        return map { String(format: "%02x", $0) }.joined()
    }
    
    func addHexPrefix() -> String {
        return "0x" + self.toHexString()
    }
}


extension EthereumKeystoreV3 {
    
    func signHash(hash: Data, password: String) throws -> (r: Data, s: Data, v: UInt8) {
        
        guard let privateKeyData = try? self.UNSAFE_getPrivateKeyData(password: password, account: self.address!) else {
            throw NSError(domain: "EthereumKeystoreV3", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to extract private key"])
        }

        let privateKey = privateKeyData
        print("privateKey:", privateKey)
        let signature = SECP256K1.signForRecovery(hash: hash, privateKey: privateKey)

        guard let serializedSignature = signature.serializedSignature, let rawSignature = signature.rawSignature else {
            throw NSError(domain: "EthereumKeystoreV3", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to sign hash"])
        }

        let r = serializedSignature.prefix(32)
        let s = serializedSignature.suffix(32)
        var v = rawSignature.last ?? 0

        // Adjust the v value by adding 27
        v = v + 27

        return (r, s, v)
    }

}
