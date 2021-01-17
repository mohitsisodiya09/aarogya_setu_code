//
//  LocationService.swift
//  Comap
//
//

import Foundation
import CoreLocation
import GameplayKit
import UIKit

protocol LocationServiceDelegate: AnyObject {
  func locationService(_ locationService: LocationService, didUpdateLocation location: CLLocation)
  func locationService(_ locationService: LocationService, didFailWithError error: Error)
}

final class LocationService: NSObject {

  // MARK: - Private Variables declaration

  fileprivate let locationManager = CLLocationManager()
  fileprivate let distanceFilter: CLLocationDistance = 100

  // MARK: - Public Variables declaration

  weak var delegate: LocationServiceDelegate?

  // MARK: - Public Methods
  
  func stopUpdatingLocation() {
    locationManager.stopUpdatingLocation()
    locationManager.delegate = nil
    delegate = nil
  }
  
  func startUpdatingLocation() {
    if CLLocationManager.locationServicesEnabled() {
      locationManager.startUpdatingLocation()
    }
  }
  
  func setupLocationService() {
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    locationManager.distanceFilter = self.distanceFilter
    locationManager.requestAlwaysAuthorization()
  }
}

// MARK: - CLLocationManagerDelegate
// MARK: -

extension LocationService: CLLocationManagerDelegate {

  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

    switch status {
    case .notDetermined:
      locationManager.requestWhenInUseAuthorization()
    case .restricted, .denied:
      AlertView.showLocationAlert(internetConnectionLost: {
          //Open Setting for Bluetooth
          guard let url = URL(string: UIApplication.openSettingsURLString) else {
              return
          }
          let app = UIApplication.shared
          app.open(url)
      }) {
          //Cancel Do Nothing
      }
      break
    default:
      startUpdatingLocation()
    }
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.last {
      delegate?.locationService(self, didUpdateLocation: location)
    }
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    delegate?.locationService(self, didFailWithError: error)
  }
}
