//
//  SpeechService.swift
//  CoMap-19
//

//
//

import UIKit
import AVFoundation

final class SpeechService {
  
  fileprivate let speech = AVSpeechSynthesizer()
  
  func speak(_ phrase: String) {
    guard UIAccessibility.isVoiceOverRunning else { return }
    
    let utterance = AVSpeechUtterance(string: phrase)
    /*let language = UserDefaults.standard.value(forKey: Constants.UserDefault.selectedLanguageKey) as? String

    if language == Language.hindi.rawValue {
      utterance.voice = AVSpeechSynthesisVoice(language: language)
    } else {
      utterance.voice = AVSpeechSynthesisVoice(language: Language.english.rawValue)
    }*/
    utterance.voice = AVSpeechSynthesisVoice(language: Language.english.rawValue)
    speech.speak(utterance)
  }
  
  func stopSpeaking() {
    speech.stopSpeaking(at: .immediate)
  }
  
}
