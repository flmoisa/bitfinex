//
//  DecoderTest.swift
//  BitfinexOrderBookTests
//
//  Created by Florin Moisa on 29/09/2020.
//

import XCTest
@testable import BitfinexOrderBook

class DecoderTests: XCTestCase {
    
    let tickerChannelID = 310312
    let bookChannelID = 268083
    
    func testTickerUpdate() {
        let tickerSample = "[310312,[10757,93.67272865,10759,108.80100329,-140.40820401,-0.0129,10758.481944,2808.92076039,10961,10656.20638633]]"
        let response = ResponseDecoder.decodeMessage(message: tickerSample, tickerChannelId: tickerChannelID)
        XCTAssertNotNil(response)
        if case .tickerUpdate(let ticker) = response {
            XCTAssertEqual(ticker.bid, 10757)
            XCTAssertEqual(ticker.bidSize, 93.67272865)
            XCTAssertEqual(ticker.ask, 10759)
            XCTAssertEqual(ticker.askSize, 108.80100329)
            XCTAssertEqual(ticker.dailyChange, -140.40820401)
            XCTAssertEqual(ticker.dailyChangeRelative, -0.0129)
            XCTAssertEqual(ticker.lastPrice, 10758.481944)
            XCTAssertEqual(ticker.volume, 2808.92076039)
            XCTAssertEqual(ticker.high, 10961)
            XCTAssertEqual(ticker.low, 10656.20638633)
        } else {
            XCTFail("Ticker was expected")
        }
    }
    
    func testTickerWrongChannelID() {
        let tickerSample = "[-1,[10757,93.67272865,10759,108.80100329,-140.40820401,-0.0129,10758.481944,2808.92076039,10961,10656.20638633]]"
        let ticker = ResponseDecoder.decodeMessage(message: tickerSample, tickerChannelId: tickerChannelID)
        XCTAssertNil(ticker)
    }
    
    func testTickerSmallerFieldsCount() {
        let tickerSample = "[310312,[10757,93.67272865,10759,108.80100329,-140.40820401,-0.0129,10758.481944,2808.92076039,10961]]"
        let ticker = ResponseDecoder.decodeMessage(message: tickerSample, tickerChannelId: tickerChannelID)
        XCTAssertNil(ticker)
    }
    
    func testTickerLargerFieldsCount() {
        let tickerSample = "[310312,[10757,93.67272865,10759,108.80100329,-140.40820401,-0.0129,10758.481944,2808.92076039,10961,10656.20638633, 124234]]"
        let ticker = ResponseDecoder.decodeMessage(message: tickerSample, tickerChannelId: tickerChannelID)
        XCTAssertNil(ticker)
    }
    
    func testDecoderEmptyMessage() {
        let tickerSample = ""
        let response = ResponseDecoder.decodeMessage(message: tickerSample, tickerChannelId: tickerChannelID)
        XCTAssertNil(response)
    }
    
    func testDecoderRandomString() {
        let tickerSample = " aslkgjhq pkfa psdfy2349y139 f%$#@^%V&B *^%$^#@^ *R(&* )"
        let response = ResponseDecoder.decodeMessage(message: tickerSample, tickerChannelId: tickerChannelID)
        XCTAssertNil(response)
    }
    
    func testOrderBookSnapshot() {
        let sample = "[268083,[[10757,12,7.14177423],[10756,2,0.86234125],[10755,4,3.9341107]]]"
        let response = ResponseDecoder.decodeMessage(message: sample, bookChannelId: bookChannelID)
        XCTAssertNotNil(response)
        if case .bookSnapshot(let book) = response {
            XCTAssertEqual(book[0].price, 10757)
            XCTAssertEqual(book[0].count, 12)
            XCTAssertEqual(book[0].amount, 7.14177423)
            XCTAssertEqual(book[1].price, 10756)
            XCTAssertEqual(book[1].count, 2)
            XCTAssertEqual(book[1].amount, 0.86234125)
            XCTAssertEqual(book[2].price, 10755)
            XCTAssertEqual(book[2].count, 4)
            XCTAssertEqual(book[2].amount, 3.9341107)
        } else {
            XCTFail("Book snapshot was expected")
        }
    }
    
    func testBookSnapshotWrongChannelId() {
        let sample = "[-1,[[10757,12,7.14177423],[10756,2,0.86234125],[10755,4,3.9341107]]]"
        let response = ResponseDecoder.decodeMessage(message: sample, bookChannelId: bookChannelID)
        XCTAssertNil(response)
    }
    
    func testBookUpdate() {
        let sample = "[268083,[10757,12,7.14177423]]"
        let response = ResponseDecoder.decodeMessage(message: sample, bookChannelId: bookChannelID)
        XCTAssertNotNil(response)
        if case .bookUpdate(let book) = response {
            XCTAssertEqual(book.price, 10757)
            XCTAssertEqual(book.count, 12)
            XCTAssertEqual(book.amount, 7.14177423)
        } else {
            XCTFail("Book update was expected")
        }
    }
    
    func testBookUpdateWrongChannelId() {
        let sample = "[-1,[10757,12,7.14177423]]"
        let response = ResponseDecoder.decodeMessage(message: sample, bookChannelId: bookChannelID)
        XCTAssertNil(response)
    }

}
