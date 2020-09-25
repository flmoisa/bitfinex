//
//  ViewController.swift
//  BitfinexOrderBook
//
//  Created by Florin Moisa on 24/09/2020.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var buysTableView: UITableView!
    @IBOutlet weak var sellsTableView: UITableView!
    
    var wsService = WebSocketService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

