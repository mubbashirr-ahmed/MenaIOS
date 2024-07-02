//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

public protocol AbstractKeystore {
    var addresses: [EthereumAddress]? { get }
    var isHDKeystore: Bool { get }
    func UNSAFE_getPrivateKeyData(password: String, account: EthereumAddress) throws -> Data
}

public enum AbstractKeystoreError: Error {
    case invalidPasswordError
    case invalidAccountError(String)
    case encryptionError(String)
    case keyDerivationError(String)
    case noEntropyError(String)
    case aesError(String)
}

