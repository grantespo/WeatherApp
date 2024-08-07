//
//  WeatherImage.swift
//  WeatherApp
//
//  Created by Grant Espanet on 8/6/24.
//

import SwiftUI

struct AsyncImageView: View {
    @StateObject private var loader: ImageLoader
    private let placeholder: Image

    init(url: URL, placeholder: Image = Image(systemName: "photo")) {
        _loader = StateObject(wrappedValue: ImageLoader(url: url))
        self.placeholder = placeholder
    }

    var body: some View {
        content
            .onAppear(perform: loader.load)
    }

    private var content: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
            } else {
                placeholder
                    .resizable()
            }
        }
    }
}

private class ImageLoader: ObservableObject {
    @Published var image: UIImage?

    private let url: URL

    init(url: URL) {
        self.url = url
    }

    func load() {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }.resume()
    }
}
