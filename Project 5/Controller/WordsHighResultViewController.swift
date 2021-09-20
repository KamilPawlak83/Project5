//
//  WordsHighResultViewController.swift
//  Project 5
//
//  Created by Kamil Pawlak on 16/09/2021.
//

import UIKit

class WordsHighResultViewController: UITableViewController {
    
    var wordsHighResultArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordsHighResultArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Words", for: indexPath)
        let sortedWordsHighResultArray = wordsHighResultArray.sorted { (lhs: String, rhs: String) -> Bool in
            return lhs.localizedStandardCompare(rhs) == .orderedDescending  // the highest result is on he top
        }
        cell.textLabel?.text = sortedWordsHighResultArray[indexPath.row]
        return cell
    }

}
