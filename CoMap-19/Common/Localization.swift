//
//  Localization.swift
//  CoMap-19
//

//
//

import Foundation

class Localization {
  
  static var bluetooth: String {
    get {
      return NSLocalizedString("bluetooth", comment: "Bluetooth")
    }
  }
  static var countryCode: String {
    get {
      return NSLocalizedString("country_code", comment: "+91")
    }
  }
  static var deviceLocation: String {
    get {
      return NSLocalizedString("device_location", comment: "Device Location")
    }
  }
  static var enterMobileNumber: String  {
    get {
      return NSLocalizedString("enter_mobile_number", comment: "Enter Mobile Number")
    }
  }
  static var enterOtp: String {
    get {
      return NSLocalizedString("enter_otp", comment: "Enter OTP")
    }
  }
  
  static var iUnderstand: String {
    get {
      return NSLocalizedString("i_understand", comment: "I understand.")
    }
  }
  
  static var mobileNumber: String {
    get {
      return NSLocalizedString("mobile_number", comment: "Mobile Number")
    }
  }
  
  static var otp: String {
    get {
      return NSLocalizedString("otp", comment: "OTP")
    }
  }
  static var permissionsDetail: String {
    get {
      return NSLocalizedString("permissions_detail", comment: "We understand the nature and sensitivity of this topic and have taken strong measures to ensure that your data is not compromised.")
    }
  }
  
  static var permissionsTitle: String {
    get {
      return NSLocalizedString("permissions_title", comment: "Terms of Service & Privacy")
    }
  }
  
  static var submit: String {
    get {
      return NSLocalizedString("submit", comment: "Submit")
    }
  }
  
  static var weHaveSentOtp: String {
    get {
      return NSLocalizedString("we_have_sent_otp", comment: "We have sent OTP to your mobile number.")
    }
  }
  static var whyIsItNeeded: String {
    get {
      return NSLocalizedString("why_is_it_needed", comment: "Why is it needed?")
    }
  }
  static var yourMobileNumberIsRequiredToKnowYourIdentity: String {
    get {
      return NSLocalizedString("your_mobile_number_is_required_to_know_your_identity", comment: "Your mobile number is required for contact tracing.")
    }
  }
  
  static var eachOneOfUs: String {
    return NSLocalizedString("each_one_of_us", comment: "Each one of us has the power to help\n prevent the spread of the Coronavirus\n pandemic in India.")
  }
  
  static var wouldYouLike: String {
    return NSLocalizedString("would_you_like", comment: "Would you like to be kept informed if you\n have crossed paths with someone who\n has tested COVID-19 positive?")
  }
  
  static var cowin20Tracks: String {
    return NSLocalizedString("cowin20_tracks", comment: "Swaraksha tracks, through a Bluetooth /\nLocation generated social graph, your\ninteraction with someone who could have\ntested COVID-19 positive.")
  }
  
  static var simplyInstall: String {
    return NSLocalizedString("simply_install", comment: "Simply,\n1. Install the app\n2. Switch on Bluetooth & Location\n3. Set location sharing to ‘Always’\n\nInvite your friends and family\n to install the app too.")
  }
  
  static var youWillBeAlerted: String {
    return NSLocalizedString("you_will_be_alerted", comment: "You will be alerted if someone you have\ncome in close proximity of, even\n unknowingly, tests COVID-19 positive")
  }
  
  static var theAppAlerts: String {
    return NSLocalizedString("the_app_alerts", comment: "The app alerts are accompanied by\n instructions on how to self-isolate and\nwhat to do in case you develop symptoms\nthat may need help and support.")
  }
  
  static var withCowin20: String {
    return NSLocalizedString("with_cowin20", comment: "With Swaraksha, you can protect yourself,\nyour family and friends, and help our\ncountry in the effort to fight COVID-19")
  }
  
  static var pleaseUpgrade: String {
    return NSLocalizedString("please_upgrade", comment: "Please Upgrade")
  }
  
  static var upgrade: String {
    return NSLocalizedString("upgrade", comment: "Upgrade")
  }
  
  static var pleaseDownloadLatestVersion: String {
    return NSLocalizedString("please_download_latest_version", comment: "Please download latest version of %@ to continue using its safety services.")
  }
  
  static var dataSharingWithMoh: String {
    return NSLocalizedString("data_sharing_with_moh", comment: "Data Sharing")
  }
  
  static var setsYourLocation: String {
    return NSLocalizedString("sets_your_location", comment: "It is recommended that you set your location sharing to ‘Always’. You can change this anytime later.")
  }
  
  static var monitorsYourDevice: String {
    return NSLocalizedString("monitors_your_device", comment: "Monitors your device’s proximity to another mobile device. It is recommended that you keep it on at all times.")
  }
  
  static var dataWillBeSentOnlyToMoi: String {
    return NSLocalizedString("data_will_be_sent_only_to_moi", comment: "Your Data will be shared only with the Government of India. The App does not allow your name and number to be disclosed to the public at large at any time.")
  }
  
  static var contributeToASaferIndia: String {
    return NSLocalizedString("contribute_to_a_safer_india", comment: "I Agree")
  }
  
  static var registerNow: String {
    return NSLocalizedString("register_now", comment: "Register Now")
  }
  
  static var resendOtp: String {
    return NSLocalizedString("resend_otp", comment: "Resend OTP")
  }
  
  static var whyIsItNeededSubTitle: String {
    return NSLocalizedString("why_is_it_needed_sub_title", comment: "Say, you met someone a week back at a gathering or were in close proximity of someone unknown at a public place, and in a few days, they test positive for COVID-19.\n\nThe Government of India will trace back all touch points of that person, through the active devices with the app installed that were in close radius of that person, in the past 14 days.\n\nA notification will then be sent to all such contacts with an advisory on further course of action, to self-isolate or to get the test done at a nearest testing centre, as needed.\n\nBy participating in active contact tracing, you will help us minimise the spread of COVID-19 and enable Government of India to implement proactive measures for your health and well-being.")
  }
  
  
  static var next: String {
    return NSLocalizedString("next", comment: "")
  }
  
  static var ok: String {
    return  NSLocalizedString("ok", comment: "Ok")
  }
  
  static var close: String {
    return NSLocalizedString("close", comment: "Close")
  }
  
  static var termsAndConditions: String {
    return NSLocalizedString("terms_n_conditions", comment: "Terms & Conditions")
  }
  
  static var invalidMobileNo: String {
    return NSLocalizedString("Please enter valid mobile number", comment: "Please enter valid mobile number")
  }
  
  static var genericOTPError: String {
    return NSLocalizedString("generic_otp_error", comment: "Something went wrong")
  }
  
  static var genericSignInError: String {
    return NSLocalizedString("generic_signin_error", comment: "Something went wrong")
  }
  
  static var registrationFailed: String {
    return NSLocalizedString("registration_failed", comment: "Registration Failed")
  }
  
  static var selectLanguageTitle: String {
    return NSLocalizedString("select_language", comment: "Please select your language")
  }
  
  static var permissionScreenTnC: String {
    return NSLocalizedString("permission_screen_tnc", comment: "If you would like to contribute to a safer India please indicate your acceptance of the Terms of Service and the Privacy Policy by clicking on the button below")
  }
  
  static var tryAgain: String {
    return NSLocalizedString("try_again", comment: "Try Again")
  }
  
  static var settings: String {
    return NSLocalizedString("settings", comment: "Settings")
  }
  
  static var turnOnText: String {
    return NSLocalizedString("turn_on", comment: "Turn On")
  }
  
  static var laterText: String {
    return NSLocalizedString("later", comment: "Later")
  }
  
  static var locationAlertTitle: String {
    return NSLocalizedString("location_alert_title", comment: "Turn on Location")
  }
  
  static var locationAlertSubTitle: String {
    return NSLocalizedString("location_alert_subtitle", comment: "Location must be set to Always, to track your history and give you accurate safety updates.")
  }
  
  static var bluetoothAlertTitle: String {
    return NSLocalizedString("bluetooth_alert_title", comment: "Turn on Bluetooth")
  }
  
  static var bluetoothAlertSubTitle: String {
    return NSLocalizedString("bluetooth_alert_subtitle", comment: "Bluetooth must be on at all times to track your proximity to other devices and give you accurate safety updates.")
  }
  
  static var internetConnectionLost: String {
    return NSLocalizedString("internet_connection_lost", comment: "Internet Connection Lost")
  }
  
  static var makeSureYourPhoneIsConnectedToWifi: String {
    return NSLocalizedString("make_sure_your_phone_is_connected_to_wifi", comment: "Make sure your phone is connected to the WiFi or switch to mobile data.")
  }
  
  static var shareAppMessage: String {
    return NSLocalizedString("share_app_message", comment: "I recommend Aarogya Setu app to fight against COVID19. Please download and share it using this link")
  }
  
  static var uploadDataConsentTitle: String {
    return NSLocalizedString("upload_consent_title", comment: "Your data is always saved on your phone. If you have tested positive for COVID-19 or are currently being tested for COVID-19 you can report this to the government. When you do so you will upload your data to the Government.")
  }
  
  static var uploadDataConsentSubTitle: String {
    return NSLocalizedString("upload_consent_subtitle", comment: "I confirm:")
  }
  
  static var beingTested: String {
    return NSLocalizedString("being_tested", comment: "I have tested positive for COVID-19")
  }
  
  static var testedPositive: String {
    return NSLocalizedString("tested_positive", comment: "I am currently being tested for COVID-19")
  }
  
  static var noneOfAbove: String {
    return NSLocalizedString("none_of_above", comment: "None of these apply to me")
  }
  
  static var confirmAndProceed: String {
    return NSLocalizedString("confirm_proceed", comment: "Confirm & Proceed")
  }
  
  static var toHelpContactTracing: String {
    return NSLocalizedString("to_help_contact_tracing", comment: "To help contact tracing, your interaction data captured with Bluetooth and GPS services will be shared with Government of India.")
  }
  
  static var sendingInteractionData: String {
    return NSLocalizedString("sending_interaction_data", comment: "Sending interaction data captured with Bluetooth& GPS services to Government of India.")
  }
  
  static var cancel: String {
    return NSLocalizedString("cancel", comment: "Cancel")
  }
  
  static var syncingData: String {
    return NSLocalizedString("syncingData", comment: "Syncing Data")
  }
  
  static var somethingWentWrong: String {
    return NSLocalizedString("something_went_wrong_please_retry", comment: "Something went wrong, please retry.")
  }
  
  static var retry: String {
    return NSLocalizedString("retry", comment: "Retry")
  }
  
  static var syncFailed: String {
    return NSLocalizedString("sync_failed", comment: "Sync Failed")
  }
  
  static var yourDataSecured: String {
    return NSLocalizedString("your_data_secured", comment: "Your data is now secured on Government of India servers.")
  }
  
  static var syncSuccessful: String {
    return NSLocalizedString("sync_successful", comment: "Sync Successful")
  }
  
  static var appVersion: String {
    return NSLocalizedString("app_version", comment: "App Version")
  }
  
  static var shareDataWithGov: String {
    return NSLocalizedString("share_data_gov", comment: "Share Data with Govt.")
  }
  
  static var shareDataPositive: String {
    return NSLocalizedString("share_data_positive", comment: "Share only if you have tested positive for COVID-19 or are currently being tested")
  }
  
  static var callHelpline: String {
    return NSLocalizedString("call_helpline", comment: "Call Helpline (1075)")
  }
  
  static var healthMinistryTollFree: String {
    return NSLocalizedString("health_ministry_toll_free", comment: "Health ministry toll-free helpline for queries related to COVID-19")
  }
  
  static var qrCode: String {
    return NSLocalizedString("qr_code", comment: "Generate/Scan QR Code")
  }
  
  static var privacyPolicy: String {
    return NSLocalizedString("privacy_policy", comment: "Privacy Policy")
  }
  
  static var termsUse: String {
    return NSLocalizedString("terms_use", comment: "Terms of Use")
  }
  
  static var ratingTitle: String {
    return NSLocalizedString("rating_title", comment: "Rate us on the App Store to help make Aarogya Setu even better.")
  }
  
  static var notNow: String {
    return NSLocalizedString("not_now", comment: "Not Now")
  }
  
  static var rateNow: String {
    return NSLocalizedString("rate_now", comment: "Rate Now")
  }
  
  static var scanQrCodeToGetMyHealthStatus: String {
    return NSLocalizedString("scan_Qr_Code_To_Get_My_Health_Status", comment: "Scan QR Code to get my health status")
  }
  
  static var refreshQrCode: String {
    return NSLocalizedString("refresh_Qr_Code", comment: "Refresh QR Code")
  }
  
  static var qrCodeValidFor: String {
    return NSLocalizedString("qr_Code_Valid_For", comment: "QR code valid for")
  }
  
  static var toGenerateQrBleAndGpsMustBeON: String {
    return NSLocalizedString("to_Generate_Qr_Ble_And_Gps_Must_Be_ON", comment: "To generate QR code, Bluetooth & GPS must be in “ON” state")
  }
  
  static var turnOnBleAndGps: String {
    return NSLocalizedString("turn_On_Ble_And_Gps", comment: "Turn on Bluetooth & GPS")
  }
  
  static var turnOnBle: String {
    return NSLocalizedString("turn_On_Ble", comment: "Turn on Bluetooth")
  }
  
  static var turnOnGps: String {
    return NSLocalizedString("turn_On_Gps", comment: "Turn on GPS")
  }
  
  static var qrCodeIsExpired: String {
    return NSLocalizedString("qr_Code_Is_Expired", comment: "QR Code is Expired")
  }
  
  static var toolTip: String {
    return NSLocalizedString("tool_tip", comment: "A lot of new Features like Helpline, Privacy Policy, Terms of Use and more can be found here.")
  }
  
  static var expiredQrCode: String {
    return NSLocalizedString("expired_qr_code", comment: "Expired QR Code")
  }
  
  static var pleaseRequestThePersonToGenerateNewCode: String {
    return NSLocalizedString("please_request_the_person_to_generate_new_code", comment: "Please request the person to generate new code")
  }
  
  static var lowRiskOfInfection: String {
    return NSLocalizedString("low_risk_of_infection", comment: "%@ is at low risk of infection")
  }
  
  static var moderateRiskOfInfection: String {
    return NSLocalizedString("moderate_risk_of_infection", comment: "%@ is at moderate risk of infection")
  }
  
  static var highRiskOfInfection: String {
    return NSLocalizedString("high_risk_of_infection", comment: "%@ is at high risk of infection")
  }
  
  static var testedPositiveForCovid19: String {
    return NSLocalizedString("tested_positive_for_covid19", comment: "%@ has tested positive for COVID-19")
  }
  
  static var invalidQrCode: String {
    return NSLocalizedString("invalid_qr_code", comment: "Invalid QR Code")
  }
  
  static var notGeneratedByOfficialApp: String {
    return NSLocalizedString("not_generated_by_official_app", comment: "It has not been generated by official Aarogya Setu app.")
  }
  
  static var scanQrCode: String {
    return NSLocalizedString("scan_qr_code", comment: "Scan QR Code")
  }
  
  static var generateMyQrCode: String {
    return NSLocalizedString("generate_my_qr_code", comment: "Generate my QR code")
  }
  
  static var scanQrPrompt: String {
    return NSLocalizedString("scan_qr_prompt", comment: "Scan QR Code to check health status of someone else")
  }
  
  static var approve: String {
    return NSLocalizedString("approve", comment: "Approve")
  }
  
  static var reject: String {
    return NSLocalizedString("reject", comment: "Reject")
  }
  
  static var alwaysApprove: String {
    return NSLocalizedString("always_approve", comment: "Always Approve")
  }
  
  static var why: String {
    return NSLocalizedString("why", comment: "")
  }
  
  static var requestApproved: String {
    return NSLocalizedString("request_approved", comment: "")
  }
  
  static var requestRejected: String {
    return NSLocalizedString("request_rejected", comment: "")
  }
  
  static var requestApprovedMessage: String {
    return NSLocalizedString("request_approved_detail", comment: "")
  }
  
  static var requestRejectedMessage: String {
    return NSLocalizedString("request_rejected_detail", comment: "")
  }
  
  static var requestAlwaysApprovedMessage: String {
    return NSLocalizedString("request_always_approved_detail", comment: "")
  }
  
  static var approvals: String {
    return NSLocalizedString("approvals", comment: "")
  }
  
  static var approved: String {
    return NSLocalizedString("approved", comment: "")
  }
  
  static var rejected: String {
    return NSLocalizedString("rejected", comment: "")
  }
  
  static var alwaysApproved: String {
    return NSLocalizedString("always_approved", comment: "")
  }
  
  static var pendingRequest: String {
    return NSLocalizedString("%@ has requested for your Aarogya Setu status", comment: "")
  }

  static var viewRequest: String {
    return NSLocalizedString("view_request", comment: "")
  }
  
  static var pendingRequestTitle: String {
    return NSLocalizedString("no_pending_approval_title", comment: "")
  }
  
  static var pendingRequestSubtitle: String {
    return NSLocalizedString("no_pending_approval_detail", comment: "")
  }
  static var deleteAccount: String {
    return NSLocalizedString("delete_account", comment: "Delete Account")
  }
  
  static var deleteMyAccount: String {
    return NSLocalizedString("delete_account_title", comment: "Delete My Account")
  }
  
  static var permanentDeleteAccount: String {
    return NSLocalizedString("delete_account_summary", comment: "You can permanently delete your account and erase all data.")
  }

  static var approvalForAarogyaSetuStatus: String {
    return NSLocalizedString("approvals_preference_title", comment: "")
  }
  
  static var externalAppsAccessSetu: String {
    NSLocalizedString("approvals_preference_summary", comment: "")
  }
  
  static var blocked: String {
    NSLocalizedString("blocked", comment: "")
  }
  
  static var askForApproval: String {
    NSLocalizedString("always_ask", comment: "")
  }
  
  static var block: String {
    NSLocalizedString("block", comment: "")
  }
  
  static var askForApprovalEverytime: String {
    NSLocalizedString("always_ask", comment: "")
  }
  
  static var reportAbuse: String {
    NSLocalizedString("report_abuse", comment: "")
  }
  
  static var reportAbuseTitle: String {
    NSLocalizedString("report_abuse_title", comment: "")
  }
  
  static var reportAbuseSubtitle: String {
    NSLocalizedString("report_abuse_detail", comment: "")
  }
  
  static var other: String {
    NSLocalizedString("other", comment: "")
  }
  
  static var spam: String {
    NSLocalizedString("suspicious_spam", comment: "")
  }
  
  static var notInitiate: String {
    NSLocalizedString("didnt_initiate_request", comment: "")
  }
  
  static var report: String {
     NSLocalizedString("report", comment: "")
   }
  
  static var statusCheck: String {
    NSLocalizedString("status_check", comment: "")
  }
  
  static var keepACheckOnStatus: String {
    NSLocalizedString("status_check_detail", comment: "")
  }
  
  static var addAccount: String {
    NSLocalizedString("add_account", comment: "")
  }
  
  static var wantOtherToCheckStatus: String {
    NSLocalizedString("want_app_to_keep_check", comment: "")
  }
  
  static var youCanKeepACheck: String {
    NSLocalizedString("keep_a_check_on_app", comment: "")
  }
  
  static var generateAndShareCode: String {
    NSLocalizedString("generate_and_share", comment: "")
  }
  
  static var add: String {
    NSLocalizedString("add", comment: "")
  }
  
  static var code: String {
    NSLocalizedString("code", comment: "")
  }
  
  static var enterCode: String {
    NSLocalizedString("enter_code", comment: "")
  }
  
  static var verifyAndAdd: String {
    NSLocalizedString("verify_and_add", comment: "")
  }
  
  static var enterRegister: String {
    NSLocalizedString("verify_and_add", comment: "")
  }
  
  static var shareYourCode: String {
    NSLocalizedString("Share code to enable user to keep a check on your status.", comment: "")
  }
  
  static var copy: String {
    NSLocalizedString("copy", comment: "")
  }
  
  static var share: String {
    NSLocalizedString("share", comment: "")
  }
  
  static var remove: String {
    NSLocalizedString("remove", comment: "")
  }
  
  static var approvalPreferences: String {
    NSLocalizedString("approvals_preference", comment: "")
  }
  
  static var userPreferenceNoRecord: String {
    NSLocalizedString("approvals_no_preference_summary", comment: "")
  }
  
  static var generateCode: String {
    NSLocalizedString("generate_code", comment: "")
  }
  
  static var enterMobileNumberStatus: String {
    NSLocalizedString("registered_mobile_detail", comment: "")
  }
  
  static var getUniqueCode: String {
    NSLocalizedString("get_code_detail", comment: "")
  }
  
  static var codeValidDuration: String {
     NSLocalizedString("code_valid_for", comment: "")
   }
  
  static var shareYourCodeMobile: String {
    NSLocalizedString("share_code_to_enable", comment: "")
  }
  
  static var autoApproved: String {
    NSLocalizedString("auto_approved", comment: "")
  }
  
  static var autoRejected: String {
    NSLocalizedString("auto_rejected", comment: "")
  }
  
  static var apps: String {
    NSLocalizedString("apps", comment: "")
  }
  
  static var users: String {
    NSLocalizedString("users", comment: "")
  }
  
  static var minutesAgo: String {
    NSLocalizedString("minutes_ago", comment: "")
  }
}
