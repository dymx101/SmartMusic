enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case serverError(String)
    case noData
}

//extension NetworkError: LocalizedError {
//    var errorDescription: String? {
//        switch self {
//        case .invalidURL:
//            return "无效的 URL"
//        case .invalidResponse:
//            return "服务器响应无效"
//        case .decodingError:
//            return "数据解析错误"
//        case .serverError(let message):
//            return "服务器错误: \(message)"
//        case .noData:
//            return "没有数据"
//        }
//    }
//} 
