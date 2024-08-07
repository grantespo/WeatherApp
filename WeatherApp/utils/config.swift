//
//  config.swift
//  WeatherApp
//
//  Created by Grant Espanet on 8/6/24.
//

import Foundation

struct Config {
    static let apiKey: String = {
        guard let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist") else {
            fatalError("Couldn't find file 'Secrets.plist'.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "OpenWeatherAPIKey") as? String else {
            fatalError("Couldn't find key 'OpenWeatherAPIKey' in 'APIKeys.plist'.")
        }
        return value
    }()
}
