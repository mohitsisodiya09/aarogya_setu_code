//
//  Language.swift
//  CoMap-19
//

//
//

import Foundation

enum Language: String {
  case english = "en"
  case hindi = "hi"
  case punjabi = "pu"
  case gujarati = "gu"
  case kannada = "ka"
  case odia = "od"
  case marathi = "ma"
  case bangla = "ba"
  case malayalam = "mal"
  case telgu = "te"
  case tamil = "ta"
  case assamese = "as"
  
  var langCode: String {
    switch self {
    case .english: return "en"
    case .hindi: return "hi"
    case .punjabi: return "pa"
    case .gujarati: return "gu"
    case .kannada: return "kn"
    case .odia: return "or"
    case .marathi: return "mr"
    case .bangla: return "bn"
    case .malayalam: return "ml"
    case .telgu: return "te"
    case .tamil: return "ta"
    case .assamese: return "as"
    }
  }
  
  var name: String {
    switch self {
    case .english: return "English"
    case .hindi: return "हिन्दी"
    case .punjabi: return "ਪੰਜਾਬੀ"
    case .gujarati: return "ગુજરાતી"
    case .kannada: return "ಕನ್ನಡ"
    case .odia: return "ଓଡ଼ିଆ"
    case .marathi: return "मराठी"
    case .bangla: return "বাংলা"
    case .malayalam: return "മലയാളം"
    case .telgu: return "తెలుగు"
    case .tamil: return "தமிழ்"
    case .assamese: return "অসমীয়া"
    }
  }
  
  var accessbilityValue: String {
    switch self {
    case .english: return "English"
    case .hindi: return "Hindi"
    case .punjabi: return "Punjabi"
    case .gujarati: return "Gujarati"
    case .kannada: return "Kannada"
    case .odia: return "Odia"
    case .marathi: return "Marathi"
    case .bangla: return "Bangla"
    case .malayalam: return "Malayalam"
    case .telgu: return "Telugu"
    case .tamil: return "Tamil"
    case .assamese: return "Assamese"
    }
  }
  
}
