//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Grant Espanet on 8/6/24.
//

import Foundation
import Combine

class WeatherViewModel: ObservableObject {
    @Published var locationName: String? = nil
    @Published var currentWeather: WeatherData?
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var locationInput: String = ""
    @Published var isFetchingLocation = false
    private var locationUpdated = false // Flag to track if the location was updated automatically
    
    @Published var selectedDate = Date()
    
    private let locationManager = LocationManager()
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        locationManager.$zipCode
            .receive(on: DispatchQueue.main)
            .sink { [weak self] zipCode in
                guard let self = self else { return }
                self.locationUpdated = true // Set the flag before updating the zip code
                self.locationInput = zipCode
            }
            .store(in: &cancellables)
        
        locationManager.$locationError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let error = error {
                    self?.errorMessage = error
                }
            }
            .store(in: &cancellables)
    }
    
    let apiKey = Config.apiKey
        
    func fetchWeather(resetDay: Bool = true) {
        if resetDay {
            selectedDate = Date()
        }
        print("fetchWeather called")
        guard !locationInput.isEmpty else {
            errorMessage = "Please enter a valid city or zip code."
            return
        }
        
        // Fetch coordinates for the given city or zip code
        let geocodingUrlString: String
        if locationInput.allSatisfy({ $0.isNumber }) {
            // Input is a zip code
            geocodingUrlString = "https://api.openweathermap.org/geo/1.0/zip?zip=\(locationInput),US&appid=\(apiKey)"
        } else {
            // Input is a city name
            geocodingUrlString = "https://api.openweathermap.org/geo/1.0/direct?q=\(locationInput),US&appid=\(apiKey)"
        }
        
        guard let geocodingUrl = URL(string: geocodingUrlString) else {
            print("Invalid URL")
            return
        }
        
        isLoading = true
        
        URLSession.shared.dataTask(with: geocodingUrl) { data, response, error in
            if let networkError = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Network error: \(networkError.localizedDescription)"
                    self.isLoading = false
                }
                return
            }
            
            guard let data = data else {
                self.setError(error: "No data received")
                return
            }
            
            do {
                if self.locationInput.allSatisfy({ $0.isNumber }) {
                    // Input was a zip code
                    let geoData = try JSONDecoder().decode(Geo.self, from: data)
                    self.fetchWeatherForCoordinates(lat: geoData.lat, lon: geoData.lon, locationName: geoData.name)
                } else {
                    // Input was a city name
                    let geoDataArray = try JSONDecoder().decode([Geo].self, from: data)
                    if let geoData = geoDataArray.first {
                        self.fetchWeatherForCoordinates(lat: geoData.lat, lon: geoData.lon, locationName: geoData.name)
                    } else {
                        self.setError(error: "Invalid city name")
                    }
                }
            } catch {
                self.setError(error: "Error decoding geo data: \(error.localizedDescription)")
            }
        }.resume()
    }
        
    private func fetchWeatherForCoordinates(lat: Double, lon: Double, locationName: String) {
            print("fetchWeatherForCoordinates called")
            let dt = Int(selectedDate.timeIntervalSince1970)
            
            guard let url = URL(string: "https://api.openweathermap.org/data/3.0/onecall/timemachine?lat=\(lat)&lon=\(lon)&dt=\(dt)&appid=\(apiKey)&units=imperial") else {
                print("Invalid URL")
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                
                if let networkError = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Network error: \(networkError.localizedDescription)"
                    }
                    return
                }
                
                guard let data = data else {
                    self.setError(error: "No data received")
                    return
                }
                
                do {
                    let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                    if let forecast = weatherResponse.data.first(where: { Calendar.current.isDate(Date(timeIntervalSince1970: TimeInterval($0.dt)), inSameDayAs: self.selectedDate) }) {
                        DispatchQueue.main.async {
                            self.currentWeather = forecast
                            self.locationName = locationName
                            self.errorMessage = nil
                        }
                    } else {
                        self.setError(error: "No forecast available for selected date")
                    }
                } catch {
                    self.setError(error: "Error decoding weather data: \(error.localizedDescription)")
                }
            }.resume()
        }
    
    func requestLocation() {
        locationManager.requestLocation()
    }
    
    private func setError(error: String) {
        DispatchQueue.main.async {
            self.errorMessage = error
            self.currentWeather = nil
            self.locationName = nil
        }
    }
}
