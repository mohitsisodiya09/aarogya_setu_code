//
//  ToastView.swift
//

// 
//

import UIKit
import ObjectiveC

typealias ButtonActionBlock = () -> Void

@objc final class ToastView: NSObject {
  
  // MARK: - Private Static variables
  
  fileprivate static let sharedView = UIView()
  
  // MARK: - Public Static Methods
  
  @objc static func hideToastMessage() {
    sharedView.hideToast()
  }
  
  @objc static func showToastMessage(_ message: String, buttonTitle: String, buttonAction: @escaping ButtonActionBlock) {
    sharedView.makeToast(message, buttonTitle: buttonTitle, buttonAction: buttonAction)
  }
  
  @objc static func showToastMessage(_ message: String) {
    sharedView.makeToast(message)
  }
}

/**
 Toast is a Swift extension that adds toast notifications to the `UIView` object class.
 It is intended to be simple, lightweight, and easy to use. Most toast notifications
 can be triggered with a single line of code.
 
 The `makeToast` methods create a new view and then display it as toast.
 
 The `showToast` methods display any view as toast.
 
 */
extension UIView {
  
  /**
   Keys used for associated objects.
   */
  private class ToastKeys {
    static var timer        = "com.toast-swift.timer"
    static var duration     = "com.toast-swift.duration"
    static var point        = "com.toast-swift.point"
    static var completion   = "com.toast-swift.completion"
    static var buttonAction   = "com.toast-swift.buttonAction"
    static var activeToast = "com.toast-swift.activeToasts"
    static var activityView = "com.toast-swift.activityView"
    static var queue        = "com.toast-swift.queue"
  }
  
  /**
   Swift closures can't be directly associated with objects via the
   Objective-C runtime, so the (ugly) solution is to wrap them in a
   class that can be used with associated objects.
   */
  private class ToastCompletionWrapper {
    let completion: ((Bool) -> Void)?
    
    init(_ completion: ((Bool) -> Void)?) {
      self.completion = completion
    }
  }
  
  private class ToastButtonActionWrapper {
    let actionBlock: (() -> Void)?
    
    init(_ actionBlock: (() -> Void)?) {
      self.actionBlock = actionBlock
    }
  }
  
  private enum ToastError: Error {
    case missingParameters
  }
  
  private var activeToasts: NSMutableArray {
      if let activeToasts = objc_getAssociatedObject(self, &ToastKeys.activeToast) as? NSMutableArray {
        return activeToasts
      }
      else {
        let activeToasts = NSMutableArray()
        objc_setAssociatedObject(self, &ToastKeys.activeToast, activeToasts, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return activeToasts
      }
  }
  
  private var queue: NSMutableArray {
    
      if let queue = objc_getAssociatedObject(self, &ToastKeys.queue) as? NSMutableArray {
        return queue
      }
      else {
        let queue = NSMutableArray()
        objc_setAssociatedObject(self, &ToastKeys.queue, queue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return queue
      }
    
  }
  
  // MARK: - Make Toast Methods
  
  /**
   Creates and presents a new toast view.
   
   @param message The message to be displayed
   @param duration The toast duration
   @param position The toast's position
   @param title The title
   @param image The image
   @param style The style. The shared style will be used when nil
   @param completion The completion closure, executed after the toast view disappears.
   didTap will be `true` if the toast view was dismissed from a tap.
   */
  fileprivate func makeToast(_ message: String?,
                             duration: TimeInterval = ToastManager.duration,
                             position: ToastPosition = ToastManager.position,
                             title: String? = nil,
                             image: UIImage? = nil,
                             style: ToastStyle = ToastManager.style,
                             completion: ((_ didTap: Bool) -> Void)? = nil) {
    do {
      let toast = try toastViewForMessage(message, title: title, image: image, style: style)
      showToast(toast, duration: duration, position: position, completion: completion)
    }
    catch {}
  }
  
  /**
   Creates a new toast view and presents it at a given center point.
   
   @param message The message to be displayed
   @param duration The toast duration
   @param point The toast's center point
   @param title The title
   @param image The image
   @param style The style. The shared style will be used when nil
   @param completion The completion closure, executed after the toast view disappears.
   didTap will be `true` if the toast view was dismissed from a tap.
   */
  fileprivate func makeToast(_ message: String?,
                             duration: TimeInterval = ToastManager.duration,
                             point: CGPoint,
                             title: String?,
                             image: UIImage?,
                             style: ToastStyle = ToastManager.style,
                             completion: ((_ didTap: Bool) -> Void)?) {
    do {
      let toast = try toastViewForMessage(message, title: title, image: image, style: style)
      showToast(toast, duration: duration, point: point, completion: completion)
    }
    catch {}
  }
  
  /**
   Creates and presents a new toast view.
   
   @param message The message to be displayed
   @param duration The toast duration
   @param position The toast's position
   @param title The title
   @param image The image
   @param style The style. The shared style will be used when nil
   @param completion The completion closure, executed after the toast view disappears.
   didTap will be `true` if the toast view was dismissed from a tap.
   */
  fileprivate func makeToast(_ message: String?,
                             duration: TimeInterval = ToastManager.duration,
                             position: ToastPosition = ToastManager.position,
                             title: String? = nil,
                             buttonTitle: String? = nil,
                             buttonAction: @escaping ButtonActionBlock,
                             image: UIImage? = nil,
                             style: ToastStyle = ToastManager.style,
                             completion: ((_ didTap: Bool) -> Void)? = nil) {
    do {
      let toast = try toastViewForMessage(message, title: title, buttonTitle: buttonTitle, image: image, style: style)
      showToast(toast, duration: duration, position: position, completion: completion, buttonAction: buttonAction)
    }
    catch {}
  }
  
  // MARK: - Show Toast Methods
  
  /**
   Displays any view as toast at a provided position and duration. The completion closure
   executes when the toast view completes. `didTap` will be `true` if the toast view was
   dismissed from a tap.
   
   @param toast The view to be displayed as toast
   @param duration The notification duration
   @param position The toast's position
   @param completion The completion block, executed after the toast view disappears.
   didTap will be `true` if the toast view was dismissed from a tap.
   */
  fileprivate func showToast(_ toast: UIView,
                             duration: TimeInterval = ToastManager.duration,
                             position: ToastPosition = ToastManager.position,
                             completion: ((_ didTap: Bool) -> Void)? = nil,
                             buttonAction: @escaping ButtonActionBlock) {
    
    if let window = activeWindow() {
      let point = position.centerPoint(forToast: toast, inSuperview: window)
      showToast(toast, duration: duration, point: point, completion: completion, buttonAction: buttonAction)
    }
  }
  
  /**
   Displays any view as toast at a provided position and duration. The completion closure
   executes when the toast view completes. `didTap` will be `true` if the toast view was
   dismissed from a tap.
   
   @param toast The view to be displayed as toast
   @param duration The notification duration
   @param position The toast's position
   @param completion The completion block, executed after the toast view disappears.
   didTap will be `true` if the toast view was dismissed from a tap.
   */
  fileprivate func showToast(_ toast: UIView,
                             duration: TimeInterval = ToastManager.duration,
                             position: ToastPosition = ToastManager.position,
                             completion: ((_ didTap: Bool) -> Void)? = nil) {
    
    if let window = activeWindow() {
      let point = position.centerPoint(forToast: toast, inSuperview: window)
      showToast(toast, duration: duration, point: point, completion: completion)
    }
  }
  
  /**
   Displays any view as toast at a provided center point and duration. The completion closure
   executes when the toast view completes. `didTap` will be `true` if the toast view was
   dismissed from a tap.
   
   @param toast The view to be displayed as toast
   @param duration The notification duration
   @param point The toast's center point
   @param completion The completion block, executed after the toast view disappears.
   didTap will be `true` if the toast view was dismissed from a tap.
   */
  fileprivate func showToast(_ toast: UIView, duration: TimeInterval = ToastManager.duration, point: CGPoint, completion: ((_ didTap: Bool) -> Void)? = nil) {
    objc_setAssociatedObject(toast, &ToastKeys.completion, ToastCompletionWrapper(completion), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    
    if ToastManager.isQueueEnabled && ((self.activeToasts as? [UIView])?.isEmpty == false) {
      objc_setAssociatedObject(toast, &ToastKeys.duration, NSNumber(value: duration), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      objc_setAssociatedObject(toast, &ToastKeys.point, NSValue(cgPoint: point), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      
      queue.add(toast)
    }
    else {
      removeActiveToast()
      showToast(toast, duration: duration, point: point)
    }
  }
  
  /**
   Displays any view as toast at a provided center point and duration. The completion closure
   executes when the toast view completes. `didTap` will be `true` if the toast view was
   dismissed from a tap.
   
   @param toast The view to be displayed as toast
   @param duration The notification duration
   @param point The toast's center point
   @param completion The completion block, executed after the toast view disappears.
   didTap will be `true` if the toast view was dismissed from a tap.
   */
  fileprivate func showToast(_ toast: UIView, duration: TimeInterval = ToastManager.duration, point: CGPoint, completion: ((_ didTap: Bool) -> Void)? = nil, buttonAction: ButtonActionBlock? = nil) {
    objc_setAssociatedObject(toast, &ToastKeys.completion, ToastCompletionWrapper(completion), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    objc_setAssociatedObject(toast, &ToastKeys.buttonAction, ToastButtonActionWrapper(buttonAction), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    
    if ToastManager.isQueueEnabled && ((self.activeToasts as? [UIView])?.isEmpty == false) {
      objc_setAssociatedObject(toast, &ToastKeys.duration, NSNumber(value: duration), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      objc_setAssociatedObject(toast, &ToastKeys.point, NSValue(cgPoint: point), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      
      queue.add(toast)
    }
    else {
      removeActiveToast()
      showToast(toast, duration: duration, point: point)
    }
  }
  
  // MARK: - Hide Toast Methods
  
  /**
   Hides the active toast. If there are multiple toasts active in a view, this method
   hides the oldest toast (the first of the toasts to have been presented).
   
   @see `hideAllToasts()` to remove all active toasts from a view.
   
   @warning This method has no effect on activity toasts. Use `hideToastActivity` to
   hide activity toasts.
   
   */
  fileprivate func hideToast() {
    guard let activeToast = activeToasts.firstObject as? UIView else {
      return
    }
    hideToast(activeToast)
  }
  
  /**
   Hides an active toast.
   
   @param toast The active toast view to dismiss. Any toast that is currently being displayed
   on the screen is considered active.
   
   @warning this does not clear a toast view that is currently waiting in the queue.
   */
  fileprivate func hideToast(_ toast: UIView) {
    guard activeToasts.contains(toast) else {
      return
    }
    hideToast(toast, fromTap: false)
  }
  
  /**
   Hides all toast views.
   
   @param clearQueue If `true`, removes all toast views from the queue. Default is `true`.
   */
  fileprivate func hideAllToasts(clearQueue: Bool = true) {
    if clearQueue {
      clearToastQueue()
    }
    
    activeToasts.compactMap { $0 as? UIView }
      .forEach { hideToast($0) }
  }
  
  /**
   Removes all toast views from the queue. This has no effect on toast views that are
   active. Use `hideAllToasts(clearQueue:)` to hide the active toasts views and clear
   the queue.
   */
  fileprivate func clearToastQueue() {
    queue.removeAllObjects()
  }
  
  // MARK: - Private Show/Hide Methods
  
  private func showToast(_ toast: UIView, duration: TimeInterval, point: CGPoint) {
    toast.center = point
    toast.alpha = 0.0
    
    if ToastManager.isTapToDismissEnabled {
      let recognizer = UITapGestureRecognizer(target: self, action: #selector(UIView.handleToastTapped(_:)))
      toast.addGestureRecognizer(recognizer)
      toast.isUserInteractionEnabled = true
      toast.isExclusiveTouch = true
    }
    
    activeToasts.add(toast)
    
    if let window = activeWindow() {
      window.addSubview(toast)
      self.addKeyboardObserver()
    }
    
    UIView.animate(withDuration: ToastManager.style.fadeDuration,
                   delay: 0.0,
                   options: [.curveEaseOut, .allowUserInteraction],
                   animations: {
                    toast.alpha = 1.0
    },
                   completion: { _ in
                    let timer = Timer(timeInterval: duration, target: self, selector: #selector(UIView.toastTimerDidFinish(_:)), userInfo: toast, repeats: false)
                    RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
                    objc_setAssociatedObject(toast, &ToastKeys.timer, timer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    })
  }
  
  private func activeWindow() -> UIWindow? {
    
    let windows = UIApplication.shared.windows
    
    let visibleWindows = windows.filter { (window) -> Bool in
      return window.isHidden == false
    }
    
    if visibleWindows.isEmpty {
      return UIView.applicationWindow()
      
    }
    else {
      return visibleWindows.last
    }
  }
  
  private func removeActiveToast() {
    
    if let toast = activeToasts.firstObject as? UIView {
      
      if let timer = objc_getAssociatedObject(toast, &ToastKeys.timer) as? Timer {
        timer.invalidate()
      }
      
      toast.removeFromSuperview()
      self.activeToasts.remove(toast)
      self.removeKeyboardObserver()
      if let wrapper = objc_getAssociatedObject(toast, &ToastKeys.completion) as? ToastCompletionWrapper, let completion = wrapper.completion {
        completion(false)
      }
    }
  }
  
  private func hideToast(_ toast: UIView, fromTap: Bool) {
    if let timer = objc_getAssociatedObject(toast, &ToastKeys.timer) as? Timer {
      timer.invalidate()
    }
    
    UIView.animate(withDuration: ToastManager.style.fadeDuration,
                   delay: 0.0,
                   options: [.curveEaseIn, .beginFromCurrentState],
                   animations: {
                    toast.alpha = 0.0
    },
                   completion: { _ in
                    toast.removeFromSuperview()
                    self.activeToasts.remove(toast)
                    self.removeKeyboardObserver()
                    if let wrapper = objc_getAssociatedObject(toast, &ToastKeys.completion) as? ToastCompletionWrapper, let completion = wrapper.completion {
                      completion(fromTap)
                    }
                    
                    if let nextToast = self.queue.firstObject as? UIView, let duration = objc_getAssociatedObject(nextToast, &ToastKeys.duration) as? NSNumber, let point = objc_getAssociatedObject(nextToast, &ToastKeys.point) as? NSValue {
                      self.queue.removeObject(at: 0)
                      self.showToast(nextToast, duration: duration.doubleValue, point: point.cgPointValue)
                    }
    })
  }
  
  // MARK: - Events
  
  @objc
  private func handleToastTapped(_ recognizer: UITapGestureRecognizer) {
    guard let toast = recognizer.view else {
      return
    }
    hideToast(toast, fromTap: true)
  }
  
  @objc
  private func toastTimerDidFinish(_ timer: Timer) {
    guard let toast = timer.userInfo as? UIView else {
      return
    }
    hideToast(toast)
  }
  
  @objc
  private func toastActionButtonTapped(_ sender: UIButton) {
    
    if let toast = sender.superview,
      let wrapper = objc_getAssociatedObject(toast, &ToastKeys.buttonAction) as? ToastButtonActionWrapper,
      let actionBlock = wrapper.actionBlock {
      
      actionBlock()
    }
  }
  
  // MARK: - Toast Construction
  
  /**
   Creates a new toast view with any combination of message, title, and image.
   The look and feel is configured via the style. Unlike the `makeToast` methods,
   this method does not present the toast view automatically. One of the `showToast`
   methods must be used to present the resulting view.
   
   @warning if message, title, and image are all nil, this method will throw
   `ToastError.missingParameters`
   
   @param message The message to be displayed
   @param title The title
   @param image The image
   @param style The style. The shared style will be used when nil
   @throws `ToastError.missingParameters` when message, title, and image are all nil
   @return The newly created toast view
   */
  fileprivate func toastViewForMessage(_ message: String?, title: String?, image: UIImage?, style: ToastStyle) throws -> UIView {
    // sanity
    guard message != nil || title != nil || image != nil else {
      throw ToastError.missingParameters
    }
    
    var messageLabel: UILabel?
    var titleLabel: UILabel?
    var imageView: UIImageView?
    
    let wrapperView = UIView()
    wrapperView.backgroundColor = style.backgroundColor
    wrapperView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
    wrapperView.layer.cornerRadius = style.cornerRadius
    
    if style.displayShadow {
      wrapperView.layer.shadowColor = UIColor.black.cgColor
      wrapperView.layer.shadowOpacity = style.shadowOpacity
      wrapperView.layer.shadowRadius = style.shadowRadius
      wrapperView.layer.shadowOffset = style.shadowOffset
    }
    
    if let image = image {
      imageView = UIImageView(image: image)
      imageView?.contentMode = .scaleAspectFit
      imageView?.frame = CGRect(x: style.horizontalPadding, y: style.verticalPadding, width: style.imageSize.width, height: style.imageSize.height)
    }
    
    var imageRect = CGRect.zero
    
    if let imageView = imageView {
      imageRect.origin.x = style.horizontalPadding
      imageRect.origin.y = style.verticalPadding
      imageRect.size.width = imageView.bounds.size.width
      imageRect.size.height = imageView.bounds.size.height
    }
    
    if let title = title {
      titleLabel = UILabel()
      titleLabel?.numberOfLines = style.titleNumberOfLines
      titleLabel?.font = style.titleFont
      titleLabel?.textAlignment = style.titleAlignment
      titleLabel?.lineBreakMode = .byTruncatingTail
      titleLabel?.textColor = style.titleColor
      titleLabel?.backgroundColor = UIColor.clear
      titleLabel?.text = title
      
      let maxTitleSize = CGSize(width: (UIView.getWindowSize().width * style.maxWidthPercentage) - imageRect.size.width, height: UIView.getWindowSize().height * style.maxHeightPercentage)
      let titleSize = titleLabel?.sizeThatFits(maxTitleSize)
      if let titleSize = titleSize {
        titleLabel?.frame = CGRect(x: 0.0, y: 0.0, width: titleSize.width, height: titleSize.height)
      }
    }
    
    if let message = message {
      messageLabel = UILabel()
      messageLabel?.text = message
      messageLabel?.numberOfLines = style.messageNumberOfLines
      messageLabel?.font = style.messageFont
      messageLabel?.textAlignment = style.messageAlignment
      messageLabel?.lineBreakMode = .byTruncatingTail
      messageLabel?.textColor = style.messageColor
      messageLabel?.backgroundColor = UIColor.clear
      
      let maxMessageSize = CGSize(width: (UIView.getWindowSize().width * style.maxWidthPercentage) - imageRect.size.width, height: UIView.getWindowSize().height * style.maxHeightPercentage)
      let messageSize = messageLabel?.sizeThatFits(maxMessageSize)
      if let messageSize = messageSize {
        let actualWidth = min(messageSize.width, maxMessageSize.width)
        let actualHeight = min(messageSize.height, maxMessageSize.height)
        messageLabel?.frame = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight)
      }
    }
    
    var titleRect = CGRect.zero
    
    if let titleLabel = titleLabel {
      titleRect.origin.x = imageRect.origin.x + imageRect.size.width + style.horizontalPadding
      titleRect.origin.y = style.verticalPadding
      titleRect.size.width = titleLabel.bounds.size.width
      titleRect.size.height = titleLabel.bounds.size.height
    }
    
    var messageRect = CGRect.zero
    
    if let messageLabel = messageLabel {
      messageRect.origin.x = imageRect.origin.x + imageRect.size.width + style.horizontalPadding
      messageRect.origin.y = titleRect.origin.y + titleRect.size.height + style.verticalPadding
      messageRect.size.width = messageLabel.bounds.size.width
      messageRect.size.height = messageLabel.bounds.size.height
    }
    
    let longerWidth = max(titleRect.size.width, messageRect.size.width)
    let longerX = max(titleRect.origin.x, messageRect.origin.x)
    let wrapperWidth = max((imageRect.size.width + (style.horizontalPadding * 2.0)), (longerX + longerWidth + style.horizontalPadding))
    let wrapperHeight = max((messageRect.origin.y + messageRect.size.height + style.verticalPadding), (imageRect.size.height + (style.verticalPadding * 2.0)))
    
    wrapperView.frame = CGRect(x: 0.0, y: 0.0, width: wrapperWidth, height: wrapperHeight)
    
    if let titleLabel = titleLabel {
      titleRect.size.width = longerWidth
      titleLabel.frame = titleRect
      wrapperView.addSubview(titleLabel)
    }
    
    if let messageLabel = messageLabel {
      messageRect.size.width = longerWidth
      messageLabel.frame = messageRect
      wrapperView.addSubview(messageLabel)
    }
    
    if let imageView = imageView {
      wrapperView.addSubview(imageView)
    }
    
    return wrapperView
  }
  
  /**
   Creates a new toast view with any combination of message, title, and image.
   The look and feel is configured via the style. Unlike the `makeToast` methods,
   this method does not present the toast view automatically. One of the `showToast`
   methods must be used to present the resulting view.
   
   @warning if message, title, and image are all nil, this method will throw
   `ToastError.missingParameters`
   
   @param message The message to be displayed
   @param title The title
   @param image The image
   @param style The style. The shared style will be used when nil
   @throws `ToastError.missingParameters` when message, title, and image are all nil
   @return The newly created toast view
   */
  fileprivate func toastViewForMessage(_ message: String?, title: String?, buttonTitle: String?, image: UIImage?, style: ToastStyle) throws -> UIView {
    // sanity
    guard message != nil || title != nil || image != nil || buttonTitle != nil else {
      throw ToastError.missingParameters
    }
    
    var messageLabel: UILabel?
    var titleLabel: UILabel?
    var imageView: UIImageView?
    var actionButton: UIButton?
    
    let wrapperView = UIView()
    wrapperView.backgroundColor = style.backgroundColor
    wrapperView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
    wrapperView.layer.cornerRadius = style.cornerRadius
    
    if style.displayShadow {
      wrapperView.layer.shadowColor = UIColor.black.cgColor
      wrapperView.layer.shadowOpacity = style.shadowOpacity
      wrapperView.layer.shadowRadius = style.shadowRadius
      wrapperView.layer.shadowOffset = style.shadowOffset
    }
    
    if let image = image {
      imageView = UIImageView(image: image)
      imageView?.contentMode = .scaleAspectFit
      imageView?.frame = CGRect(x: style.horizontalPadding, y: style.verticalPadding, width: style.imageSize.width, height: style.imageSize.height)
    }
    
    var imageRect = CGRect.zero
    
    if let imageView = imageView {
      imageRect.origin.x = style.horizontalPadding
      imageRect.origin.y = style.verticalPadding
      imageRect.size.width = imageView.bounds.size.width
      imageRect.size.height = imageView.bounds.size.height
    }
    
    if let buttonTitle = buttonTitle {
      actionButton = UIButton(type: .system)
      actionButton?.setTitle(buttonTitle, for: .normal)
      actionButton?.titleLabel?.font = style.actionButtonTextFont
      actionButton?.setTitleColor(style.actionButtonTextColor, for: .normal)
      actionButton?.addTarget(self, action: #selector(toastActionButtonTapped(_:)), for: .touchUpInside)
      if let buttonSize = actionButton?.sizeThatFits(CGSize(width: (UIView.getWindowSize().width * style.maxWidthPercentage) - imageRect.size.width, height: UIView.getWindowSize().height * style.maxHeightPercentage)) {
        actionButton?.frame = CGRect(x: 0, y: style.verticalPadding, width: buttonSize.width, height: buttonSize.height)
      }
    }
    
    if let title = title {
      titleLabel = UILabel()
      titleLabel?.numberOfLines = style.titleNumberOfLines
      titleLabel?.font = style.titleFont
      titleLabel?.textAlignment = style.titleAlignment
      titleLabel?.lineBreakMode = .byTruncatingTail
      titleLabel?.textColor = style.titleColor
      titleLabel?.backgroundColor = UIColor.clear
      titleLabel?.text = title
      
      var maxTitleSize = CGSize(width: (UIView.getWindowSize().width * style.maxWidthPercentage) - imageRect.size.width, height: UIView.getWindowSize().height * style.maxHeightPercentage)
      
      if let actionButton = actionButton {
        maxTitleSize = CGSize(width: maxTitleSize.width - actionButton.bounds.size.width, height: maxTitleSize.height)
      }
      let titleSize = titleLabel?.sizeThatFits(maxTitleSize)
      if let titleSize = titleSize {
        titleLabel?.frame = CGRect(x: 0.0, y: 0.0, width: titleSize.width, height: titleSize.height)
      }
    }
    
    if let message = message {
      messageLabel = UILabel()
      messageLabel?.text = message
      messageLabel?.numberOfLines = style.messageNumberOfLines
      messageLabel?.font = style.messageFont
      messageLabel?.textAlignment = style.messageAlignment
      messageLabel?.lineBreakMode = .byTruncatingTail
      messageLabel?.textColor = style.messageColor
      messageLabel?.backgroundColor = UIColor.clear
      
      var maxMessageSize = CGSize(width: (UIView.getWindowSize().width * style.maxWidthPercentage) - imageRect.size.width, height: UIView.getWindowSize().height * style.maxHeightPercentage)
      
      if let actionButton = actionButton {
        maxMessageSize = CGSize(width: maxMessageSize.width - actionButton.bounds.size.width, height: maxMessageSize.height)
      }
      let messageSize = messageLabel?.sizeThatFits(maxMessageSize)
      if let messageSize = messageSize {
        let actualWidth = min(messageSize.width, maxMessageSize.width)
        let actualHeight = min(messageSize.height, maxMessageSize.height)
        messageLabel?.frame = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight)
      }
    }
    
    var titleRect = CGRect.zero
    
    if let titleLabel = titleLabel {
      titleRect.origin.x = imageRect.origin.x + imageRect.size.width + style.horizontalPadding
      titleRect.origin.y = style.verticalPadding
      titleRect.size.width = titleLabel.bounds.size.width
      titleRect.size.height = titleLabel.bounds.size.height
    }
    
    var messageRect = CGRect.zero
    
    if let messageLabel = messageLabel {
      messageRect.origin.x = imageRect.origin.x + imageRect.size.width + style.horizontalPadding
      messageRect.origin.y = titleRect.origin.y + titleRect.size.height + style.verticalPadding
      messageRect.size.width = messageLabel.bounds.size.width
      messageRect.size.height = messageLabel.bounds.size.height
    }
    
    var actionButtonRect = CGRect.zero
    
    if let actionButton = actionButton {
      let x_pos = messageRect.maxX + style.horizontalPadding
      actionButtonRect.origin.x = x_pos
      actionButtonRect.origin.y = style.verticalPadding
      actionButtonRect.size.width = actionButton.bounds.size.width
      actionButtonRect.size.height = actionButton.bounds.size.height
    }
    
    let longerWidth = max(titleRect.size.width, messageRect.size.width)
    let longerX = max(titleRect.origin.x, messageRect.origin.x)
    var wrapperWidth = max((imageRect.size.width + (style.horizontalPadding * 2.0)), (longerX + longerWidth + style.horizontalPadding))
    if actionButton != nil {
      wrapperWidth += actionButtonRect.size.width + style.horizontalPadding
    }
    var wrapperHeight = max((messageRect.origin.y + messageRect.size.height + style.verticalPadding), (imageRect.size.height + (style.verticalPadding * 2.0)))
    wrapperHeight = max(wrapperHeight, actionButtonRect.size.height + (style.verticalPadding * 2.0))
    wrapperView.frame = CGRect(x: 0.0, y: 0.0, width: wrapperWidth, height: wrapperHeight)
    
    if let titleLabel = titleLabel {
      titleRect.size.width = longerWidth
      titleLabel.frame = titleRect
      wrapperView.addSubview(titleLabel)
    }
    
    if let messageLabel = messageLabel {
      messageRect.origin.y = (wrapperHeight - messageRect.size.height) / 2
      messageRect.size.width = longerWidth
      messageLabel.frame = messageRect
      wrapperView.addSubview(messageLabel)
    }
    
    if let actionButton = actionButton {
      actionButtonRect.origin.y = (wrapperHeight - actionButtonRect.size.height) / 2
      actionButton.frame = actionButtonRect
      wrapperView.addSubview(actionButton)
    }
    
    if let imageView = imageView {
      wrapperView.addSubview(imageView)
    }
    
    return wrapperView
  }
  
  private func addKeyboardObserver() {
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
    
  }
  
  private func removeKeyboardObserver() {
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
  }
  
  @objc private func keyboardWillShow(_ sender: NSNotification) {
    
    guard let activeToast = activeToasts.firstObject as? UIView else {
      return
    }
    
    bringToastAboveKeyboard(activeToast)
  }
  
  @objc private func keyboardDidHide(_ sender: NSNotification) {
    
    guard let activeToast = activeToasts.firstObject as? UIView else {
      return
    }
    
    moveToastOverApplicationWindow(activeToast)
  }
  
  fileprivate func bringToastAboveKeyboard(_ toast: UIView) {
    
    if let activeWindow = activeWindow() {
      toast.removeFromSuperview()
      let point = ToastManager.position.centerPoint(forToast: toast, inSuperview: activeWindow)
      toast.center = point
      activeWindow.addSubview(toast)
    }
  }
  
  fileprivate func moveToastOverApplicationWindow(_ toast: UIView) {
    
    if let activeWindow = UIView.applicationWindow() {
      toast.removeFromSuperview()
      let point = ToastManager.position.centerPoint(forToast: toast, inSuperview: activeWindow)
      toast.center = point
      activeWindow.addSubview(toast)
    }
  }
}

// MARK: - Toast Style

/**
 `ToastStyle` instances define the look and feel for toast views created via the
 `makeToast` methods as well for toast views created directly with
 `toastViewForMessage(message:title:image:style:)`.
 
 @warning `ToastStyle` offers relatively simple styling options for the default
 toast view. If you require a toast view with more complex UI, it probably makes more
 sense to create your own custom UIView subclass and present it with the `showToast`
 methods.
 */
public struct ToastStyle {
  
  public init() {}
  
  /**
   The background color. Default is `.black` at 80% opacity.
   */
  public var backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.8)
  
  /**
   The title color. Default is `UIColor.whiteColor()`.
   */
  public var titleColor: UIColor = .white
  
  /**
   The message color. Default is `.white`.
   */
  public var messageColor: UIColor = .white
  
  /**
   The ActionButton Text color. Default is `UIColor.omg_ratingDiscounts`.
   */
  public var actionButtonTextColor: UIColor = UIColor.green
  
  /**
   The ActionButton Text Font. Default is `UIFont.omg_p2Medium`.
   */
  public var actionButtonTextFont: UIFont? =  UIFont(name: "AvenirNext-Regular", size: 12.0)
  
  /**
   A percentage value from 0.0 to 1.0, representing the maximum width of the toast
   view relative to it's superview. Default is 0.8 (80% of the superview's width).
   */
  public var maxWidthPercentage: CGFloat = 0.8 {
    didSet {
      maxWidthPercentage = max(min(maxWidthPercentage, 1.0), 0.0)
    }
  }
  
  /**
   A percentage value from 0.0 to 1.0, representing the maximum height of the toast
   view relative to it's superview. Default is 0.8 (80% of the superview's height).
   */
  public var maxHeightPercentage: CGFloat = 0.8 {
    didSet {
      maxHeightPercentage = max(min(maxHeightPercentage, 1.0), 0.0)
    }
  }
  
  /**
   The spacing from the horizontal edge of the toast view to the content. When an image
   is present, this is also used as the padding between the image and the text.
   Default is 10.0.
   
   */
  public var horizontalPadding: CGFloat = 10.0
  
  /**
   The spacing from the vertical edge of the toast view to the content. When a title
   is present, this is also used as the padding between the title and the message.
   Default is 10.0. On iOS11+, this value is added added to the `safeAreaInset.top`
   and `safeAreaInsets.bottom`.
   */
  public var verticalPadding: CGFloat = 10.0
  
  /**
   The bottom spacing of toast view from safeAreInsets
   */
  public var toastViewBottomPadding: CGFloat = 70.0
  
  /**
   The corner radius. Default is 10.0.
   */
  public var cornerRadius: CGFloat = 2.0
  
  /**
   The title font. Default is `.boldSystemFont(15.0)`.
   */
  public var titleFont: UIFont = .boldSystemFont(ofSize: 15.0)
  
  /**
   The message font. Default is `.systemFont(ofSize: 15.0)`.
   */
  public var messageFont: UIFont = .systemFont(ofSize: 15.0)
  
  /**
   The title text alignment. Default is `NSTextAlignment.Left`.
   */
  public var titleAlignment: NSTextAlignment = .left
  
  /**
   The message text alignment. Default is `NSTextAlignment.Left`.
   */
  public var messageAlignment: NSTextAlignment = .left
  
  /**
   The maximum number of lines for the title. The default is 0 (no limit).
   */
  public var titleNumberOfLines = 0
  
  /**
   The maximum number of lines for the message. The default is 0 (no limit).
   */
  public var messageNumberOfLines = 0
  
  /**
   Enable or disable a shadow on the toast view. Default is `false`.
   */
  public var displayShadow = false
  
  /**
   The shadow color. Default is `.black`.
   */
  public var shadowColor: UIColor = .black
  
  /**
   A value from 0.0 to 1.0, representing the opacity of the shadow.
   Default is 0.8 (80% opacity).
   */
  public var shadowOpacity: Float = 0.8 {
    didSet {
      shadowOpacity = max(min(shadowOpacity, 1.0), 0.0)
    }
  }
  
  /**
   The shadow radius. Default is 6.0.
   */
  public var shadowRadius: CGFloat = 6.0
  
  /**
   The shadow offset. The default is 4 x 4.
   */
  public var shadowOffset = CGSize(width: 4.0, height: 4.0)
  
  /**
   The image size. The default is 80 x 80.
   */
  public var imageSize = CGSize(width: 80.0, height: 80.0)
  
  /**
   The size of the toast activity view when `makeToastActivity(position:)` is called.
   Default is 100 x 100.
   */
  public var activitySize = CGSize(width: 100.0, height: 100.0)
  
  /**
   The fade in/out animation duration. Default is 0.2.
   */
  public var fadeDuration: TimeInterval = 0.2
  
  /**
   Activity indicator color. Default is `.white`.
   */
  public var activityIndicatorColor: UIColor = .white
  
  /**
   Activity background color. Default is `.black` at 80% opacity.
   */
  public var activityBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.8)
  
}

// MARK: - Toast Manager

/**
 `ToastManager` provides general configuration options for all toast
 notifications. Backed by a singleton instance.
 */
fileprivate class ToastManager {
  
  /**
   The shared style. Used whenever toastViewForMessage(message:title:image:style:) is called
   with with a nil style.
   
   */
  public static var style = ToastStyle()
  
  /**
   Enables or disables tap to dismiss on toast views. Default is `false`.
   
   */
  public static var isTapToDismissEnabled = false
  
  /**
   Enables or disables queueing behavior for toast views. When `true`,
   toast views will appear one after the other. When `false`, multiple toast
   views will appear at the same time (potentially overlapping depending
   on their positions). This has no effect on the toast activity view,
   which operates independently of normal toast views. Default is `false`.
   
   */
  public static var isQueueEnabled = false
  
  /**
   The default duration. Used for the `makeToast` and
   `showToast` methods that don't require an explicit duration.
   Default is 3.0.
   
   */
  public static var duration: TimeInterval = 3.0
  
  /**
   Sets the default position. Used for the `makeToast` and
   `showToast` methods that don't require an explicit position.
   Default is `ToastPosition.Bottom`.
   
   */
  public static var position: ToastPosition = .bottom
  
}

// MARK: - ToastPosition

fileprivate enum ToastPosition {
  case top
  case center
  case bottom
  
  fileprivate func centerPoint(forToast toast: UIView, inSuperview superview: UIView) -> CGPoint {
    let topPadding: CGFloat = ToastManager.style.verticalPadding
    let bottomPadding: CGFloat = ToastManager.style.toastViewBottomPadding
    
    switch self {
    case .top:
      return CGPoint(x: superview.bounds.size.width / 2.0, y: (toast.frame.size.height / 2.0) + topPadding)
    case .center:
      return CGPoint(x: superview.bounds.size.width / 2.0, y: superview.bounds.size.height / 2.0)
    case .bottom:
      return CGPoint(x: superview.bounds.size.width / 2.0, y: (superview.bounds.size.height - (toast.frame.size.height / 2.0)) - bottomPadding)
    }
  }
}

extension UIView {
  
  private static func applicationWindow() -> UIWindow? {
    return UIApplication.shared.windows.first
  }
  
  static func getWindowSize() -> CGSize {
    let window = UIView.applicationWindow()
    return window?.bounds.size ?? CGSize.zero
  }
}


enum VerticalLocation: String {
  case bottom
  case top
}

extension UIView {
  func addShadow(location: VerticalLocation, color: UIColor = .black, opacity: Float = 0.1, radius: CGFloat = 2.0) {
    switch location {
    case .bottom:
      addShadow(offset: CGSize(width: 0, height: 10), color: color, opacity: opacity, radius: radius)
    case .top:
      addShadow(offset: CGSize(width: 0, height: -2), color: color, opacity: opacity, radius: radius)
    }
  }
  
  func addShadow(offset: CGSize, color: UIColor = .black, opacity: Float = 0.5, radius: CGFloat = 5.0) {
    self.layer.masksToBounds = false
    self.layer.shadowColor = color.cgColor
    self.layer.shadowOffset = offset
    self.layer.shadowOpacity = opacity
    self.layer.shadowRadius = radius
  }
}
