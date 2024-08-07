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
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                self.locationError = "Failed to get postal code: \(error.localizedDescription)"
                return
            }
            
            if let placemark = placemarks?.first, let postalCode = placemark.postalCode {
                DispatchQueue.main.async {
                    self.zipCode = postalCode
                }
            } else {
                self.locationError = "Failed to get postal code"
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user location: \(error.localizedDescription)")
        locationError = "Failed to get user location: \(error.localizedDescription)"
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            locationError = "Location access denied. Please enable location services in settings."
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        @unknown default:
            locationError = "Unknown location authorization status."
        }
    }
}
