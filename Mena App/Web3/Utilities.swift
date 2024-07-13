//
//  Utilities.swift
//  Mena App
//
//  Created by Shoaib_iOSDeveloper on 10/07/2024.
//  Copyright © 2024 Shoaib. All rights reserved.
//

import Foundation
import Web3Core
import BigInt
import BigDecimal

public enum JSONRPCError: Error {
  case encodingError
  case unknownError
  // case executionError(_ errorResult: JSONRPCErrorResult)
  case requestRejected(_ data: Data)
  case noResult
}

extension BigDecimal {
  static let ten = BigDecimal(integerValue: 10, scale: 0)

  func multiply(_ other: BigDecimal) -> BigDecimal {
    return BigDecimal(
      integerValue: self.integerValue * other.integerValue, scale: self.scale + other.scale)
  }

  func pow(_ exponent: Int) -> BigDecimal {
    var result = BigDecimal(integerValue: 1, scale: 0)
    for _ in 0..<exponent {
      result = result.multiply(self)
    }
    return result
  }
}

extension BigDecimal {
  enum RoundingMode {
    case halfUp
    case halfDown
    case halfEven
  }

  func setScale(_ newScale: Int, roundingMode: RoundingMode) -> BigDecimal {
    if newScale > self.scale {
      let scaleDifference = newScale - self.scale
      let integerValue = self.integerValue * tenToThe(power: scaleDifference)
      return BigDecimal(integerValue: integerValue, scale: newScale)
    } else if newScale < self.scale {
      let scaleDifference = self.scale - newScale
      var integerValue = self.integerValue / tenToThe(power: scaleDifference)
      let remainder = self.integerValue % tenToThe(power: scaleDifference)

      switch roundingMode {
      case .halfUp:
        if remainder >= tenToThe(power: scaleDifference - 1) {
          integerValue += 1
        }
      case .halfDown:
        break
      case .halfEven:
        if remainder >= tenToThe(power: scaleDifference - 1) && integerValue % 2 != 0 {
          integerValue += 1
        }
      }

      return BigDecimal(integerValue: integerValue, scale: newScale)
    } else {
      return self
    }
  }

  func tenToThe(power: Int) -> BigInt {
    var result = BigInt(1)
    for _ in 0..<power {
      result *= 10
    }
    return result
  }
}

class Function {
  let name: String
  let parameters: [Any]
  let emptyParameters: [Any]

  init(name: String, parameters: [Any], emptyParameters: [Any] = []) {
    self.name = name
    self.parameters = parameters
    self.emptyParameters = emptyParameters
  }
}

public struct CodableTransaction: Codable {
  public let from: EthereumAddress
  public let to: EthereumAddress?
  public let value: BigUInt
  public let gas: BigUInt
  public let gasPrice: BigUInt
  public let nonce: BigUInt
  public let data: Data
  public let accessList: [AccessListEntry]?
  public let type: TransactionType

  public init(
    from: EthereumAddress,
    to: EthereumAddress?,
    value: BigUInt,
    gas: BigUInt,
    gasPrice: BigUInt,
    nonce: BigUInt,
    data: Data = Data(),
    accessList: [AccessListEntry]? = nil,
    type: TransactionType = .eip2930
  ) {
    self.from = from
    self.to = to
    self.value = value
    self.gas = gas
    self.gasPrice = gasPrice
    self.nonce = nonce
    self.data = data
    self.accessList = accessList
    self.type = type
  }
}
