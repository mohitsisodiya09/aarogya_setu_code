//
//  FileParser.swift
//

//
//

import Foundation

struct FileReadingError: Error {
  enum ErrorType {
    case fileNotFound
    case contentNotAvailable
    case notDictionary
    case parsing
    case objectMapping
    case coding
  }
  
  let kind: ErrorType
  
  var localizedDescription: String {
    var errorString = Constants.StringValues.emptyString
    switch kind {
    case .contentNotAvailable:
      errorString = NSLocalizedString("Content Not Found", comment: "")
    case .fileNotFound:
      errorString = NSLocalizedString("File Not Found", comment: "")
    case .notDictionary:
      errorString = NSLocalizedString("Not a Dictionary Type", comment: "")
    case .objectMapping:
      errorString = NSLocalizedString("Object Mapping Error", comment: "")
    case .parsing:
      errorString = NSLocalizedString("Unable to parse the content", comment: "")
    case .coding:
      errorString = NSLocalizedString("Unable to Encode/Decode the content", comment: "")
    }
    return errorString
  }
}

struct FileWritingError: Error {
  enum ErrorType {
    case locationNotFound
    case write
  }
  
  let type: ErrorType
  
  var localizedDescription: String {
    var errorString = Constants.StringValues.emptyString
    switch type {
    case .locationNotFound:
      errorString = NSLocalizedString("File Location Not Found", comment: "")
    case .write:
      errorString = NSLocalizedString("Something went wrong while writing File", comment: "")

    }
    return errorString
  }
}

final class FileParser: NSObject {
  fileprivate struct Defaults {
    static let jsonFileExtension = Constants.FileExtensions.json
  }
  
  enum FileSource: Int {
    case bundle
    case documentDirectory
    case none
  }
  
  class func removeContenOfFileInDocumentDirectory(fileName: String, fileExtension: String) throws {
    guard let fileURL = getFilePathFromDocumentDirectory(fileName: fileName, fileExtension: fileExtension), doesFileExist(at: fileURL.path) else {
      throw FileReadingError(kind: .fileNotFound)
    }
    
    removeFile(at: fileURL)
  }
  
  class func readJson(fileName: String,
                      source: FileSource,
                      bundle: Bundle = Bundle.main) throws -> [String: Any] {
    if source == .bundle {
      guard let fileURL = getFilePathFromBundle(fileName: fileName,
                                                fileExtension: Defaults.jsonFileExtension,
                                                bundle: bundle) else {
                                                  throw FileReadingError(kind: .fileNotFound)
      }
      return try serializeContentOfFile(file: fileURL)
    }
    else if source == .documentDirectory {
      guard let fileURL = getFilePathFromDocumentDirectory(fileName: fileName, fileExtension: Defaults.jsonFileExtension), doesFileExist(at: fileURL.path) else {
        throw FileReadingError(kind: .fileNotFound)
      }
      return try serializeContentOfFile(file: fileURL)
    }
    else {
      // No source
      // json as a string
      guard let data = fileName.data(using: .utf8) else {
        throw FileReadingError(kind: .coding)
      }
      let json = try JSONSerialization.jsonObject(with: data, options: [])
      if let object = json as? [String: Any] {
        // json is a dictionary
        return (object)
      }
      else {
        throw FileReadingError(kind: .notDictionary)
      }
    }
  }
  
  class func writeJson(json: [String: Any],
                       source: FileSource,
                       fileName: String,
                       bundle: Bundle = Bundle.main) throws {
    
    var fileURL: URL?
    
    if source == .documentDirectory {
      guard let filePath = getFilePathFromDocumentDirectory(fileName: fileName, fileExtension: Defaults.jsonFileExtension) else {
        throw FileWritingError(type: .locationNotFound)
      }
      fileURL = filePath
    }
    else if source == .bundle {
      guard let filePath = getFilePathFromBundle(fileName: fileName,
                                                 fileExtension: Defaults.jsonFileExtension,
                                                 bundle: bundle) else {
                                                  throw FileReadingError(kind: .fileNotFound)
      }
      
      fileURL = filePath
    }
    
    if let fileURL = fileURL {
      if doesFileExist(at: fileURL.path) {
        removeFile(at: fileURL)
      }
      
      do {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        try data.write(to: fileURL, options: [])
      }
      catch {
        throw FileWritingError(type: .write)
      }
    }
    else {
      throw FileWritingError(type: .locationNotFound)
    }
  }
  
  class func writeJson(jsonData: Data,
                       source: FileSource,
                       fileName: String,
                       bundle: Bundle = Bundle.main) throws {
    
    var fileURL: URL?
    
    if source == .documentDirectory {
      guard let filePath = getFilePathFromDocumentDirectory(fileName: fileName, fileExtension: Defaults.jsonFileExtension) else {
        throw FileWritingError(type: .locationNotFound)
      }
      fileURL = filePath
    }
    else if source == .bundle {
      guard let filePath = getFilePathFromBundle(fileName: fileName,
                                                 fileExtension: Defaults.jsonFileExtension,
                                                 bundle: bundle) else {
                                                  throw FileReadingError(kind: .fileNotFound)
      }
      
      fileURL = filePath
    }
    
    if let fileURL = fileURL {
      if doesFileExist(at: fileURL.path) {
        removeFile(at: fileURL)
      }
      
      do {
        try jsonData.write(to: fileURL, options: [])
      }
      catch {
        throw FileWritingError(type: .write)
      }
    }
    else {
      throw FileWritingError(type: .locationNotFound)
    }
  }
  
  class func writeJson(jsonData: Data,
                       source: FileSource,
                       fileName: String,
                       fileExtension: String,
                       bundle: Bundle = Bundle.main) throws {
    
    var fileURL: URL?
    
    if source == .documentDirectory {
      guard let filePath = getFilePathFromDocumentDirectory(fileName: fileName, fileExtension: fileExtension) else {
        throw FileWritingError(type: .locationNotFound)
      }
      fileURL = filePath
    }
    else if source == .bundle {
      guard let filePath = getFilePathFromBundle(fileName: fileName,
                                                 fileExtension: fileExtension,
                                                 bundle: bundle) else {
                                                  throw FileReadingError(kind: .fileNotFound)
      }
      
      fileURL = filePath
    }
    
    if let fileURL = fileURL {
      if doesFileExist(at: fileURL.path) {
        removeFile(at: fileURL)
      }
      
      do {
        try jsonData.write(to: fileURL, options: [])
      }
      catch {
        throw FileWritingError(type: .write)
      }
    }
    else {
      throw FileWritingError(type: .locationNotFound)
    }
  }
  
  fileprivate class func doesFileExist(at path: String) -> Bool {
    return FileManager().fileExists(atPath: path)
  }
  
  fileprivate class func removeFile(at path: URL) {
    try? FileManager().removeItem(at: path)
  }
  
  fileprivate class func serializeContentOfFile(file: URL) throws -> [String: Any] {
    let data = try Data(contentsOf: file)
    let json = try JSONSerialization.jsonObject(with: data, options: [])
    if let object = json as? [String: Any] {
      // json is a dictionary
      return object
    }
    else {
      throw FileReadingError(kind: .notDictionary)
    }
  }
  
  fileprivate class func getFilePathFromBundle(fileName: String,
                                               fileExtension: String,
                                               bundle: Bundle) -> URL? {
    return bundle.url(forResource: fileName, withExtension: fileExtension)
  }
  
  fileprivate class func getFilePathFromDocumentDirectory(fileName: String, fileExtension: String) -> URL? {
    let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
    let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
    let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
    var fileURL: URL?
    if let dirPath = paths.first {
      fileURL = URL(fileURLWithPath: dirPath).appendingPathComponent("\(fileName).\(fileExtension)")
    }
    return fileURL
  }
}
