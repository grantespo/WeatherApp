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
    
    @Published var selectedDate = Date()
    
    private let locationManager = LocationManager()
    private var cancellables: Set<AnyCancellable> = []
    private let networkClient = NetworkClient()
    
    init() {
        locationManager.$zipCode
            .receive(on: DispatchQueue.main)
            .filter { [weak self] in $0 != self?.locationInput }
            .sink { [weak self] zipCode in
                guard let self = self else { return }
                self.locationInput = zipCode
                self.fetchWeather()
            }
            .store(in: &cancellables)
        
        locationManager.$locationError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let self = self else { return }
                if let error = error {
                    self.errorMessage = error
                }
            }
            .store(in: &cancellables)
    }
    
    let apiKey = Config.apiKey
    
    func fetchWeather(resetDay: Bool = true) {
        if resetDay {
            selectedDate = Date()
        }
        guard !locationInput.isEmpty,
        !(locationInput.allSatisfy({ $0.isNumber }) && locationInput.count != 5) else {
            errorMessage = "Please enter a valid city or zip code."
            return
        }
        
        let geocodingUrlString: String
        if locationInput.allSatisfy({ $0.isNumber }) {
            geocodingUrlString = APIConstants.geoBaseURL + "zip?zip=\(locationInput),US&appid=\(apiKey)"
        } else {
            geocodingUrlString = APIConstants.geoBaseURL + "direct?q=\(locationInput),US&appid=\(apiKey)"
        }
        
        guard let geocodingUrl = URL(string: geocodingUrlString) else {
            setError(error: "Invalid URL")
            return
        }
        
        isLoading = true
        
        if locationInput.allSatisfy({ $0.isNumber }) {
            // Input is a zip code, expecting a single Geo object
            networkClient.fetchData(from: geocodingUrl, as: Geo.self)
                .sink(receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    switch completion {
                    case .failure(let error):
                        self.setError(error: "Error: \(error.localizedDescription)")
                    case .finished:
                        break
                    }
                }, receiveValue: { [weak self] geoData in
                    guard let self = self else { return }
                    self.fetchWeatherForCoordinates(lat: geoData.lat, lon: geoData.lon, locationName: geoData.name)
                })
                .store(in: &cancellables)
        } else {
            // Input is a city name, expecting an array of Geo objects
            networkClient.fetchData(from: geocodingUrl, as: [Geo].self)
                .sink(receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    switch completion {
                    case .failure(let error):
                        self.setError(error: "Error: \(error.localizedDescription)")
                    case .finished:
                        break
                    }
                }, receiveValue: { [weak self] geoDataArray in
                    guard let self = self else { return }
                    if let geoData = geoDataArray.first {
                        self.fetchWeatherForCoordinates(lat: geoData.lat, lon: geoData.lon, locationName: geoData.name)
                    } else {
                        self.setError(error: "Invalid city name")
                    }
                })
                .store(in: &cancellables)
        }
    }
    
    private func fetchWeatherForCoordinates(lat: Double, lon: Double, locationName: String) {
        let dt = Int(selectedDate.timeIntervalSince1970)
        
        guard let url = URL(string: APIConstants.onecall3BaseURL + "timemachine?lat=\(lat)&lon=\(lon)&dt=\(dt)&appid=\(apiKey)&units=imperial") else {
            self.setError(error: "Invalid URL")
            return
        }
        
        networkClient.fetchData(from: url, as: WeatherResponse.self)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .failure(let error):
                    self.setError(error: "Error: \(error.localizedDescription)")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] weatherResponse in
                guard let self = self else { return }
                
                if let forecast = weatherResponse.data.first(where: { Calendar.current.isDate(Date(timeIntervalSince1970: TimeInterval($0.dt)), inSameDayAs: self.selectedDate) }) {
                    self.currentWeather = forecast
                    self.locationName = locationName
                    self.errorMessage = nil
                    self.isLoading = false
                } else {
                    self.setError(error: "No forecast available for selected date")
                }
            })
            .store(in: &cancellables)
    }
    
    func requestLocation() {
        locationManager.requestLocation()
    }
    
    private func setError(error: String) {
        DispatchQueue.main.async {
            self.errorMessage = error
            self.currentWeather = nil
            self.locationName = nil
            self.isLoading = false
        }
    }
}
