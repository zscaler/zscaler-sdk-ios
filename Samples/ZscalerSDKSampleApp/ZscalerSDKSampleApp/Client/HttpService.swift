import Foundation
import Network

public class HttpService {
    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    public func executeRequest(method: HttpMethodType, url: URL) async throws -> BrowserResponse {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode)
        else {
            throw URLError(.badServerResponse)
        }

        return BrowserResponse(data: data, response: httpResponse)
    }
}
