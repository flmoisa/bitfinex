//
//  BookStoreViewModel.swift
//  BitfinexOrderBook
//
//  Created by Florin Moisa on 27/09/2020.
//

import Foundation
import RxRelay
import RxSwift

class OrderBookViewModel  {
    
    private var orderBook = OrderBook()
    
    let tickerObservable = OrderBookWebService.shared.tickerObservable()
    let bookLineObservable = OrderBookWebService.shared.bookLineObservable()
    
    var bidsObservable: Observable<[BookLine]> {
        get {
            return bookLineObservable.filter { (bookLine) -> Bool in
                return bookLine?.isBid == true
            }.map { [weak self] (bookLine) -> [BookLine] in
                if let bookLine = bookLine {
                    self?.orderBook.processNewLine(line: bookLine)
                    return self?.orderBook.sortedBids ?? []
                }
                return []
            }
        }
    }
    
    var asksObservable: Observable<[BookLine]> {
        get {
            return bookLineObservable.filter { (bookLine) -> Bool in
                return bookLine?.isAsk == true
            }.map { [weak self] (bookLine) -> [BookLine] in
                if let bookLine = bookLine {
                    self?.orderBook.processNewLine(line: bookLine)
                    return self?.orderBook.sortedAsks ?? []
                }
                return []
            }
        }
    }
}
