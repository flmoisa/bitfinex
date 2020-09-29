//
//  OrderBookResponse.swift
//  BitfinexOrderBook
//
//  Created by Florin Moisa on 29/09/2020.
//

import Foundation
import SwiftyJSON

class ResponseDecoder {
    
    enum ResponseType {
        case tickerResponse(_ ticker: TickerResponse)
        case bookResponse(_ book: BookResponse)
        case tickerUpdate(_ ticker: Ticker)
        case bookUpdate(_ bookLine: BookLine)
        case bookSnapshot(_ book: [BookLine])
    }
    
    static func decodeMessage(message: String, tickerChannelId: Int? = nil, bookChannelId: Int? = nil) -> ResponseType? {
        
        do {
            let tickerResponse = try TickerResponse(jsonString: message)
            if tickerResponse.channel == "ticker" && tickerResponse.event == "subscribed" {
                print("Ticker response: \(tickerResponse)")
                return .tickerResponse(tickerResponse)
            }
        } catch {
        }
        
        do {
            let bookResponse = try BookResponse(jsonString: message)
            if bookResponse.channel == "book" && bookResponse.event == "subscribed" {
                print("Book response: \(bookResponse)")
                return .bookResponse(bookResponse)
            }
        } catch {
        }
        
        let json = JSON(parseJSON: message)
        
        if json.type == .array, json.count == 2 {
            
            if let tickerChannelId = tickerChannelId, json[0].intValue == tickerChannelId {
                
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
                    print("Ticker: \(ticker)")
                    return .tickerUpdate(ticker)
                }
            }
            
            if json[0].intValue == bookChannelId {
                
                // order book message
                
                let values = json[1]
                if values.type == .array, values.count > 0 {
                    
                    if values[0].type == .array {
                        
                        // Book snapshot
                        
                        let lines = values.arrayValue
                        let book = lines.map { (jsonLine) -> BookLine in
                            return BookLine(
                                price: jsonLine[0].floatValue,
                                count: jsonLine[1].intValue,
                                amount: jsonLine[2].floatValue)
                        }
                        
                        return .bookSnapshot(book)
                                                
                    } else {
                        
                        // Book line
                        
                        let bookLine = BookLine(
                            price: values[0].floatValue,
                            count: values[1].intValue,
                            amount: values[2].floatValue)
                        
                        return .bookUpdate(bookLine)
                    }
                }
            }
        }
        
        return nil
    }
}
