import Foundation
import Network

public final class HttpRequestService {
    weak var delegate: HttpRequestServiceDelegate?

    private var tunnelService: TunnelService

    init(tunnelService: TunnelService) {
        self.tunnelService = tunnelService
    }

    public func executeRequest(method: HttpMethodType, url: URL) {
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        _ = tunnelService.setup(sessionConfiguration: sessionConfiguration)
        let session = URLSession(configuration: sessionConfiguration)
        self.delegate?.contentIsLoading()

        Task {
            do {
                let response = try await request(session: session, method: method, url: url)
                DispatchQueue.main.async {
                    self.delegate?.contentIsLoaded(response.data, response.response)
                }
            } catch {
                DispatchQueue.main.async {
                    self.delegate?.contentLoadError(error: error)
                }
            }
        }
    }
    
    func request(session: URLSession, method: HttpMethodType, url: URL) async throws -> (data: Data, response: HTTPURLResponse) {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode)
        else {
            throw URLError(.badServerResponse)
        }

        return (data, httpResponse)
    }
}
