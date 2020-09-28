//
//  ViewController.swift
//  BitfinexOrderBook
//
//  Created by Florin Moisa on 24/09/2020.
//

import UIKit
import RxCocoa
import RxSwift

class OrderBookViewController: UIViewController {
    
    @IBOutlet weak var buysTableView: UITableView!
    @IBOutlet weak var sellsTableView: UITableView!
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var lastLabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var volumeLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var changeLabel: UILabel!
    
    private var disposeBag = DisposeBag()
    
    private var bookStoreModel = OrderBookViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView(tableView: buysTableView)
        configureTableView(tableView: sellsTableView)
        
        bookStoreModel.tickerObservable.bind { [unowned self] (ticker) in
            if let ticker = ticker {
                self.lowLabel.text = ticker.low.priceFormat
                self.lastLabel.text = ticker.lastPrice.priceFormat
                self.highLabel.text = ticker.high.priceFormat
                self.volumeLabel.text = ticker.volume.volumeFormat
                self.changeLabel.text = (ticker.dailyChangeRelative).percentFormat
                self.changeLabel.textColor = ticker.dailyChangeRelative > 0 ? UIColor.systemGreen : UIColor.systemRed
            }
        }.disposed(by: disposeBag)
        
        bookStoreModel.bidsObservable.bind(to: buysTableView.rx.items(cellIdentifier: "OrderBookTableViewCell", cellType: OrderBookTableViewCell.self)){ tableView, bookLine, cell in
            cell.configureWithModel(bookLine: bookLine)
        }
        .disposed(by: disposeBag)
        
        bookStoreModel.asksObservable.bind(to: sellsTableView.rx.items(cellIdentifier: "OrderBookTableViewCell", cellType: OrderBookTableViewCell.self)){ tableView, bookLine, cell in
            cell.configureWithModel(bookLine: bookLine)
        }
        .disposed(by: disposeBag)
    }
    
    private func configureTableView(tableView: UITableView) {
        tableView.register(UINib(nibName: "OrderBookTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "OrderBookTableViewCell")
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.rowHeight = 32
    }
}

extension OrderBookViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard buysTableView.numberOfRows(inSection: 0) == sellsTableView.numberOfRows(inSection: 0) else { return }
        
        switch scrollView {
        case sellsTableView:
            buysTableView.contentOffset = scrollView.contentOffset
        case buysTableView:
            sellsTableView.contentOffset = scrollView.contentOffset
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UINib(nibName: "OrderBookHeaderView", bundle: Bundle.main).instantiate(withOwner: tableView, options: nil).first as? UIView
    }
}

