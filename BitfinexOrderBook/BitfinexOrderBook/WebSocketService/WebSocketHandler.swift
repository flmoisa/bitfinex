//
//  WebSocketService.swift
//  BitfinexOrderBook
//
//  Created by Florin Moisa on 25/09/2020.
//

import Foundation
import Starscream
import RxRelay
import Reachability

class WebSocketHandler {
    
    private var socket: WebSocket?
    private var reachability: Reachability?
    
    private var onConnected: () -> ()
    private var onMessage: (String) -> ()
    private var onError: (Error) -> ()
    
    private(set) var isConnectedRelay = BehaviorRelay<Bool>(value: false)
    
    init(endPoint: String, onConnected: @escaping () -> (), onMessage: @escaping (String) -> (), onError: @escaping (Error) -> ()) {
        
        self.onConnected = onConnected
        self.onMessage = onMessage
        self.onError = onError
        
        var request = URLRequest(url: URL(string: endPoint)!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        
        socket?.onEvent = { [unowned self] event in
            switch event {
            case .connected(let headers):
                self.isConnectedRelay.accept(true)
                print("websocket is connected: \(headers)")
                self.onConnected()
                
            case .disconnected(let reason, let code):
                self.isConnectedRelay.accept(false)
                print("websocket is disconnected: \(reason) with code: \(code)")
                
            case .text(let string):
                print("Received text: \(string)")
                self.onMessage(string)
                
            case .binary(let data):
                print("Received data: \(data.count)")
            case .ping(_):
                break
            case .pong(_):
                break
            case .viabilityChanged(_):
                break
            case .reconnectSuggested(_):
                break
            case .cancelled:
                self.isConnectedRelay.accept(false)
            case .error(let error):
                self.isConnectedRelay.accept(false)
                print("Received error: \(error.debugDescription)")
                if let error = error {
                    self.onError(error)
                }
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(startService), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopService), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    func sendMessage(_ message: String) {
        self.socket?.write(string: message)
    }
    
    @objc func startService() {
        
        reachability = try? Reachability()
        reachability?.whenReachable = { [weak self] reachability in
            self?.reachabilityChanged(isReachable: true)
        }
        
        reachability?.whenUnreachable = { [weak self] reachability in
            self?.reachabilityChanged(isReachable: false)
        }
        
        try? reachability?.startNotifier()
        
    }
    @objc func stopService() {
        
        reachability?.stopNotifier()
    }
    
    func reachabilityChanged(isReachable: Bool) {
        isReachable == true ? socket?.connect() : socket?.disconnect()
    }
}
