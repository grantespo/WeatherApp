//
//  ContentView.swift
//  WeatherApp
//
//  Created by Grant Espanet on 8/6/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject private var viewModel = WeatherViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    HStack {
                        TextField("Enter City or Zip Code", text: $viewModel.locationInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .padding()
                        Button(action: {
                            viewModel.fetchWeather()
                            hideKeyboard()
                        }) {
                            Image(systemName: "magnifyingglass")
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(colorScheme == .dark ? Color(.darkGray) : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            viewModel.requestLocation()
                        }) {
                            Image(systemName: "location.circle")
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(colorScheme == .dark ? Color(.darkGray) : .blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    
                    if viewModel.isLoading {
                        ProgressView("Loading...")
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        WeatherView(viewModel: viewModel)
                    }
                    Spacer()
                }
                .navigationTitle(viewModel.locationName ?? "Weather")
            }.background(
                LinearGradient(
                    gradient: Gradient(colors: [.blue.opacity(0.2), .blue.opacity(0.8)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
            )
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
