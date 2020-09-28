//
//  OrderBookWebService.swift
//  BitfinexOrderBook
//
//  Created by Florin Moisa on 28/09/2020.
//

import Foundation
import RxSwift
import RxRelay
import SwiftyJSON

let WS_END_POINT = "wss://api-pub.bitfinex.com/ws/2"

class OrderBookWebService {
    
    static private(set) var shared = OrderBookWebService()
    
    private var webSocketHandler: WebSocketHandler?
    
    private var bookChannelId: Int?
    private var tickerChannelId: Int?
    
    private(set) var tickerRelay = BehaviorRelay<Ticker?>(value: nil)
    private(set) var bookLineRelay = BehaviorRelay<BookLine?>(value: nil)
    private(set) var isLoadingRelay = BehaviorRelay<Bool>(value: true)
    
    init() {
        webSocketHandler = WebSocketHandler(
            endPoint: WS_END_POINT,
            onConnected: { [unowned self] in
                self.getBooks()
                self.getTicker()
            },
            onMessage: { [unowned self] (message) in
                self.decodeMessage(message: message)
            },
            onError: { (error) in
                // handle error
            })
    }
    
    private func getBooks() {
        var bookREQ = BookRequest.init()
        bookREQ.event = "subscribe"
        bookREQ.channel = "book"
        bookREQ.symbol = "BTCUSD"
        if let json = try? bookREQ.jsonString(){
            webSocketHandler?.sendMessage(json)
        }
    }
    
    private func getTicker() {
        var tickerREQ = TickerRequest()
        tickerREQ.event = "subscribe"
        tickerREQ.channel = "ticker"
        tickerREQ.symbol = "BTCUSD"
        if let json = try? tickerREQ.jsonString(){
            webSocketHandler?.sendMessage(json)
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
                
                // ticker message
                
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
                    tickerRelay.accept(ticker)
                    print("Ticker: \(ticker)")
                    return
                }
            }
            
            if json[0].intValue == bookChannelId {
                
                // order book message
                
                let values = json[1]
                if values.type == .array, values.count > 0 {
                    
                    if values[0].type == .array {
                        
                        // Book snapshot
                        
                        let lines = values.arrayValue
                        lines.forEach { jsonLine in
                            let bookLine = BookLine(
                                price: jsonLine[0].floatValue,
                                count: jsonLine[1].intValue,
                                amount: jsonLine[2].floatValue)
                            bookLineRelay.accept(bookLine)
                        }
                        
                        isLoadingRelay.accept(false)
                        
                    } else {
                        
                        // Book line
                        
                        let bookLine = BookLine(
                            price: values[0].floatValue,
                            count: values[1].intValue,
                            amount: values[2].floatValue)
                        
                        bookLineRelay.accept(bookLine)
                        
                        return
                    }
                    
                }
                
            }
        }
    }
}
