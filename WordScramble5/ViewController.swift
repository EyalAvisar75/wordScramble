//
//  ViewController.swift
//  WordScramble5
//
//  Created by eyal avisar on 20/07/2020.
//  Copyright © 2020 eyal avisar. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    var allWords = [String]()
    var usedWords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(startGame))
        if let wordsURL = Bundle.main.url(forResource: "words", withExtension: "rtf") {
            if let words = try? String(contentsOf: wordsURL) {
                allWords = words.components(separatedBy: [" ", "\n"])
            }
            else {
                allWords = ["silkworm"]
            }
        }
        
        startGame()
    }


   @objc func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        
        ac.addTextField()
        let submitAction = UIAlertAction(title: "Submit", style: .default){
            [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else {return}
            self?.submit(answer)
        }
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer:String) {
        let lowerAnswer = answer.lowercased()
        
        let errorTitle:String
        let errorMessage:String
        
        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    guard lowerAnswer.count > 3 else {
                        print("answer should have at least 4 letters")
                        return
                    }
                    usedWords.insert(lowerAnswer, at: 0)
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    
                    return
                }
                else {
                    errorTitle = "Word not recognized"
                    errorMessage = "You can't just make them up, you know..."
                }
                
            }
            else {
                errorTitle = "Word already used"
                errorMessage = "Be more original!"
            }
        }
        else {
            errorTitle = "Word not possible"
            errorMessage = "You can't derive that word from \(title!.lowercased())."
        }
        
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func isPossible(word:String) -> Bool {
        guard var tempWord = title?.lowercased() else {return false}
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            }
            else {
                return false
            }
        }
        return true
    }
    
    func isOriginal(word:String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word:String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    //MARK: table datasource methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Word")
        cell?.textLabel?.text = usedWords[indexPath.row]
        
        return cell!
    }
}

