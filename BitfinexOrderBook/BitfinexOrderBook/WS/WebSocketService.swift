//
//  WebSocketService.swift
//  BitfinexOrderBook
//
//  Created by Florin Moisa on 25/09/2020.
//

import Foundation
import Starscream
import SwiftyJSON

class WebSocketService {
    
    private var socket: WebSocket?
    private var isConnected = false
    
    private var bookChannelId: Int?
    private var tickerChannelId: Int?
    
    init() {
        
        var request = URLRequest(url: URL(string: "wss://api-pub.bitfinex.com/ws/2")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket?.connect()
        
        socket?.onEvent = { [unowned self] event in
            switch event {
            case .connected(let headers):
                self.isConnected = true
                print("websocket is connected: \(headers)")
                
                // send messages on WS to get data
                self.getTicker()
                self.getBooks()
                
            case .disconnected(let reason, let code):
                self.isConnected = false
                print("websocket is disconnected: \(reason) with code: \(code)")
                
            case .text(let string):
                print("Received text: \(string)")
                
                // process the message received on WS
                self.decodeMessage(message: string)
                
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
    
    private func getBooks() {
        var bookREQ = BookRequest.init()
        bookREQ.event = "subscribe"
        bookREQ.channel = "book"
        bookREQ.symbol = "BTCUSD"
        if let json = try? bookREQ.jsonString(){
            self.socket?.write(string: json)
        }
    }
    
    private func getTicker() {
        var tickerREQ = TickerRequest()
        tickerREQ.event = "subscribe"
        tickerREQ.channel = "ticker"
        tickerREQ.symbol = "BTCUSD"
        if let json = try? tickerREQ.jsonString(){
            self.socket?.write(string: json)
        }
    }
    
    private func decodeMessage(message: String) {
        
        do {
            let tickerResponse = try TickerResponse(jsonString: message)
            if tickerResponse.channel == "ticker" && tickerResponse.event == "subscribed" {
                tickerChannelId = Int(tickerResponse.chanID)
                print("Ticker response: \(tickerResponse)")
                return
            }
        } catch {
        }
        
        do {
            let bookResponse = try BookResponse(jsonString: message)
            if bookResponse.channel == "book" && bookResponse.event == "subscribed" {
                bookChannelId = Int(bookResponse.chanID)
                print("Book response: \(bookResponse)")
                return
            }
        } catch {
        }
        
        let json = JSON(parseJSON: message)
        
        if json.type == .array, json.count == 2 {
            
            if json[0].intValue == tickerChannelId {
                let values = json[1]
                if values.type == .array, values.count == 10 {
                    let ticker = Ticker(
                        bid: values[0].floatValue,
                        bidSize: values[1].floatValue,
                        ask: values[2].floatValue,
                        askSize: values[3].floatValue,
                        dailyChange: values[4].floatValue,
                        dailyChangeRelative: values[5].floatValue,
                        lastPrice: values[6].floatValue,
                        volume: values[7].floatValue,
                        high: values[8].floatValue,
                        low: values[9].floatValue)
                    print("Ticker: \(ticker)")
                    return
                }
            }
            
            if json[0].intValue == bookChannelId {
                
                let values = json[1]
                if values.type == .array, values.count > 0 {
                    
                    if values[0].type == .array {
                        print("Book snapshot")
                    } else {
                        
                        let bookLine = BookLine(
                            price: values[0].floatValue,
                            count: values[1].intValue,
                            amount: values[2].floatValue)
                        
                        print("Book line: \(bookLine)")
                        return
                    }
                    
                }
                
            }
        }
    }
}
