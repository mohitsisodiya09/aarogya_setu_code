//
//  ConfirmNumberHeader.swift
//  CoMap-19
//

//

import UIKit

protocol ConfirmNumberHeaderDelegate: AnyObject {
  func confirmNumberHeader(valueChanged mobileNumber: String, countryCode: String)
}

class ConfirmNumberHeader: UIView {
  
  // MARK: - Outlets
  
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var countryCodeTextField: UITextField! {
    didSet {
      countryCodeTextField.text = "+91"
      countryCodeTextField.delegate = self
      countryCodeTextField.keyboardType = .numbersAndPunctuation
      countryCodeTextField.placeholder = Localization.countryCode
      countryCodeTextField.tintColor = UIColor.black
      countryCodeTextField.accessibilityLabel = AccessibilityLabel.countryCode
    }
  }
  
  @IBOutlet weak var mobileNumberTextField: FloatingLabelTextField! {
    didSet {
      mobileNumberTextField.delegate = self
      mobileNumberTextField.keyboardType = .numberPad
      mobileNumberTextField.placeholder = Localization.mobileNumber
      mobileNumberTextField.accessibilityLabel = AccessibilityLabel.mobileNumber
    }
  }
  
  // MARK: - Private members
  
  private let mobileNumberFieldTextLimit: Int = 10
  
  // MARK: - Public members
  
  weak var delegate: ConfirmNumberHeaderDelegate?
  
  // MARK: - Init
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  // MARK: - Private members
  
  fileprivate struct Defaults {
    static let nibName = "ConfirmNumberHeader"
  }
  
  // MARK: - Private Methods
  
  fileprivate func setup() {
    Bundle.main.loadNibNamed(Defaults.nibName, owner: self, options: nil)
    addSubview(contentView)
    contentView.frame = self.bounds
    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    addDoneButtonToTextField()
    countryCodeTextField.addTarget(self, action: #selector(countryCodeValueChanged), for: UIControl.Event.editingChanged)
    mobileNumberTextField.addTarget(self, action: #selector(phoneNumberValueChange), for: UIControl.Event.editingChanged)
    
  }
  
  // MARK: - Private methods
  @objc private func phoneNumberValueChange() {
    delegate?.confirmNumberHeader(valueChanged: mobileNumberTextField.text ?? "", countryCode: countryCodeTextField.text ?? "+91")
  }
  
  @objc private func countryCodeValueChanged() {
    delegate?.confirmNumberHeader(valueChanged: mobileNumberTextField.text ?? "", countryCode: countryCodeTextField.text ?? "+91")
  }
  
  fileprivate func addBottomBorder(color: UIColor) {
    let bottomLine = CALayer()
    bottomLine.frame = CGRect(x: 0.0, y: countryCodeTextField.frame.height - 1, width: countryCodeTextField.frame.width, height: 1.0)
    bottomLine.backgroundColor = color.cgColor
    countryCodeTextField.borderStyle = UITextField.BorderStyle.none
    countryCodeTextField.layer.addSublayer(bottomLine)
  }
  
  fileprivate func addDoneButtonToTextField() {
    let toolbar = UIToolbar()
    toolbar.sizeToFit()
    
    let doneButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""),
                                     style: .done, target: self,
                                     action: #selector(doneButtonAction(_:)))
    toolbar.setItems([doneButton], animated: true)
    
    countryCodeTextField.inputAccessoryView = toolbar
    mobileNumberTextField.inputAccessoryView = toolbar
  }
  
  // MARK: - Button Actions
  @IBAction private func doneButtonAction(_ sender: UIButton) {
    UIApplication.topViewController()?.view.endEditing(true)
  }
  
}

// MARK: - UITextFieldDelegate
extension ConfirmNumberHeader: UITextFieldDelegate {
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    if textField == countryCodeTextField {
      addBottomBorder(color: UIColor.black)
    }
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if textField == mobileNumberTextField {
      let newLength = (textField.text ?? "").utf16.count + string.utf16.count - range.length
      return newLength <= mobileNumberFieldTextLimit
    }
    return true
  }
}

