//
//  TickerModel.swift
//  BitfinexOrderBook
//
//  Created by Florin Moisa on 25/09/2020.
//

import Foundation

struct Ticker {
    let bid: Float
    let bidSize: Float
    let ask: Float
    let askSize: Float
    let dailyChange: Float
    let dailyChangeRelative: Float
    let lastPrice: Float
    let volume: Float
    let high: Float
    let low: Float
}
