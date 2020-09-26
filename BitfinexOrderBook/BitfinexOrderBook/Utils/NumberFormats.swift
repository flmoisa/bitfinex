//
//  NumberFormats.swift
//  BitfinexOrderBook
//
//  Created by Florin Moisa on 26/09/2020.
//

import Foundation

extension Float {
    
    var priceFormat: String {
        get {
            let formatter = NumberFormatter()
            formatter.currencySymbol = "$"
            formatter.numberStyle = .currency
            formatter.minimumFractionDigits = 1
            formatter.maximumFractionDigits = 1
            return formatter.string(from: self as NSNumber) ?? ""
        }
    }
    
    var percentFormat: String {
        get {
            let formatter = NumberFormatter()
            formatter.numberStyle = .percent
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
            formatter.positivePrefix = "\u{2191}"  //formatter.plusSign
            formatter.negativePrefix = "\u{2193}"  //formatter.minusSign
            return formatter.string(from: self as NSNumber) ?? ""
        }
    }
    
    var volumeFormat: String {
        get {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 3
            formatter.maximumFractionDigits = 3
            return formatter.string(from: self as NSNumber) ?? ""
        }
    }
}
