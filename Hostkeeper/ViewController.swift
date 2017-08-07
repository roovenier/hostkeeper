//
//  ViewController.swift
//  Hostkeeper
//
//  Created by alexander.oschepkov on 07.08.17.
//  Copyright © 2017 alexander.oschepkov. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet weak var tableView: NSTableView!
    
    let tableViewData = [["project":"NPF","terminal":"Doe"],["project":"Merkator","terminal":"Doe"]]

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if tableColumn!.identifier == "terminal" {
            return tableView.make(withIdentifier: "terminal", owner: self) as! NSButton
        } else {
            let result = tableView.make(withIdentifier:(tableColumn?.identifier)!, owner: self) as! NSTableCellView
            result.textField?.stringValue = tableViewData[row][(tableColumn?.identifier)!]!
            return result
        }
    }
}
