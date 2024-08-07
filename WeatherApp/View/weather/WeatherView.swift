//
//  WeatherView.swift
//  WeatherApp
//
//  Created by Grant Espanet on 8/6/24.
//

import SwiftUI

struct WeatherView: View {
    @ObservedObject var viewModel: WeatherViewModel
    
    var body: some View {
        ZStack {
            VStack {
                if let weather = viewModel.currentWeather {
                    VStack {
                        HStack {
                            // Calendar Widget Button
                            DatePicker("", selection: $viewModel.selectedDate, in:  Calendar.current.date(from: DateComponents(year: 1979, month: 1, day: 1))!...Calendar.current.date(byAdding: .day, value: 4, to: Date())!, displayedComponents: .date)
                                .labelsHidden()
                                .datePickerStyle(CompactDatePickerStyle())
                                .onChange(of: viewModel.selectedDate) {
                                    viewModel.fetchWeather(resetDay: false)
                                }
                        }
                        
                        HStack {
                            Text("\(weather.temp, specifier: "%.1f")°F")
                                .font(.title)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .frame(maxWidth: .infinity)
                            Spacer()
                        }
                        
                        Text(weather.weather.first?.description.capitalized ?? "")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        if let icon = weather.weather.first?.icon {
                            AsyncImageView(url: URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")!)
                                .id(icon) // Force reload when icon URL changes
                                .frame(width: 100, height: 100).padding(.bottom)
                        }
                        
                        WeatherDetailCard(weather: weather)
                    }
                    .padding()
                } else {
                    Text("Please enter a zipcode to see the weather.")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                }
            }
        }
    }
}
