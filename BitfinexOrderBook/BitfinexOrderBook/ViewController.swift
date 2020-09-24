//
//  ViewController.swift
//  BitfinexOrderBook
//
//  Created by Florin Moisa on 24/09/2020.
//

import UIKit
import Starscream

class ViewController: UIViewController {
    
    private var socket: WebSocket?
    private var isConnected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var request = URLRequest(url: URL(string: "wss://api-pub.bitfinex.com/ws/2")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket?.connect()
        socket?.onEvent = { [unowned self] event in
            switch event {
            case .connected(let headers):
                self.isConnected = true
                print("websocket is connected: \(headers)")
            case .disconnected(let reason, let code):
                self.isConnected = false
                print("websocket is disconnected: \(reason) with code: \(code)")
            case .text(let string):
                print("Received text: \(string)")
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
            }
        }
    }
    
    
    
}

