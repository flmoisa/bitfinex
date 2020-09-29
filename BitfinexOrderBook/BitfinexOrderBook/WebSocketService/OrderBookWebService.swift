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
        
        let decoded = ResponseDecoder.decodeMessage(message: message, tickerChannelId: tickerChannelId, bookChannelId: bookChannelId)
        
        switch decoded {
        case .tickerResponse(let tickerResponse):
            tickerChannelId = Int(tickerResponse.chanID)
        case .bookResponse(let bookResponse):
            bookChannelId = Int(bookResponse.chanID)
        case .tickerUpdate(let ticker):
            tickerRelay.accept(ticker)
        case .bookUpdate(let bookLine):
            bookLineRelay.accept(bookLine)
        case .bookSnapshot(let bookLines):
            bookLines.forEach { (bookLine) in
                bookLineRelay.accept(bookLine)
            }
            isLoadingRelay.accept(false)
        case .none:
            break // unknown message, ignore
        }   
    }
}
