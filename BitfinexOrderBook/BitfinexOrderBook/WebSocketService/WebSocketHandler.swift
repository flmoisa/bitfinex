//
//  WebSocketService.swift
//  BitfinexOrderBook
//
//  Created by Florin Moisa on 25/09/2020.
//

import Foundation
import Starscream

class WebSocketHandler {
    
    private var socket: WebSocket?
    private var isConnected = false
    
    private var onConnected: () -> ()
    private var onMessage: (String) -> ()
    private var onError: (Error) -> ()
    
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
                self.isConnected = true
                print("websocket is connected: \(headers)")
                self.onConnected()
                
            case .disconnected(let reason, let code):
                self.isConnected = false
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
                self.isConnected = false
            case .error(let error):
                self.isConnected = false
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
        socket?.connect()
    }
    @objc func stopService() {
        socket?.disconnect()
    }
}
