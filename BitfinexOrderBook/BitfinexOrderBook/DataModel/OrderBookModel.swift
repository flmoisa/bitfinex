//
//  BookStore.swift
//  BitfinexOrderBook
//
//  Created by Florin Moisa on 27/09/2020.
//

import Foundation

struct BookLine {
    let price: Float
    let count: Int
    let amount: Float
}

class OrderBook {
    
    var bids = [Float:BookLine]()
    var asks = [Float:BookLine]()
    
    func processNewLine(line: BookLine) {
        if line.count == 0 {
            if line.amount == 1 {
                bids.removeValue(forKey: line.price)
            }
            if line.amount == -1 {
                asks.removeValue(forKey: line.price)
            }
        }
        if line.count > 0 {
            if line.isBid == true {
                bids[line.price] = line
            }
            if line.isAsk == true {
                asks[line.price] = line
            }
        }
    }
    
    var sortedBids: [BookLine] {
        get {
            return bids.values.sorted { (line1, line2) -> Bool in
                return line1.price > line2.price
            }
        }
    }
    
    var sortedAsks: [BookLine] {
        get {
            return asks.values.sorted { (line1, line2) -> Bool in
                return line1.price < line2.price
            }
        }
    }
}

extension BookLine {
    var isBid: Bool {
        return self.amount > 0
    }
    var isAsk: Bool {
        return self.amount < 0
    }
}
