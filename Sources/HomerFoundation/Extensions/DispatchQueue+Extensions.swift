import Foundation

public extension DispatchQueue {
    private nonisolated(unsafe) static let mainQueueMarker: DispatchSpecificKey<Void> = {
        let key = DispatchSpecificKey<Void>()
        DispatchQueue.main.setSpecific(key: key, value: ())
        return key
    }()

    static var isMainQueue: Bool {
        getSpecific(key: mainQueueMarker) != nil
    }
}
