//
//  BookStoreViewModel.swift
//  BitfinexOrderBook
//
//  Created by Florin Moisa on 27/09/2020.
//

import Foundation
import RxRelay
import RxSwift

class BookStoreViewModel  {
    
    private var bookStore = BookStore()
    
    let tickerObservable = WebSocketService.shared.tickerObservable()
    let bookLineObservable = WebSocketService.shared.bookLineObservable()
    
    var bidsObservable: Observable<[BookLine]> {
        get {
            return bookLineObservable.filter { (bookLine) -> Bool in
                return bookLine?.isBid == true
            }.map { [weak self] (bookLine) -> [BookLine] in
                if let bookLine = bookLine {
                    self?.bookStore.processNewLine(line: bookLine)
                    return self?.bookStore.sortedBids ?? []
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
                    self?.bookStore.processNewLine(line: bookLine)
                    return self?.bookStore.sortedAsks ?? []
                }
                return []
            }
        }
    }
}
