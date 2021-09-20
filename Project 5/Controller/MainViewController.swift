//
//  ViewController.swift
//  Project 5
//
//  Created by Kamil Pawlak on 21/07/2021.
//

import UIKit

class MainViewController: UITableViewController {

    var allWords = [String]()
    var usedWords = [String]()
    var score = 0
    var highScorePoints = [String]()
    var highScoreWords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
     
        loadData()
        updateBar()
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["KNOWINGS"]
        }
        
        let defaults = UserDefaults.standard
        highScorePoints = defaults.object(forKey:"HighScorePoints") as? [String] ?? [String]()
        highScoreWords = defaults.object(forKey: "HighScoreWords") as? [String] ?? [String]()
    }
    
    //MARK: - Table View Secton
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    //MARK: - Functions that check if the answer is proper
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter Answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else {return}
            self?.submit(answer)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        ac.addAction(submitAction)
        ac.addAction(cancelAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        
        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    usedWords.insert(lowerAnswer, at: 0)
                    
                    let defaults = UserDefaults.standard
                    defaults.set(usedWords, forKey: "UsedWords")
                    
                    //Reload only first row
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    
                    score = score + answer.count
                    defaults.set(score, forKey: "Score")
                    updateBar()
                    return
                    
                } else {
                    showErrorMessage(errorTitle: "Word not recognized or too short", errorMessage: "Don't make them up")
                }
            } else {
                showErrorMessage(errorTitle: "Word already exist", errorMessage: "Word is already in your table")
            }
        } else {
            showErrorMessage(errorTitle: "Incorrect Word", errorMessage: "Choose proper letters")
        }
    }
    
    func isPossible(word: String) -> Bool {
        guard var wordInTitle = title?.lowercased() else {return false}
        if wordInTitle != word {
        for letter in word {
            if let position = wordInTitle.firstIndex(of: letter) {
                wordInTitle.remove(at: position)
            } else {
                return false
            }
        }
        return true
        } else {
            showErrorMessage(errorTitle: "Incorrect Word", errorMessage: "You used starting word without any changes")
            return false
        }
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        if word.utf16.count > 2 {
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
        } else {
            return false
        }
    }
    
    //MARK: - Functions
    
    @objc func startGame() {
        
        if score > 2 {
            let defaults = UserDefaults.standard
            highScorePoints.append("\(score) points for the word: \(title ?? "No title")")
            defaults.set(highScorePoints, forKey: "HighScorePoints")
            
            // if score > 0 that means that usedWords.count > 0
            if usedWords.count == 1 {
                highScoreWords.append("\(usedWords.count) word in the word: \(title ?? "No title")") // singular for word
            } else {
                highScoreWords.append("\(usedWords.count) words in the word: \(title ?? "No title")") // plural for words
            }
            defaults.set(highScoreWords, forKey: "HighScoreWords")
        }
        
        if let uppercaseTitle = allWords.randomElement()?.uppercased() {
        title = uppercaseTitle
        }
        
        let defaults = UserDefaults.standard
        defaults.set(title, forKey: "Title")
        
        usedWords.removeAll(keepingCapacity: true)
        defaults.set(usedWords, forKey: "UsedWords")
        
        score = 0
        defaults.set(score, forKey: "Score")
        
        updateBar()
        tableView.reloadData()
    }
    
    func showErrorMessage(errorTitle: String, errorMessage: String) {
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "I will try again", style: .cancel)
        ac.addAction(cancelAction)
        present(ac, animated: true)
    }
    
    func updateBar() {
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let newGame = UIBarButtonItem(title: "New Game", style: .plain, target: self, action: #selector(startGame))
        let score = UIBarButtonItem(title: "Score:\(score)", style: .plain, target: self, action: #selector(scoreButtonPressed))
        let numberOfWords = UIBarButtonItem(title: "Words:\(usedWords.count)", style: .plain, target: self, action: #selector(wordsButtonPressed))
        
        toolbarItems = [newGame, spacer, score, spacer, numberOfWords]
        navigationController?.isToolbarHidden = false
    }
    
    func loadData() {
        let defaults = UserDefaults.standard
        title = defaults.string(forKey: "Title")
        usedWords = defaults.object(forKey: "UsedWords") as? [String] ?? [String]()
        score = defaults.integer(forKey: "Score")
    }
    
    //MARK: - Segue section
    
    @objc func scoreButtonPressed() {
        self.performSegue(withIdentifier: "goToHighScore", sender: self)
    }
    
    @objc func wordsButtonPressed() {
        self.performSegue(withIdentifier: "goToWordsHighResult", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToHighScore" {
            let destinationVC = segue.destination as! HighScoreViewController
            destinationVC.highScoreArray = highScorePoints
            if score > 2  {
                destinationVC.highScoreArray.append("\(score) points - CURRENT SCORE")
            }
        }
        if segue.identifier == "goToWordsHighResult" {
            let destinationVC = segue.destination as! WordsHighResultViewController
            destinationVC.wordsHighResultArray = highScoreWords
            if usedWords.count == 1 {
                destinationVC.wordsHighResultArray.append("\(usedWords.count) word - CURRENT SCORE") // singular
            }
            if usedWords.count > 1 {
                destinationVC.wordsHighResultArray.append("\(usedWords.count) words - CURRENT SCORE") // plural
            }
        }
    }
}



