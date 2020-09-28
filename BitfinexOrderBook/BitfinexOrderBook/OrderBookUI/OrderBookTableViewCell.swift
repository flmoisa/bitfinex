//
//  OrderBookTableViewCell.swift
//  BitfinexOrderBook
//
//  Created by Florin Moisa on 27/09/2020.
//

import UIKit

class OrderBookTableViewCell: UITableViewCell {

    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureWithModel(bookLine: BookLine) {
        priceLabel.text = bookLine.price.priceFormat
        amountLabel.text = bookLine.amount.amountFormat
    }
    
}
