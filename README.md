# Aarogya Setu iOS app

![alt text](./Icon.png "AarogyaSetu Logo")

Aarogya Setu is a mobile application developed by the Government of India to connect essential health services with the people of India in our combined fight against COVID-19. The App is aimed at augmenting the initiatives of the Government of India, particularly the Department of Health, in proactively reaching out to and informing the users of the app regarding risks, best practices and relevant advisories pertaining to the containment of COVID-19.

## Features

Aarogya Setu mobile application provides the following features:

- Minimal and simple user interface, which user can get easily acquainted with
- Scan nearby Aarogya Setu user using BluetoothLE Scanner 
- Advertise to nearby Aarogya Setu user using BluetoothLE GATT Server
- Update user about nearby activity using Location Service
- Secure information transfer with SSL Pinning
- Encrypt any sensitive information
- Available in 12 different languages
- Nation wide COVID-19 Statistics
- Self-Assessment as per MoHFW and ICMR guidelines
- Emergency Helpline Contact
- List of ICMR approved labs with COVID-19 testing facilities
- e-Pass integration

The Aarogya Setu App is being widely used by more than 11 Crore Users. The App has been highly successful in identifying people with high risk of COVID-19 infection and has also played a major role in identifying potential COVID-19 hotspots. In the larger public interest and in order to help the international community in their COVID-19 efforts, the Government of India is opening the source code of this App under Apache License 2.0.

If you find any security issues or vulnerabilities in the code, then you can send the details to us at : as-bugbounty@nic.in

If you want to convey any other feedback regarding the App or Code, then you can send it to us at : support.aarogyasetu@nic.in



## Setup

### Requirements
- XCode 11.0.0
- Xcode Command Line
- Minimum iOS deployment target 10.3.0

### Configure
- GoogleService-Info.plist

**keystore.properties**

Setup a below constants with following sample detail and your configurations
```
# Server SSL Keys
pinnedPublicKeyHash = <Your Public Key>
backupPinnedPublicKeyHash = <Your Backup Key>
authenticationPublicKeyHash = <Your Auth Key>
authenticationBackupPublicKeyHash = <Your Auth Backup Key>

apiKeyValue = <Your AWS Key>
platformToken = <Platform token, can be any UUID>

# BLE UUIDs
# You can use terminal command uuidgen to generate UUID
AdvertisementAarogyaServiceCBUUID = <BLE Service UUID>
PeripheralAarogyaServiceDeviceCharactersticCBUUID = <UUID for Device Characterstic>
PeripheralAarogyaServiceDevicePinggerCBUUID = <UUID for Device Pingger>
PeripheralAarogyaServiceDeviceOSCBUUID = <UUID for Device OS>

# API URLs
WEB_URL = <Your Web URL>
WEB_BASE_URL = <Your Web Host>
BASE_URL = <Your App Host>
authBaseUrl = <Your Auth Host>

# API End Points
bulkUpload = /api/v1/endPoint/1/
registerUser = /api/v1/endPoint/2/
registerFcmToken = /api/v1/endPoint/3/
userStatus = /api/v1/endPoint/4/
appConfig = /api/v1/endPoint/5/
generateOTP = endPoint6
validateOTP = endPoint7
refreshToken = endPoint8
generateQrCode = /api/v1/endPoint/9/
publicQrKey = "api/v1/endPoint/10/

```

**Firebase and google-services.json**

Setup Firebase for the different environment.
Download the GoogleService-Info.plist for each of the environments and put it in the corresponding environment folder.

## Download App

<p align="center">
<a href='https://apps.apple.com/in/app/aarogyasetu/id1505825357'><img alt='Get it on Apple App Store' src='./Download_on_the_App_Store_Badge.png' width="50%"/></a>
</p>

