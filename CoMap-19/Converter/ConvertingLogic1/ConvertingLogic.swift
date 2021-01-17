//
//  ConvertingLogic.swift
//  CoMap-19
//

//

import Foundation
import CommonCrypto

protocol Convertable {
  func convert(_ data: Data) throws -> Data
  func convertback(_ data: Data) throws -> String
  func convertback(to data: Data) throws -> Data
  static func generateRandom32BitKey() -> String
}

protocol Randomizer {
  static func randomIv() -> Data
  static func randomSalt() -> Data
  static func randomData(length: Int) -> Data
}

struct ConvertingLogic {
  private let key: Data
  private let ivSize: Int         = kCCBlockSizeAES128
  private let options: CCOptions  = CCOptions(kCCOptionPKCS7Padding)
  
  init(keyString: String) throws {
    guard keyString.count == kCCKeySizeAES256 else {
      throw Error.invalidKeySize
    }
    self.key = Data(keyString.utf8)
  }
}

extension ConvertingLogic {
  enum Error: Swift.Error {
    case invalidKeySize
    case generateRandomIVFailed
    case encryptionFailed
    case decryptionFailed
    case dataToStringFailed
  }
}

private extension ConvertingLogic {
  
  static func generateRandomIV(for data: inout Data) throws {
    
    try data.withUnsafeMutableBytes { dataBytes in
      
      guard let dataBytesBaseAddress = dataBytes.baseAddress else {
        throw Error.generateRandomIVFailed
      }
      
      let status: Int32 = SecRandomCopyBytes(
        kSecRandomDefault,
        kCCBlockSizeAES128,
        dataBytesBaseAddress
      )
      
      guard status == 0 else {
        throw Error.generateRandomIVFailed
      }
    }
  }
}

extension ConvertingLogic: Convertable {
  
  static func generateRandom32BitKey() -> String {
   let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let allowedCharsCount = UInt32(allowedChars.count)
    var randomString = ""

    for _ in 0..<32 {
        let randomNum = Int(arc4random_uniform(allowedCharsCount))
        let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
        let newCharacter = allowedChars[randomIndex]
        randomString += String(newCharacter)
    }

    return randomString
  }
  
  func convert(_ data: Data) throws -> Data {
    
    let bufferSize: Int = ivSize + data.count + kCCBlockSizeAES128
    var buffer = Data(count: bufferSize)
    try ConvertingLogic.generateRandomIV(for: &buffer)
    
    var numberBytesEncrypted: Int = 0
    
    do {
      try key.withUnsafeBytes { keyBytes in
        try data.withUnsafeBytes { dataToEncryptBytes in
          try buffer.withUnsafeMutableBytes { bufferBytes in
            
            guard let keyBytesBaseAddress = keyBytes.baseAddress,
              let dataToEncryptBytesBaseAddress = dataToEncryptBytes.baseAddress,
              let bufferBytesBaseAddress = bufferBytes.baseAddress else {
                throw Error.encryptionFailed
            }
            
            let cryptStatus: CCCryptorStatus = CCCrypt( // Stateless, one-shot encrypt operation
              CCOperation(kCCEncrypt),                // op: CCOperation
              CCAlgorithm(kCCAlgorithmAES),           // alg: CCAlgorithm
              options,                                // options: CCOptions
              keyBytesBaseAddress,                    // key: the "password"
              key.count,                              // keyLength: the "password" size
              bufferBytesBaseAddress,                 // iv: Initialization Vector
              dataToEncryptBytesBaseAddress,          // dataIn: Data to encrypt bytes
              dataToEncryptBytes.count,               // dataInLength: Data to encrypt size
              bufferBytesBaseAddress + ivSize,        // dataOut: encrypted Data buffer
              bufferSize,                             // dataOutAvailable: encrypted Data buffer size
              &numberBytesEncrypted                   // dataOutMoved: the number of bytes written
            )
            
            guard cryptStatus == CCCryptorStatus(kCCSuccess) else {
              throw Error.encryptionFailed
            }
          }
        }
      }
      
    } catch {
      throw Error.encryptionFailed
    }
    
    let encryptedData: Data = buffer[..<(numberBytesEncrypted + ivSize)]
    return encryptedData
  }
  
  func convertback(_ data: Data) throws -> String {
    
    let bufferSize: Int = data.count - ivSize
    var buffer = Data(count: bufferSize)
    
    var numberBytesDecrypted: Int = 0
    
    do {
      try key.withUnsafeBytes { keyBytes in
        try data.withUnsafeBytes { dataToDecryptBytes in
          try buffer.withUnsafeMutableBytes { bufferBytes in
            
            guard let keyBytesBaseAddress = keyBytes.baseAddress,
              let dataToDecryptBytesBaseAddress = dataToDecryptBytes.baseAddress,
              let bufferBytesBaseAddress = bufferBytes.baseAddress else {
                throw Error.encryptionFailed
            }
            
            let cryptStatus: CCCryptorStatus = CCCrypt( // Stateless, one-shot encrypt operation
              CCOperation(kCCDecrypt),                // op: CCOperation
              CCAlgorithm(kCCAlgorithmAES128),        // alg: CCAlgorithm
              options,                                // options: CCOptions
              keyBytesBaseAddress,                    // key: the "password"
              key.count,                              // keyLength: the "password" size
              dataToDecryptBytesBaseAddress,          // iv: Initialization Vector
              dataToDecryptBytesBaseAddress + ivSize, // dataIn: Data to decrypt bytes
              bufferSize,                             // dataInLength: Data to decrypt size
              bufferBytesBaseAddress,                 // dataOut: decrypted Data buffer
              bufferSize,                             // dataOutAvailable: decrypted Data buffer size
              &numberBytesDecrypted                   // dataOutMoved: the number of bytes written
            )
            
            guard cryptStatus == CCCryptorStatus(kCCSuccess) else {
              throw Error.decryptionFailed
            }
          }
        }
      }
    } catch {
      throw Error.encryptionFailed
    }
    
    let decryptedData: Data = buffer[..<numberBytesDecrypted]
    
    guard let decryptedString = String(data: decryptedData, encoding: .utf8) else {
      throw Error.dataToStringFailed
    }
    
    return decryptedString
  }
  
  func convertback(to data: Data) throws -> Data {
    
    let bufferSize: Int = data.count - ivSize
    var buffer = Data(count: bufferSize)
    
    var numberBytesDecrypted: Int = 0
    
    do {
      try key.withUnsafeBytes { keyBytes in
        try data.withUnsafeBytes { dataToDecryptBytes in
          try buffer.withUnsafeMutableBytes { bufferBytes in
            
            guard let keyBytesBaseAddress = keyBytes.baseAddress,
              let dataToDecryptBytesBaseAddress = dataToDecryptBytes.baseAddress,
              let bufferBytesBaseAddress = bufferBytes.baseAddress else {
                throw Error.encryptionFailed
            }
            
            let cryptStatus: CCCryptorStatus = CCCrypt( // Stateless, one-shot encrypt operation
              CCOperation(kCCDecrypt),                // op: CCOperation
              CCAlgorithm(kCCAlgorithmAES128),        // alg: CCAlgorithm
              options,                                // options: CCOptions
              keyBytesBaseAddress,                    // key: the "password"
              key.count,                              // keyLength: the "password" size
              dataToDecryptBytesBaseAddress,          // iv: Initialization Vector
              dataToDecryptBytesBaseAddress + ivSize, // dataIn: Data to decrypt bytes
              bufferSize,                             // dataInLength: Data to decrypt size
              bufferBytesBaseAddress,                 // dataOut: decrypted Data buffer
              bufferSize,                             // dataOutAvailable: decrypted Data buffer size
              &numberBytesDecrypted                   // dataOutMoved: the number of bytes written
            )
            
            guard cryptStatus == CCCryptorStatus(kCCSuccess) else {
              throw Error.decryptionFailed
            }
          }
        }
      }
    } catch {
      throw Error.encryptionFailed
    }
    
    let decryptedData: Data = buffer[..<numberBytesDecrypted]
    
    return decryptedData
  }
}
