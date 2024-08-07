//
//  WeatherDetailCard.swift
//  WeatherApp
//
//  Created by Grant Espanet on 8/7/24.
//

import SwiftUI

struct WeatherDetailCard: View {
    @Environment(\.colorScheme) var colorScheme
    
    var weather: WeatherData
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                WeatherDetailView(iconName: "thermometer", title: "Feels like", value: String(format: "%.1f°F", weather.feelsLike))
                WeatherDetailView(iconName: "wind", title: "Wind", value: String(format: "\(windDirection(from: Double(weather.windDeg)))" + " " + "%.1f mph", weather.windSpeed))
            }
            
            HStack {
                WeatherDetailView(iconName: "humidity", title: "Humidity", value: "\(weather.humidity)%")
                WeatherDetailView(iconName: "cloud", title: "Cloudiness", value: "\(weather.clouds)%")
            }

            HStack {
                WeatherDetailView(iconName: "sunrise", title: "Sunrise", value: formattedTime(from: TimeInterval(weather.sunrise)))
                WeatherDetailView(iconName: "sunset", title: "Sunset", value: formattedTime(from: TimeInterval(weather.sunset)))
            }
        }
        .padding()
        .background(colorScheme == .dark ? Color(.darkGray) : .white)
        .cornerRadius(20)
        .shadow(radius: 5)
    }
    
    private func formattedTime(from timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: date)
    }
    
    private func windDirection(from degrees: Double) -> String {
        switch degrees {
        case 0..<11.25, 348.75..<360:
            return "N"
        case 11.25..<33.75:
            return "NNE"
        case 33.75..<56.25:
            return "NE"
        case 56.25..<78.75:
            return "ENE"
        case 78.75..<101.25:
            return "E"
        case 101.25..<123.75:
            return "ESE"
        case 123.75..<146.25:
            return "SE"
        case 146.25..<168.75:
            return "SSE"
        case 168.75..<191.25:
            return "S"
        case 191.25..<213.75:
            return "SSW"
        case 213.75..<236.25:
            return "SW"
        case 236.25..<258.75:
            return "WSW"
        case 258.75..<281.25:
            return "W"
        case 281.25..<303.75:
            return "WNW"
        case 303.75..<326.25:
            return "NW"
        case 326.25..<348.75:
            return "NNW"
        default:
            return "N"
        }
    }
}
