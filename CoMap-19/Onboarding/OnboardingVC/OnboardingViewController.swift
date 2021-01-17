//
//  OnboardingViewController.swift
//  COVID-19
//
//

import UIKit

class OnboardingViewController: UIViewController {
  
  @IBOutlet weak var pageControl: UIPageControl!
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var registerButton: UIButton! {
    didSet {
      registerButton.setTitle(Localization.registerNow, for: .normal)
      registerButton.accessibilityLabel = AccessibilityLabel.registerNow
      registerButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16.0)
      registerButton.layer.cornerRadius = getButtonHeightConstraint() / 2
      registerButton.backgroundColor = UIColor(red: 57/255, green: 56/255, blue: 64/255, alpha: 1.0)
    }
  }
  
  @IBOutlet weak var buttonHeightConstrinat: NSLayoutConstraint! {
    didSet {
      buttonHeightConstrinat.constant = getButtonHeightConstraint()
    }
  }
  
  var presentedFromHome: Bool = false
  
  private struct Defaults {
    static let languageChangeButtonWidth: CGFloat = 44.0
  }
  
  private var images: [UIImage] = {
    return [UIImage(named: "1"),
            UIImage(named: "group8"),
            UIImage(named: "3"),
            UIImage(named: "group19")].compactMap({ $0 })
  }()
  
  
  private var descriptionArray: [[String: String]] = [["top": Localization.eachOneOfUs,
                                                       "bottom": Localization.wouldYouLike],
                                                      ["top": Localization.cowin20Tracks,
                                                       "bottom": Localization.simplyInstall],
                                                      ["top": Localization.youWillBeAlerted,
                                                       "bottom": Localization.theAppAlerts],
                                                      ["bottom": Localization.withCowin20]]
  
  private let accessibilityDescriptionArray: [[String: String]] = [["top": AccessibilityLabel.eachOneOfUs,
                                                                    "bottom": AccessibilityLabel.wouldYouLike],
                                                                   ["top": AccessibilityLabel.cowin20Tracks,
                                                                    "bottom": AccessibilityLabel.simplyInstall],
                                                                   ["top": AccessibilityLabel.youWillBeAlerted,
                                                                    "bottom": AccessibilityLabel.theAppAlerts],
                                                                   ["bottom": AccessibilityLabel.withCowin20]]
  
  private var tableArray:[String] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    pageControl.numberOfPages = images.count
    pageControl.isAccessibilityElement = false
    collectionView.delegate = self
    collectionView.dataSource = self
    registerButton.setTitle(presentedFromHome ? Localization.close : Localization.next, for: .normal)
    registerButton.accessibilityLabel = presentedFromHome ? AccessibilityLabel.close : AccessibilityLabel.next
    
    navigationController?.navigationBar.transparentNavigationBar()
    self.navigationItem.hidesBackButton = true
    navigationController?.setNavigationBarHidden(false, animated: true)
    self.navigationItem.rightBarButtonItem = infoButtonBarItem()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if presentedFromHome {
      AnalyticsManager.setScreenName(name: ScreenName.infoScreen,
                                     className: NSStringFromClass(type(of: self)))
    }
    else {
      AnalyticsManager.setScreenName(name: ScreenName.OnboardingScreen,
                                     className: NSStringFromClass(type(of: self)))
    }
  }
  
  @IBAction func registerButtonTapped(_ sender: UIButton) {
    if presentedFromHome {
      self.dismiss(animated: true, completion: nil)
    }
    else if self.pageControl.currentPage == (images.count - 1) {
      UserDefaults.standard.set(true, forKey: Constants.UserDefault.onboardingOpenned)
      let storyboard = UIStoryboard(name: Constants.Storyboard.main, bundle: nil)
      let controller = storyboard.instantiateViewController(withIdentifier: Constants.ViewControllerIdentifer.permissionScreen)
      let navController = UINavigationController(rootViewController: controller)
      navController.modalPresentationStyle = .fullScreen
      self.present(navController, animated: false, completion: nil)
    }
    else {
      nextPageTransition(self.pageControl.currentPage + 1)
      collectionView.scrollToItem(at: IndexPath(row: self.pageControl.currentPage, section: 0), at: .centeredHorizontally, animated: true)
    }
  }
  
  @IBAction func changeLanguageButtonTapped(_ sender: UIBarButtonItem) {
    let storyboard = UIStoryboard(name: Constants.Storyboard.languageSelection, bundle: nil)
    let controller = storyboard.instantiateViewController(withIdentifier: Constants.ViewControllerIdentifer.languageSelection)
    (controller as? LanguageSelectionViewController)?.delegate = self
    self.present(controller, animated: true, completion: nil)
  }
  
  fileprivate func infoButtonBarItem() -> UIBarButtonItem {
    let button = UIBarButtonItem(image: #imageLiteral(resourceName: "languageChangeCopy3"),
                                 style: .plain,
                                 target: self,
                                 action: #selector(changeLanguageButtonTapped))
    button.accessibilityLabel = AccessibilityLabel.languageChange
    button.width = Defaults.languageChangeButtonWidth
    return button
  }
  
  
  fileprivate func nextPageTransition(_ page: Int) {
    self.pageControl.currentPage = page
    if presentedFromHome {
      registerButton.setTitle(Localization.close, for: .normal)
      registerButton.accessibilityLabel = AccessibilityLabel.close
    }
    else {
      registerButton.setTitle(page != (images.count - 1) ? Localization.next : Localization.registerNow, for: .normal)
      registerButton.accessibilityLabel = page != (images.count - 1) ? AccessibilityLabel.next : AccessibilityLabel.registerNow
    }
    
    UIView.animate(withDuration: 0.3) {
      switch page {
      case 0:
        self.view.backgroundColor = #colorLiteral(red: 0.9825511575, green: 0.9320011139, blue: 0.9308857322, alpha: 1)
      case 1:
        self.view.backgroundColor = #colorLiteral(red: 0.9764705882, green: 0.9137254902, blue: 0.9568627451, alpha: 1)
      case 2:
        self.view.backgroundColor = #colorLiteral(red: 0.9215686275, green: 0.9137254902, blue: 0.9764705882, alpha: 1)
      case 3:
        self.view.backgroundColor = #colorLiteral(red: 0.9137254902, green: 0.968627451, blue: 0.9764705882, alpha: 1)
      default:
        self.view.backgroundColor = .white
      }
    }
  }
  
  fileprivate func getFontSize(isBold: Bool) -> UIFont {
    if let langKey = UserDefaults.standard.value(forKey: Constants.UserDefault.selectedLanguageKey) as? String {
    
      let lang = Language(rawValue: langKey)
      switch lang {
      case .english:
        let name = isBold ? "AvenirNext-Bold": "AvenirNext-Medium"
        return getFontSize(name: name, isBold: isBold)
      case .hindi, .punjabi:
        let name = isBold ? "KohinoorDevanagari-Semibold": "KohinoorDevanagari-Regular"
        return getFontSize(name: name, isBold: isBold)
      case .gujarati:
        let name = isBold ? "KohinoorGujarati-Bold" : "KohinoorGujarati-Regular"
        return getFontSize(name: name, isBold: isBold)
      case .kannada:
        let name = isBold ? "KannadaMN-Bold" : "KannadaMN"
        return getFontSize(name: name, isBold: isBold)
      case .marathi:
        let name = isBold ? "ITFDevanagariMarathi-Demi" : "ITFDevanagariMarathi-Book"
        return getFontSize(name: name, isBold: isBold)
      case .tamil:
        let name = isBold ? "TamilSangamMN-Bold": "TamilSangamMN"
        return getFontSize(name: name, isBold: isBold)
      case .malayalam:
        let name = isBold ? "MalayalamSangamMN-Bold": "MalayalamSangamMN"
        return getFontSize(name: name, isBold: isBold)
      case .odia:
        let name = isBold ? "NotoSansOriya-Bold": "NotoSansOriya"
        return getFontSize(name: name, isBold: isBold)
      case .bangla:
        let name = isBold ? "KohinoorBangla-SemiBold": "KohinoorBangla-Light"
        return getFontSize(name: name, isBold: isBold)
      case .telgu:
        let name = isBold ? "KohinoorTelugu-Medium": "KohinoorTelugu-Light"
        return getFontSize(name: name, isBold: isBold)
      case .assamese:
        let name = isBold ? "KohinoorTelugu-Medium": "KohinoorTelugu-Light"
        return getFontSize(name: name, isBold: isBold)
        
      default:
        let name = isBold ? "AvenirNext-Bold": "AvenirNext-Medium"
        return getFontSize(name: name, isBold: isBold)
      }
    }
    else{
      let name = isBold ? "AvenirNext-Bold": "AvenirNext-Medium"
      return getFontSize(name: name, isBold: isBold)
    }
  }
  
  fileprivate func getFontSize(name: String, isBold: Bool) -> UIFont {
    
    let model = UIDevice.current.screenType
    
    switch model {
        
      case .iPhones_4_4S, .iPhones_5_5s_5c_SE:
        
        if let font = UIFont(name: name, size: 14.0) {
          return font
        }
        else {
          return isBold ? UIFont.boldSystemFont(ofSize: 14.0) : UIFont.systemFont(ofSize: 14.0)
      }
      
    case .iPhones_6_6s_7_8, .iPhones_X_XS, .unknown:
      if let font = UIFont(name: name, size: 14.0) {
        return font
      }
      else {
        return isBold ? UIFont.boldSystemFont(ofSize: 16.0) : UIFont.systemFont(ofSize: 16.0)
      }
      
    case .iPhones_6Plus_6sPlus_7Plus_8Plus,
         .iPhone_XR_11,
         .iPhone_XSMax_ProMax,
         .iPhone_11Pro:
      
      if let font = UIFont(name: name, size: 14.0) {
        return font
      }
      else {
        return isBold ? UIFont.boldSystemFont(ofSize: 18.0) : UIFont.systemFont(ofSize: 18.0)
      }
    }
  }
  
  
  fileprivate func getButtonHeightConstraint() -> CGFloat {
    let model = UIDevice.current.screenType
    
    switch model {
   
    case .iPhones_4_4S:
      return 40.0
    case .iPhones_5_5s_5c_SE:
      return 40.0
    case .iPhones_6_6s_7_8:
      return 50.0
    case .iPhones_6Plus_6sPlus_7Plus_8Plus:
      return 50.0
    case .iPhones_X_XS:
      return 50.0
    case .iPhone_XR_11:
      return 50.0
    case .iPhone_XSMax_ProMax:
      return 50.0
    case .iPhone_11Pro:
      return 50.0
    case .unknown:
      return 40.0
    }
  }
  
  fileprivate func boldAppName(_ top: String, _ topText: NSMutableAttributedString?) {
    if let lang = UserDefaults.standard.value(forKey: Constants.UserDefault.selectedLanguageKey) as? String {
      
      let language = Language(rawValue: lang)
      
      switch language {
      case .english:
        let range = (top as NSString).range(of: "Aarogya Setu", options: .caseInsensitive)
        topText?.addAttribute(.font,
                              value: getFontSize(isBold: true),
                              range: range)
      case .hindi:
        let range = (top as NSString).range(of: "आरोग्य सेतु", options: .caseInsensitive)
        topText?.addAttribute(.font, value: getFontSize(isBold: true),
                              range: range)
      case .punjabi:
        let range = (top as NSString).range(of: "ਅਰੋਗਿਆ ਸੇਤੂ", options: .caseInsensitive)
        topText?.addAttribute(.font, value: getFontSize(isBold: true),
                              range: range)
        
      case .tamil:
        let range = (top as NSString).range(of: "ஆரோக்கிய சேது", options: .caseInsensitive)
        topText?.addAttribute(.font, value: getFontSize(isBold: true),
                              range: range)
        
      case .marathi:
        let range = (top as NSString).range(of: "आरोग्य सेतु", options: .caseInsensitive)
        topText?.addAttribute(.font, value: getFontSize(isBold: true),
                              range: range)
        
      case .bangla:
        let range = (top as NSString).range(of: "আরোগ্য সেতু", options: .caseInsensitive)
        topText?.addAttribute(.font, value: getFontSize(isBold: true),
                              range: range)
        
      case .odia:
        let range = (top as NSString).range(of: "Aarogya Setu", options: .caseInsensitive)
        topText?.addAttribute(.font, value: getFontSize(isBold: true),
                              range: range)
        
      case .telgu:
        let range = (top as NSString).range(of: "ఆరోగ్య సేతుతో", options: .caseInsensitive)
        topText?.addAttribute(.font, value: getFontSize(isBold: true),
                              range: range)
      case .malayalam:
        let range = (top as NSString).range(of: "ആരോഗ്യ സേതു", options: .caseInsensitive)
        topText?.addAttribute(.font, value: getFontSize(isBold: true),
                              range: range)
      case .kannada:
        let range = (top as NSString).range(of: "Aarogya Setu", options: .caseInsensitive)
        topText?.addAttribute(.font, value: getFontSize(isBold: true),
                              range: range)
        
      case .gujarati:
        let range = (top as NSString).range(of: "આરોગ્ય સેતુ", options: .caseInsensitive)
        topText?.addAttribute(.font, value: getFontSize(isBold: true),
                              range: range)
        
      case .assamese:
        let range = (top as NSString).range(of: "আৰোগ্য সেতুৱে", options: .caseInsensitive)
               topText?.addAttribute(.font, value: getFontSize(isBold: true),
                                     range: range)
        
      default:
        break
      }
    }
  }
}

// MARK: - UICollectionViewDataSource

extension OnboardingViewController: UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return images.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCollectionViewCell.reuseIdentifier,
                                                        for: indexPath) as? OnboardingCollectionViewCell else {
                                                          return UICollectionViewCell()
    }
    
    let descriptionDict = descriptionArray[indexPath.row]
    let accessibilityDict = accessibilityDescriptionArray[indexPath.row]
    
    switch indexPath.row {
    case 0,2:
      var topText: NSMutableAttributedString?
      if let top = descriptionDict["top"] {
      
        topText = NSMutableAttributedString(string: top)
        topText?.addAttribute(.font, value: getFontSize(isBold: false),
                              range: NSRange(location: 0, length: topText?.length ?? 0))
      }
  
      var bottomText: NSMutableAttributedString?
      if let bottom = descriptionDict["bottom"] {
       
        bottomText = NSMutableAttributedString(string: bottom)
        bottomText?.addAttribute(.font, value: getFontSize(isBold: false),
                                 range: NSRange(location: 0, length: bottomText?.length ?? 0))
      }
      
      cell.setupUI(image: .setImage(image: images[indexPath.row]),
                   topDescription: topText,
                   topAccessibilityDescription: accessibilityDict["top"],
                   bottomDescription: bottomText,
                   bottomAccessibilityDescription: accessibilityDict["bottom"])
    case 1:
      var topText: NSMutableAttributedString?
      if let top = descriptionDict["top"] {
       
        topText = NSMutableAttributedString(string: top)
        topText?.addAttribute(.font, value: getFontSize(isBold: false),
                              range: NSRange(location: 0, length: topText?.length ?? 0))
        boldAppName(top, topText)
      }
      var bottomText: NSMutableAttributedString?
      if let bottom = descriptionDict["bottom"] {
       
        bottomText = NSMutableAttributedString(string: bottom)
        bottomText?.addAttribute(.font, value: getFontSize(isBold: false), range: NSRange(location: 0, length: bottomText?.length ?? 0))
       
        switch UserDefaults.standard.value(forKey: Constants.UserDefault.selectedLanguageKey) as? String {
        case "en":
          bottomText?.addAttribute(.font, value: getFontSize(isBold: true), range: NSRange(location: 11, length: 7))
          bottomText?.addAttribute(.font, value: getFontSize(isBold: true), range: NSRange(location: 40, length: 20))
          bottomText?.addAttribute(.font, value: getFontSize(isBold: true), range: NSRange(location: 63, length: 13))
        default:
          break
        }
      }
      
      cell.setupUI(image: .setHorizontalImage(image: images[indexPath.row]),
                   topDescription: topText,
                   topAccessibilityDescription: accessibilityDict["top"],
                   bottomDescription: bottomText,
                   bottomAccessibilityDescription: accessibilityDict["bottom"])
    case 3:
      var bottomText: NSMutableAttributedString?
      if let bottom = descriptionDict["bottom"] {
        bottomText = NSMutableAttributedString(string: bottom)
        bottomText?.addAttribute(.font, value: getFontSize(isBold: false),
                                 range: NSRange(location: 0, length: bottomText?.length ?? 0))
        boldAppName(bottom, bottomText)
      }
      
      cell.setupUI(image: .setVerticalImage(image: images[indexPath.row]),
                   topDescription: nil,
                   topAccessibilityDescription: nil,
                   bottomDescription: bottomText,
                   bottomAccessibilityDescription: accessibilityDict["bottom"])
    default:
      break
    }
    
    return cell
  }
  
}

// MARK: - UICollectionViewDelegate

extension OnboardingViewController : UICollectionViewDelegate {
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let pageWidth: CGFloat = self.collectionView.frame.size.width;
    let page = Int(self.collectionView.contentOffset.x / pageWidth)
    nextPageTransition(page)
  }
  
}

// MARK: - UICollectionViewDelegateFlowLayout

extension OnboardingViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: UIScreen.main.bounds.width, height: collectionView.bounds.height)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0.0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0.0
  }
  
}

extension OnboardingViewController: LanguageSelectionDelegate {
  func selectedLangauge(lang code: String) {
    
    let pageWidth: CGFloat = self.collectionView.frame.size.width;
    let page = Int(self.collectionView.contentOffset.x / pageWidth)
    nextPageTransition(page)
    
    descriptionArray =  [["top": Localization.eachOneOfUs,
                          "bottom": Localization.wouldYouLike],
                         ["top": Localization.cowin20Tracks,
                          "bottom": Localization.simplyInstall],
                         ["top": Localization.youWillBeAlerted,
                          "bottom": Localization.theAppAlerts],
                         ["bottom": Localization.withCowin20]]
    collectionView.reloadData()
  }
}
