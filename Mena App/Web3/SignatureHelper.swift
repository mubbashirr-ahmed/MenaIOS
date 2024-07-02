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
    class func getSignature(messageBytes: [UInt8], ecKeyPair: EthereumKeystoreV3, password: String) -> String? {
        do {
            let data = Data(messageBytes)
            let hash = Utilities.hashPersonalMessage(data)!
            let (r, s, v) = try ecKeyPair.signHash(hash: hash, password: password)

            let signatureR = r.toHexString().addHexPrefix()
            let signatureS = s.toHexString().addHexPrefix()
            let signatureV = String(format: "%02x", v)

            return signatureR + signatureS + signatureV
        } catch {
            print("Error generating signature: \(error)")
            return nil
        }
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
        let signature = SECP256K1.signForRecovery(hash: hash, privateKey: privateKey)

        guard let serializedSignature = signature.serializedSignature, let rawSignature = signature.rawSignature else {
            throw NSError(domain: "EthereumKeystoreV3", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to sign hash"])
        }

        let r = serializedSignature.prefix(32)
        let s = serializedSignature.suffix(32)
        let v = rawSignature.last ?? 0

        return (r, s, v)
    }
}
