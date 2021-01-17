//
//  LanguageSelectionViewController.swift
//  COVID-19
//
//

import UIKit

protocol LanguageSelectionDelegate: class {
  func selectedLangauge(lang code: String)
}

class LanguageSelectionViewController: UIViewController {
  
  var indicator = UIActivityIndicatorView()
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var nextButton: UIButton! {
    didSet {
      let title = UserDefaults.standard.bool(forKey: Constants.UserDefault.languageSelectionDone) ? Localization.ok : Localization.next
      let accessibilityTitle = UserDefaults.standard.bool(forKey: Constants.UserDefault.languageSelectionDone) ? AccessibilityLabel.ok : AccessibilityLabel.next
      nextButton.setTitle(title, for: .normal)
      nextButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16.0)
      nextButton.accessibilityLabel = accessibilityTitle
    }
  }
  
  fileprivate var languages: [Language] = [.english, .hindi, .gujarati, .punjabi, .kannada, .odia, .marathi, .bangla, .malayalam, .tamil, .telgu, .assamese]
  
  fileprivate var selectedIndexPath: IndexPath?
  
  weak var delegate: LanguageSelectionDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.contentInset.bottom = 16
    tableView.estimatedRowHeight = 44
    tableView.dataSource = self
    tableView.delegate = self
    self.navigationItem.hidesBackButton = true
    navigationController?.setNavigationBarHidden(true, animated: true)
    titleLabel.text = Localization.selectLanguageTitle
    titleLabel.accessibilityLabel = AccessibilityLabel.selectLanguageTitle
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    AnalyticsManager.setScreenName(name: ScreenName.languageSelectionScreen,
                                   className: NSStringFromClass(type(of: self)))
  }
  
  @IBAction func nextButtonTapped(_ sender: UIButton) {
    if UserDefaults.standard.bool(forKey: Constants.UserDefault.languageSelectionDone),
      let langCode = UserDefaults.standard.value(forKey: Constants.UserDefault.selectedLanguageKey) as? String {
      self.delegate?.selectedLangauge(lang: langCode)
      self.dismiss(animated: true, completion: nil)
    }
    else {
      UserDefaults.standard.set(true, forKey: Constants.UserDefault.languageSelectionDone)
      let storyboard = UIStoryboard(name: Constants.Storyboard.onboarding, bundle: nil)
      let controller = storyboard.instantiateViewController(withIdentifier: Constants.ViewControllerIdentifer.onboarding)
      self.navigationController?.pushViewController(controller, animated: true)
    }
  }
  
  
  func saveSelectedLocalizationContent() {
    if let indexPath = self.selectedIndexPath {
      let langauge = self.languages[indexPath.row]
      UserDefaults.standard.set(langauge.rawValue, forKey: Constants.UserDefault.selectedLanguageKey)
      setAppLanguage(languageCode: langauge.langCode)
      updateTextOnLanguageChange()
    }
  }
  
  func setAppLanguage(languageCode code: String) {
    Localize.setAppleLanguageTo(lang: code)
  }
  
  func activityIndicator() {
    indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    indicator.style = UIActivityIndicatorView.Style.gray
    indicator.center = self.view.center
    self.view.addSubview(indicator)
  }
    
    private func updateTextOnLanguageChange(){
        titleLabel.text = Localization.selectLanguageTitle
        nextButton.setTitle(Localization.next, for: .normal)
    }
}

// MARK: - UITableViewDataSource
extension LanguageSelectionViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return languages.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: LanguageSelectionTableViewCell.reuseIdentifier,
                                                   for: indexPath) as? LanguageSelectionTableViewCell else {
      return UITableViewCell()
    }
    let backgroundView = UIView()
    backgroundView.backgroundColor = UIColor.white
    cell.selectedBackgroundView = backgroundView
    
    cell.descriptionLabel.text = languages[indexPath.row].name
    cell.descriptionLabel.accessibilityLabel = languages[indexPath.row].accessbilityValue
    return cell
  }
  
}

// MARK: - UITableViewDelegate
extension LanguageSelectionViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    nextButton.alpha = 1.0
    nextButton.isUserInteractionEnabled = true
    selectedIndexPath = indexPath
    
    NotificationCenter.default.post(Notification(name: .languageChanged,
                                                 object: nil,
                                                 userInfo: nil))
    self.saveSelectedLocalizationContent()
  }
  
}
