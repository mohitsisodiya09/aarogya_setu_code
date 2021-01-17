//
//  FloatingLabelTextField.swift
//  CustomTextfield
//
//

import UIKit

public final class FloatingLabelTextField: UITextField {

  // MARK: - File Constants

  fileprivate struct Defaults {
    static let defaultTextFieldHeight: CGFloat = 44.0
    static let placeholderPadding: CGFloat = 2.0
    static let borderHeight: CGFloat = 1.0
    static let defaultPlaceholderFontHeightPercent: CGFloat = 0.7 // with respect to text height
    static let animationDuration = 0.3
    static let animationDelay = 0.1
    static let emptyString = ""
  }

  // MARK: - Private Variables

  fileprivate let placeholderLabel = UILabel()

  fileprivate let errorLabel = UILabel()

  fileprivate let borderView = UIView()

  fileprivate var placeholderString: String? {
    didSet {
      placeholderLabel.text = placeholderString
    }
  }

  fileprivate var errorString: String? {
    didSet {
      errorLabel.alpha = (errorString != nil) ? 1 : 0
      errorLabel.isHidden = (errorString != nil) ? false : true
      errorLabel.text = errorString
      refreshColorScheme()
      refreshLayout()
    }
  }

  fileprivate var placeholderText: String?

  // MARK: - IBInspectable's

  @IBInspectable
  var textInset: CGFloat = 0.0

  @IBInspectable
  var errorLabelColor: UIColor? {
    didSet {
      errorLabel.textColor = errorLabelColor
    }
  }

  @IBInspectable
  var placeholderLabelColor: UIColor? {
    didSet {
      placeholderLabel.textColor = placeholderLabelColor
    }
  }

  @IBInspectable
  var borderColor: UIColor? {
    didSet {
      borderView.backgroundColor = borderColor
    }
  }

  // MARK: - Public Properties

  public var placeholderLabelFont: UIFont? {
    didSet {
      placeholderLabel.font = placeholderLabelFont
    }
  }

  public var errorLabelFont: UIFont? {
    didSet {
      errorLabel.font = errorLabelFont
    }
  }

  // MARK: - Private Methods

  fileprivate func prepare() {
    setupTextChangeNotification()
    setupDefaultStyle()
    prepareBorderView()
    preparePlaceholderLabel()
    prepareErrorLabel()
  }

  fileprivate func setupDefaultStyle() {
    clipsToBounds = true
    borderStyle = .none
    contentScaleFactor = UIScreen.main.scale
    font = UIFont(name: "SFProDisplay-Regular", size: 16)
    textColor = .black
    placeholderLabelColor = UIColor(red: 57/255, green: 56/255, blue: 64/255, alpha: 1.0)
    borderColor = UIColor(red: 57/255, green: 56/255, blue: 64/255, alpha: 1.0)
    errorLabelColor = UIColor(red: 213/255, green: 0/255, blue: 0/255, alpha: 1.0)
    errorLabelFont = UIFont(name: "SFProDisplay-Regular", size: 12)
    placeholderLabelFont = UIFont(name: "SFProDisplay-Regular", size: 10)
    self.tintColor = .black
  }

  fileprivate func preparePlaceholderLabel() {
    placeholderLabel.numberOfLines = 0
    placeholderLabel.font = placeholderLabelFont
    placeholderLabel.alpha = 0
    placeholderLabel.isHidden = true
    placeholderLabel.textColor = placeholderLabelColor
    addSubview(placeholderLabel)
    refreshLayout()
  }

  fileprivate func prepareErrorLabel() {
    errorLabel.numberOfLines = 0
    errorLabel.font = errorLabelFont
    errorLabel.alpha = 0
    errorLabel.isHidden = true
    errorLabel.lineBreakMode = .byWordWrapping
    errorLabel.textColor = errorLabelColor
    addSubview(errorLabel)
    refreshLayout()
  }

  fileprivate func prepareBorderView() {
    borderView.backgroundColor = borderColor
    addSubview(borderView)
  }

  fileprivate func refreshLayout() {
    invalidateIntrinsicContentSize()
    layoutIfNeeded()
  }

  fileprivate func refreshColorScheme() {
    if let length = errorString?.count, length > 0 {
      borderView.backgroundColor = errorLabelColor
      placeholderLabel.textColor = errorLabelColor
    }
    else {
      borderView.backgroundColor = borderColor
      placeholderLabel.textColor = placeholderLabelColor
    }
  }

  fileprivate func showPlaceholderLabel() {
    
    placeholder = Defaults.emptyString
    placeholderString = placeholderText
    refreshLayout()

    UIView.animate(withDuration: Defaults.animationDuration,
                   delay: Defaults.animationDelay,
                   options: .curveEaseOut,
                   animations: {
                    self.placeholderLabel.isHidden = false
                    self.placeholderLabel.alpha = 1
    }, completion: nil)
  }

  fileprivate func setupTextChangeNotification() {

    _ = NotificationCenter.default.addObserver(
      forName: UITextField.textDidBeginEditingNotification,
      object: self,
      queue: nil) { [weak self] (notification) in
        self?.showPlaceholderLabel()
    }

    _ = NotificationCenter.default.addObserver(
      forName: UITextField.textDidEndEditingNotification,
      object: self,
      queue: nil) {[weak self] (notification) in

        if self?.text == nil || self?.text == Defaults.emptyString {
          self?.placeholderString = nil
          self?.placeholderLabel.isHidden = true
          self?.placeholderLabel.alpha = 0
          self?.placeholder = self?.placeholderText
        }
        else {
          self?.placeholder = Defaults.emptyString
        }
        self?.refreshLayout()
    }

    _ = NotificationCenter.default.addObserver(
      forName: UITextField.textDidChangeNotification,
      object: self,
      queue: nil) {[weak self] (notification) in
        self?.errorString = nil
        self?.errorLabel.isHidden = true
        self?.errorLabel.alpha = 0
    }
  }

  fileprivate func typingRect(bounds: CGRect) -> CGRect {
    var frame = bounds

    let leftViewWidth = leftView?.frame.size.width ?? 0
    let rightViewWidth = rightView?.frame.size.width ?? 0

    frame.origin.x = leftViewWidth
    frame.size.width -= (leftViewWidth + rightViewWidth)

    if placeholderString != nil {
      let y_pos = placeholderLabel.frame.origin.y + placeholderLabel.intrinsicContentSize.height + Defaults.placeholderPadding
      frame.origin.y = y_pos
      frame.size.height = (bounds.height - y_pos)
    }
    if errorString != nil {
      let availableWidth = self.bounds.size.width - leftViewWidth - rightViewWidth - 2 * textInset
      let errorSize = errorLabel.sizeThatFits(CGSize(width: availableWidth,
                                                     height: CGFloat.greatestFiniteMagnitude))
      frame.size.height -= (errorSize.height + Defaults.placeholderPadding)
    }
    return frame
  }

  // MARK: - Overriden properties
  
  public override var accessibilityLabel: String? {
    didSet {
      if accessibilityLabel?.isEmpty == false {
        placeholderLabel.accessibilityLabel = accessibilityLabel
      }
    }
  }

  override public var placeholder: String? {
    didSet {
      if placeholder?.isEmpty == false {
        placeholderText = placeholder
      }
    }
  }

  override public var text: String? {
    didSet {
      if text?.isEmpty == false {
        showPlaceholderLabel()
      }
    }
  }
  
  override public var rightView: UIView? {
    didSet {
      layoutIfNeeded()
    }
  }
  
  override public var leftView: UIView? {
    didSet {
      refreshLayout()
    }
  }

  override public var intrinsicContentSize: CGSize {
    let leftViewWidth = leftView?.frame.size.width ?? 0.0
    let rightViewWidth = rightView?.frame.size.width ?? 0.0
    let availableWidth = bounds.size.width - leftViewWidth - rightViewWidth - 2 * textInset

    var height = Defaults.defaultTextFieldHeight

    if placeholderString != nil {
      let placeholderSize = placeholderLabel.sizeThatFits(CGSize(width: availableWidth,
                                                                 height: CGFloat.greatestFiniteMagnitude))
      height += Defaults.placeholderPadding
      height += placeholderSize.height
    }

    height += Defaults.borderHeight

    if errorString != nil {
      let errorSize = errorLabel.sizeThatFits(CGSize(width: availableWidth,
                                                     height: CGFloat.greatestFiniteMagnitude))
      height += Defaults.placeholderPadding
      height += errorSize.height
    }
    return CGSize(width: bounds.width, height: ceil(height))
  }

  // MARK: - Lifecylce Methods

  public override init(frame: CGRect) {
    super.init(frame: frame)

    prepare()
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    prepare()
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  override public func textRect(forBounds bounds: CGRect) -> CGRect {
    var textBounds = bounds
    textBounds.origin.x += textInset
    textBounds.size.width -= (2 * textInset)
    return typingRect(bounds: textBounds)
  }
  
  override public func rightViewRect(forBounds bounds: CGRect) -> CGRect {
    var rightViewBounds = super.rightViewRect(forBounds: bounds)
    let textBounds = textRect(forBounds: bounds)
    rightViewBounds.origin.y = textBounds.origin.y
    rightViewBounds.size.height = textBounds.size.height
    return rightViewBounds
  }

  override public func placeholderRect(forBounds bounds: CGRect) -> CGRect {
    return textRect(forBounds: bounds)
  }

  override public func editingRect(forBounds bounds: CGRect) -> CGRect {
    return textRect(forBounds: bounds)
  }

  override public func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
    let originalBounds = super.clearButtonRect(forBounds: bounds)
    let typingRect = self.typingRect(bounds: bounds)
    let y_pos = typingRect.origin.y + floor((typingRect.size.height - originalBounds.size.height)/2)
    return CGRect(origin: CGPoint(x: originalBounds.origin.x, y: y_pos), size: originalBounds.size)
  }

  override public func layoutSubviews() {
    super.layoutSubviews()

    let leftViewWidth = leftView?.frame.size.width ?? 0
    let rightViewWidth = rightView?.frame.size.width ?? 0

    let leftInset = leftViewWidth + textInset
    let availableWidth = bounds.size.width - leftViewWidth - rightViewWidth - 2 * textInset

    let placeholderSize = placeholderLabel.sizeThatFits(CGSize(width: availableWidth,
                                                               height: CGFloat.greatestFiniteMagnitude))

    if isEditing || ( text?.isEmpty == false && placeholderString?.isEmpty == false) {
      let placeholderWidth = availableWidth > placeholderSize.width ? placeholderSize.width : availableWidth
      placeholderLabel.frame = CGRect(x: leftInset,
                                      y: 0,
                                      width: placeholderWidth,
                                      height: placeholderSize.height)
    }

    var y_pos = Defaults.defaultTextFieldHeight

    if placeholderString != nil {
      y_pos += (placeholderSize.height + Defaults.placeholderPadding)
    }

    borderView.frame = CGRect(x: leftInset, y: y_pos, width: bounds.size.width, height: Defaults.borderHeight)

    y_pos += Defaults.borderHeight

    if errorString != nil {
      let errorSize = errorLabel.sizeThatFits(CGSize(width: availableWidth,
                                                     height: CGFloat.greatestFiniteMagnitude))
      let errorWidth = availableWidth > errorSize.width ? errorSize.width : availableWidth
      y_pos += Defaults.placeholderPadding
      errorLabel.frame = CGRect(x: leftInset, y: y_pos, width: errorWidth, height: errorSize.height)
    }
  }

  // MARK: - Public Methods

  public func setError(_ errorDescription: String?) {
    DispatchQueue.main.async {
      self.errorString = errorDescription
    }
  }

}
