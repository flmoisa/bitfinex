//
//  ViewController.swift
//  BitfinexOrderBook
//
//  Created by Florin Moisa on 24/09/2020.
//

import UIKit
import RxCocoa
import RxSwift

class ViewController: UIViewController {
    
    @IBOutlet weak var buysTableView: UITableView!
    @IBOutlet weak var sellsTableView: UITableView!
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var lastLabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var volumeLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var changeLabel: UILabel!
    
    private var disposeBag = DisposeBag()
    
    private let tickerObservable = WebSocketService.shared.tickerObservable()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
//        tickerObservable.map { (ticker) -> String in
//            if let ticker = ticker {
//                return ticker.lastPrice.priceFormat
//            }
//            return ""
//        }.bind(to: self.lastLabel.rx.text)
        
        
        
        
        tickerObservable.bind { [unowned self] (ticker) in
            if let ticker = ticker {
                self.lowLabel.text = ticker.low.priceFormat
                self.lastLabel.text = ticker.lastPrice.priceFormat
                self.highLabel.text = ticker.high.priceFormat
                self.volumeLabel.text = ticker.volume.volumeFormat
                self.changeLabel.text = (ticker.dailyChangeRelative).percentFormat
            }
        }.disposed(by: disposeBag)
    }
    
}

