//
//  Networking.swift
//  WeatherApp
//
//  Created by Grant Espanet on 8/10/24.
//

import Foundation
import Combine

class NetworkClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = TimeInterval(5)
        configuration.timeoutIntervalForResource =  TimeInterval(5)
        self.session = URLSession(configuration: configuration)
    }
    
    func fetchData<T: Decodable>(from url: URL, as type: T.Type) -> AnyPublisher<T, Error> {
        return session.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: type, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
