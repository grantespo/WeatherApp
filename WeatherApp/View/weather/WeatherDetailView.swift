//
//  WeatherDetailView.swift
//  WeatherApp
//
//  Created by Grant Espanet on 8/7/24.
//

import SwiftUI

struct WeatherDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var iconName: String
    var title: String
    var value: String
    
    var body: some View {
        VStack {
            Image(systemName: iconName)
                .font(.title)
                .foregroundColor(.blue)
            
            Text(title)
                .font(.caption)
                .foregroundColor(colorScheme == .dark ? Color(.lightGray) : .gray)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(colorScheme == .dark ? Color(.white) : .black)
        }
        .frame(maxWidth: .infinity)
    }
}
