//
//  NetworkReachability.swift
//
//  Created by Alliston Aleixo on 18/05/22.
//

import Alamofire
import Foundation

#if os(iOS)
    public protocol NetworkReachabilityDelegate: AnyObject {
        func showOfflineAlert()
        func dismissOfflineAlert()
    }

    public class NetworkReachability {

        // MARK: Public

        public static let shared = NetworkReachability()

        public var delegate: NetworkReachabilityDelegate?

        public func startNetworkMonitoring() {
            reachabilityManager?.startListening { status in
                switch status {
                case .notReachable:
                    self.delegate?.showOfflineAlert()
                case .reachable(.cellular):
                    self.delegate?.dismissOfflineAlert()
                case .reachable(.ethernetOrWiFi):
                    self.delegate?.dismissOfflineAlert()
                case .unknown:
                    print("Unknown network state")
                }
            }
        }

        // MARK: Internal

        let reachabilityManager = NetworkReachabilityManager(host: "www.google.com")

    }
#endif
