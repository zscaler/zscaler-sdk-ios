import Foundation

public struct ZscalerLogModel {
    private var url: URL?

    init(url: URL? = nil) {
        self.url = url
    }

    public func exportURL() -> URL? {
        url
    }
}
