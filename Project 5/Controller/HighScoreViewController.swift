//
//  HighScoreViewController.swift
//  Project 5
//
//  Created by Kamil Pawlak on 16/09/2021.
//

import UIKit

class HighScoreViewController: UITableViewController {
    
    var highScoreArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return highScoreArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Score", for: indexPath)
        let sortedHighScoreArray = highScoreArray.sorted { (lhs: String, rhs: String) -> Bool in
            return lhs.localizedStandardCompare(rhs) == .orderedDescending // the highest result is on he top
        }
        cell.textLabel?.text = sortedHighScoreArray[indexPath.row]
        return cell
    }
}
