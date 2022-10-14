//
//  UITableViewController+deselectRow.swift
//  
//
//  Created by Moritz Schaub on 13.10.22.
//

import UIKit

public extension UITableViewController {
    func deselectRow() {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
