import Foundation

struct NetworkClient {

    private enum NetworkError: Error {
        case codeError
    }
    
    private enum Constants {
        static let successStatusCodeMin = 200
        static let successStatusCodeMax = 300
    }
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                handler(.failure(error))
                return
            }
            
            if let response = response as? HTTPURLResponse,
               response.statusCode < Constants.successStatusCodeMin ||
               response.statusCode >= Constants.successStatusCodeMax {
                handler(.failure(NetworkError.codeError))
                return
            }
            
            guard let data = data else { return }
            handler(.success(data))
        }
        
        task.resume()
    }
}
