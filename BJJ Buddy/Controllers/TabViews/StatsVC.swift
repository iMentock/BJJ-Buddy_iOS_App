//
//  StatsVC.swift
//  BJJ Buddy
//
//  Created by Virgil Martinez on 9/11/18.
//  Copyright © 2018 Virgil Martinez. All rights reserved.
//

import UIKit

class StatsVC: UIViewController {
    
    //MARK: - OUTLETS
    @IBOutlet var totalTrainingTimeLabel: UILabel!
    @IBOutlet var totalRollingTimeLabel: UILabel!
    @IBOutlet var totalRestTimeLabel: UILabel!
    @IBOutlet var totalRoundsRolledLabel: UILabel!
    @IBOutlet var totalJournalEntriesLabel: UILabel!
    @IBOutlet var averageWordsPerEntryLabel: UILabel!
    
    //MARK: - VARIABLES
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var users: [User] = []
    var entries: [JournalEntry] = []
    
    var totalTrainingTime = 0
    var totalRollingTime = 0
    var totalRestTime = 0
    var totalRoundsRolled = 0
    var totalJournalEntries = 0
    var averageWordsPerEntry = 0

    //MARK: - LIFECYCLE FUNCTIONS
    override func viewWillAppear(_ animated: Bool) {
        fetchData()
        if checkIfEmpty() {
            totalTrainingTimeLabel.text = "N/A"
            totalRollingTimeLabel.text = "N/A"
            totalRestTimeLabel.text = "N/A"
            totalRoundsRolledLabel.text = "N/A"
            totalJournalEntriesLabel.text = "N/A"
            averageWordsPerEntryLabel.text = "N/A"
        } else {
            configureJournalEntryStats()
            configureUserEntityStats()
            updateDisplay()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        reset()
    }
    
    //MARK: - CUSTOM FUNCTIONS
    func reset() {
        totalTrainingTime = 0
        totalRollingTime = 0
        totalRestTime = 0
        totalRoundsRolled = 0
        totalJournalEntries = 0
        averageWordsPerEntry = 0
    }
    func checkIfEmpty() -> Bool {
        if users.isEmpty && entries.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    func fetchData() {
        do {
            entries = try context.fetch(JournalEntry.fetchRequest())
            users = try context.fetch(User.fetchRequest())
        } catch {
            //TODO: - Error handling
            print("Couldn't fetch data")
        }
    }
    
    func configureJournalEntryStats() {
        for entry in entries {
            //Minutes into 60
            totalTrainingTime += Int(entry.trainingTime * 60)
            //Seconds
            totalRollingTime += Int(entry.numberOfRounds) * Int(entry.rollingTime * 60)
            totalRoundsRolled += Int(entry.numberOfRounds)
        }
        //Journal Entry count & Average words
        totalJournalEntries = entries.count
        let numberOfWords = countWords()
        let averageWordCount = numberOfWords / totalJournalEntries
        averageWordsPerEntry = averageWordCount
    }
    
    func configureUserEntityStats() {
        totalTrainingTime += Int(users[0].totalClassTime)
        totalRollingTime += Int(users[0].totalTimeRolled)
        totalRestTime += Int(users[0].totalTimeRested)
        totalRoundsRolled += Int(users[0].totalRounds)
    }
    
    func updateDisplay() {
        if totalTrainingTime != 0 {
            totalTrainingTimeLabel.text = makeTimeString(forTime: totalTrainingTime)
        }
        if totalRollingTime != 0 {
            totalRollingTimeLabel.text = makeTimeString(forTime: totalRollingTime)
        }
        if totalRestTime != 0 {
            totalRestTimeLabel.text = makeTimeString(forTime: totalRestTime)
        }
        if totalRoundsRolled != 0 {
            totalRoundsRolledLabel.text = "\(totalRoundsRolled)"
        }
        if totalJournalEntries != 0 {
            totalJournalEntriesLabel.text = "\(totalJournalEntries)"
        }
        if averageWordsPerEntry != 0 {
            averageWordsPerEntryLabel.text = "\(averageWordsPerEntry)"
        }
        
    }
    
    func makeTimeString(forTime: Int) -> String {
        var timeString = ""
        var hours = 0
        var minutes = 0
        var seconds = 0
        
        hours = forTime / 3600
        minutes = (forTime % 3600) / 60
        seconds = (forTime % 3600) % 60

        if hours == 0 && minutes == 0 && seconds != 00 {
            timeString = "\(seconds)(s)"
            return timeString
        } else if hours == 0 && minutes != 0 && seconds == 00 {
            timeString = "\(minutes)(m)"
            return timeString
        } else if hours != 0 && minutes == 0 && seconds == 00 {
            timeString = "\(hours)(h)"
            return timeString
        } else if hours != 0 && minutes != 0 && seconds == 00 {
            timeString = "\(hours)(h) - \(minutes)(m)"
            return timeString
        } else if hours != 0 && minutes != 0 && seconds != 00 {
            timeString = "\(hours)(h) - \(minutes)(m) - \(seconds)(s)"
            return timeString
        } else if hours == 0 && minutes != 0 && seconds != 00 {
            timeString = "\(minutes)(m) - \(seconds)(s)"
            return timeString
        } else {
            timeString = "\(hours)(h) - \(seconds)(s)"
            return timeString
        }
    }
    
    func countWords() -> Int  {
        var wordCount = 0
        let chararacterSet = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
        for entry in entries {
            let components = entry.entry?.components(separatedBy: chararacterSet)
            let words = components?.filter { !$0.isEmpty }
            wordCount += (words?.count)!
        }
        return wordCount
    }
    //TODO: - Connect Social Media Buttons
}
