//
//  location.swift
//  WeatherApp
//
//  Created by Grant Espanet on 8/6/24.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var zipCode: String = ""
    @Published var locationError: String? = nil
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }
    
    func requestLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.async {
                if let placemark = placemarks?.first, let postalCode = placemark.postalCode {
                    self.zipCode = postalCode
                } else {
                    self.locationError = "Failed to get postal code"
                    print("Failed to get postal code: \(error?.localizedDescription ?? "")")
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.locationError = "Failed to get user location"
            print("Failed to get user location: \(error.localizedDescription)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            switch status {
            case .notDetermined:
                self.locationManager.requestWhenInUseAuthorization()
            case .restricted, .denied:
                self.locationError = "Location access denied. Please enable location services in settings."
            case .authorizedWhenInUse, .authorizedAlways:
                self.locationManager.requestLocation()
            @unknown default:
                self.locationError = "Unknown location authorization status."
            }
        }
    }
}
