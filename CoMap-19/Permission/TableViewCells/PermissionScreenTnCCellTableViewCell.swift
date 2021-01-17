//
//  PermissionScreenTnCCellTableViewCell.swift
//  CoMap-19
//
//
//

import UIKit

protocol PermissionScreenTnCCellTableViewCellDelegate: AnyObject {
  func permissionScreenTnCCellTableViewCell(_ cell: PermissionScreenTnCCellTableViewCell,
                                            urlTapped url: URL)
}

class PermissionScreenTnCCellTableViewCell: UITableViewCell {
  
  @IBOutlet private weak var textView: UITextView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    textView.font = UIFont(name: "AvenirNext-Regular", size: 14)
    textView.isScrollEnabled = false
    textView.delegate = self
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  weak var delegate: PermissionScreenTnCCellTableViewCellDelegate?
  
  func addHyperLink(){
    
    textView.text = Localization.permissionScreenTnC
    
    let myAttribute = [ NSAttributedString.Key.font: UIFont(name: "AvenirNext-Regular", size: 14)! ]
    
    let attributedString = NSMutableAttributedString(string: textView.text, attributes: myAttribute)
    let tncURL = URL(string: Constants.WebUrl.tncPage)!
    let privacyURL = URL(string: Constants.WebUrl.privacyPage)!
    
    
    if let lang = UserDefaults.standard.value(forKey: Constants.UserDefault.selectedLanguageKey) as? String {
      let language = Language(rawValue: lang)
      switch language {
      case .english:
        attributedString.setAttributes([.link: tncURL],
                                       range: (textView.text as NSString).range(of: "Terms of Service", options: .caseInsensitive))
        attributedString.setAttributes([.link: privacyURL],
                                       range: (textView.text as NSString).range(of: "Privacy Policy", options: .caseInsensitive))
      case .hindi:
        attributedString.setAttributes([.link: tncURL],
                                       range: (textView.text as NSString).range(of: "सेवा", options: .caseInsensitive))
        attributedString.setAttributes([.link: privacyURL],
                                       range: (textView.text as NSString).range(of: "गोपनीयता की शर्तों", options: .caseInsensitive))
      case .telgu:
        attributedString.setAttributes([.link: tncURL],
                                       range: (textView.text as NSString).range(of: "సర్వీస్", options: .caseInsensitive))
        attributedString.setAttributes([.link: privacyURL],
                                       range: (textView.text as NSString).range(of: "ప్రైవసీ పాలసీ", options: .caseInsensitive))
      case .marathi:
        attributedString.setAttributes([.link: tncURL],
                                       range: (textView.text as NSString).range(of: "सेवा", options: .caseInsensitive))
        attributedString.setAttributes([.link: privacyURL],
                                       range: (textView.text as NSString).range(of: "गोपनीयता धोरण", options: .caseInsensitive))
      case .bangla:
        attributedString.setAttributes([.link: tncURL],
                                       range: (textView.text as NSString).range(of: "পরিষেবার শর্তাদি(Terms of Service)", options: .caseInsensitive))
        attributedString.setAttributes([.link: privacyURL],
                                       range: (textView.text as NSString).range(of: "গোপনীয়তা নীতি(Privacy Policy)", options: .caseInsensitive))
      case .odia:
        attributedString.setAttributes([.link: tncURL],
                                       range: (textView.text as NSString).range(of: "ସେବା ସର୍ତ୍ତାବଳୀ", options: .caseInsensitive))
        attributedString.setAttributes([.link: privacyURL],
                                       range: (textView.text as NSString).range(of: "ଗୋପନୀୟତା ନୀତିକୁ", options: .caseInsensitive))
      case .punjabi:
        attributedString.setAttributes([.link: tncURL],
                                       range: (textView.text as NSString).range(of: "ਸੇਵਾ ਦੀਆਂ ਸ਼ਰਤਾਂ", options: .caseInsensitive))
        attributedString.setAttributes([.link: privacyURL],
                                       range: (textView.text as NSString).range(of: "ਗੋਪਨੀਯਤਾ ਨੀਤੀ", options: .caseInsensitive))
      case .malayalam:
        attributedString.setAttributes([.link: tncURL],
                                       range: (textView.text as NSString).range(of: "സേവന നിബന്ധനകളും", options: .caseInsensitive))
        attributedString.setAttributes([.link: privacyURL],
                                       range: (textView.text as NSString).range(of: "സ്വകാര്യതാ നയവും", options: .caseInsensitive))
      case .kannada:
        attributedString.setAttributes([.link: tncURL],
                                       range: (textView.text as NSString).range(of: "ನಿಯಮಗಳು", options: .caseInsensitive))
        attributedString.setAttributes([.link: privacyURL],
                                       range: (textView.text as NSString).range(of: "ಗೌಪ್ಯತಾ ನೀತಿಗಳಿಗೆ", options: .caseInsensitive))
      case .gujarati:
        attributedString.setAttributes([.link: tncURL],
                                       range: (textView.text as NSString).range(of: "સેવાની શરતો", options: .caseInsensitive))
        attributedString.setAttributes([.link: privacyURL],
                                       range: (textView.text as NSString).range(of: "ગોપનીયતા નીતિ", options: .caseInsensitive))
        case .tamil:
        attributedString.setAttributes([.link: tncURL],
                                       range: (textView.text as NSString).range(of: "சேவை விதிமுறைகள்", options: .caseInsensitive))
        attributedString.setAttributes([.link: privacyURL],
                                       range: (textView.text as NSString).range(of: "தனியுரிமைக் கொள்கையை", options: .caseInsensitive))
        
      case .assamese:
        attributedString.setAttributes([.link: tncURL],
                                       range: (textView.text as NSString).range(of: "Terms of Service", options: .caseInsensitive))
        attributedString.setAttributes([.link: privacyURL],
                                       range: (textView.text as NSString).range(of: "Privacy Policy", options: .caseInsensitive))
      default:
        break
      }
    }
    
    self.textView.attributedText = attributedString
    self.textView.isUserInteractionEnabled = true
    self.textView.isEditable = false
    
    // Set how links should appear: blue and underlined
    self.textView.linkTextAttributes = [
      .foregroundColor: UIColor(red: 61/255, green: 129/255, blue: 228/255, alpha: 1.0),
      .underlineStyle: 0
    ]
    
    let originalText = NSMutableAttributedString(attributedString: textView.attributedText)
    let newString = NSMutableAttributedString(attributedString: textView.attributedText)
    
    originalText.enumerateAttributes(in: NSRange(0..<originalText.length), options: .reverse) { (attributes, range, pointer) in
      
      if let _ = attributes[NSAttributedString.Key.link] {
        newString.removeAttribute(NSAttributedString.Key.font, range: range)
        
        if let font = UIFont(name: "AvenirNext-DemiBold", size: 14) {
          newString.addAttribute(.font,
                                 value: font,
                                 range: range)
        }
      }
    }
    
    self.textView.attributedText = newString // updates the text view on the vc
    
  }
  
}

extension PermissionScreenTnCCellTableViewCell: UITextViewDelegate {
  
  func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
    
    delegate?.permissionScreenTnCCellTableViewCell(self, urlTapped: URL)
    
    return false
  }
}
