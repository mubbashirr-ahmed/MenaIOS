//
//  AESCrypt.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 18/07/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation
import CommonCrypto

class AESCrypt {
    private static let key = "1234567890abcdef"

    private static func encrypt(plaintext: String) -> String? {
        guard let keyData = key.data(using: .utf8) else { return nil }
        guard let plaintextData = plaintext.data(using: .utf8) else { return nil }

        let iv = AESCrypt.generateRandomIV()
        do {
            let encryptedData = try AESCrypt.encrypt(plaintextData, key: keyData, iv: iv)
            let encryptedString = encryptedData.base64EncodedString()
            let ivString = iv.base64EncodedString()
            return "\(ivString)\(encryptedString)"
        } catch {
            print("Error encrypting: \(error)")
            return nil
        }
    }
    private static func decrypt(ciphertext: String) -> String? {
        guard let ciphertextData = ciphertext.data(using: .utf8) else { return nil }
        guard let keyData = key.data(using: .utf8) else { return nil }

        let ivData = ciphertextData.subdata(in: 0..<24)
        let encryptedData = ciphertextData.subdata(in: 24..<ciphertextData.count)

        do {
            let decryptedData = try AESCrypt.decrypt(encryptedData, key: keyData, iv: ivData)
            return String(data: decryptedData, encoding: .utf8)
        } catch {
            print("Error decrypting: \(error)")
            return nil
        }
    }

    public static func driver(text: String) throws -> String {
        guard let decryptedText = decrypt(ciphertext: text) else {
            throw NSError(domain: "Invalid QR Code", code: 0, userInfo: nil)
        }
        return decryptedText
    }

    private static func generateRandomIV() -> Data {
        var localIV = Data(count: 16)
        let count = localIV.count
        localIV.withUnsafeMutableBytes { ivBytes in
            SecRandomCopyBytes(kSecRandomDefault, count, ivBytes)
        }
        return localIV
    }

    private static func encrypt(_ plaintext: Data, key: Data, iv: Data) throws -> Data {
        let cryptData = NSMutableData(length: Int(plaintext.count) + kCCBlockSizeAES128)!
        let keyLength = size_t(kCCKeySizeAES256)
        let operation: CCOperation = UInt32(kCCEncrypt)
        let algoritm: CCAlgorithm = UInt32(kCCAlgorithmAES128)
        let options: CCOptions = UInt32(kCCOptionPKCS7Padding)

        var numBytesEncrypted: size_t = 0

        let cryptStatus = CCCrypt(operation,
                                  algoritm,
                                  options,
                                  (key as NSData).bytes,
                                  keyLength,
                                  (iv as NSData).bytes,
                                  plaintext.bytes,
                                  plaintext.count,
                                  cryptData.mutableBytes,
                                  cryptData.length,
                                  &numBytesEncrypted)

        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            cryptData.length = Int(numBytesEncrypted)
            return cryptData as Data
        } else {
            throw NSError(domain: "Error encrypting", code: Int(cryptStatus), userInfo: nil)
        }
    }

    private static func decrypt(_ ciphertext: Data, key: Data, iv: Data) throws -> Data {
        let plaintextLength = ciphertext.count
        let plaintext = NSMutableData(length: plaintextLength)!
        let keyLength = size_t(kCCKeySizeAES256)
        let operation: CCOperation = UInt32(kCCDecrypt)
        let algoritm: CCAlgorithm = UInt32(kCCAlgorithmAES128)
        let options: CCOptions = UInt32(kCCOptionPKCS7Padding)

        var numBytesDecrypted: size_t = 0

        let cryptStatus = CCCrypt(operation,
                                  algoritm,
                                  options,
                                  (key as NSData).bytes,
                                  keyLength,
                                  (iv as NSData).bytes,
                                  ciphertext.bytes,
                                  ciphertext.count,
                                  plaintext.mutableBytes,
                                  plaintext.length,
                                  &numBytesDecrypted)

        if UInt32(cryptStatus) == UInt32(kCCSuccess) {
            plaintext.length = Int(numBytesDecrypted)
            return plaintext as Data
        } else {
            throw NSError(domain: "Error decrypting", code: Int(cryptStatus), userInfo: nil)
        }
    }
}
