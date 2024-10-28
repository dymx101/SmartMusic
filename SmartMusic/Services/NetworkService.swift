import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case serverError(String)
}

class NetworkService {
    static let shared = NetworkService()
    private let baseURL = "http://35.188.0.156:8000/api"
    private let logger = LogService.shared
    
    private init() {}
    
    func fetch<T: Decodable>(_ endpoint: String) async throws -> T {
        logger.info("Fetching data from endpoint: \(endpoint)")
        
        guard let url = URL(string: baseURL + endpoint) else {
            logger.error("Invalid URL: \(baseURL + endpoint)")
            throw NetworkError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("Invalid response type")
                throw NetworkError.invalidResponse
            }
            
            logger.debug("Response status code: \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode) else {
                logger.error("Invalid response status: \(httpResponse.statusCode)")
                throw NetworkError.invalidResponse
            }
            
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(T.self, from: data)
                logger.info("Successfully decoded response")
                return result
            } catch {
                logger.error("Decoding error: \(error.localizedDescription)")
                throw NetworkError.decodingError
            }
        } catch {
            logger.error("Network error: \(error.localizedDescription)")
            throw NetworkError.serverError(error.localizedDescription)
        }
    }
}
