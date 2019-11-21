//
//  ViewController.swift
//  Concentrartion
//
//  Created by yuan cheng on 19/8/19.
//  Copyright © 2019 Yuan Cheng. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    // during the initialize of game, we need cardButtons, which is also during the initiation step, so we use lazy keyword, lazy means we don't initialize game until someone wants to use it.
    private lazy var game = Concentration(numberOfPairsOfCards: numberOfPairsOfCards)
    
    var numberOfPairsOfCards: Int {
        return (cardButtons.count + 1) / 2
    }
    
    private(set) var flipCount = 0 {
        didSet{
            updateFlipCountLabel()
        }
    }
    
    private func updateFlipCountLabel() {
        let attributes: [NSAttributedString.Key:Any] = [
            .strokeWidth : 5.0,
            .strokeColor : UIColor.orange
        ]
        let attributedString = NSAttributedString(string: "Flips: \(flipCount)", attributes: attributes)
        flipCountLabel.attributedText = attributedString
    }
    @IBOutlet private weak var flipCountLabel: UILabel! {
        didSet {
            updateFlipCountLabel()
        }
    }
    @IBOutlet private var cardButtons: [UIButton]!
    
    @IBAction private func touchCard(_ sender: UIButton) {
        flipCount += 1
        if let cardNumber = cardButtons.firstIndex(of: sender) {
            // update the card Model
            game.chooseCard(at: cardNumber)
            // update the button View
            updateViewFromModel()
        } else {
            print("chosen card was not in cardButtons")
        }
    }
    
    private func updateViewFromModel() {
        for index in cardButtons.indices {
            let button = cardButtons[index]
            let card = game.cards[index]
            if card.isFaceUp {
                button.setTitle(emoji(for: card), for: UIControl.State.normal)
                button.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            } else {
                button.setTitle("", for: UIControl.State.normal)
                button.backgroundColor = card.isMatched ? #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 0) : #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
            }
        }
    }
    
    //private var emojiArray = ["🦇","😱","🎃","👻","🙀","👿","🍭","🍎"]
    private var emojiArray = "🦇😱🎃👻🙀👿🍭🍎"

    // create an empty Dictionary
    private var emoji = [Card:String]()

    private func emoji(for card: Card) -> String {
        if emoji[card] == nil, emojiArray.count > 0 {
            // take a random emoji out of the array and assign it to the card
            // instead of using emojiArray as a array of string, we make emojis a string!
            let randomEmojiIndex = emojiArray.index(emojiArray.startIndex, offsetBy: emojiArray.count.arc4random)
            emoji[card] = String(emojiArray.remove(at: randomEmojiIndex))
        }
        // check for nil because the value may not be in the Dictionary
        return emoji[card] ?? "?"
    }
}

// In this extension we add a new computed variable, which when an integer is trying to get it, it returns a random integer from 0 to that integer.
// So add this extension because this variable is associated with the type Int, its not related to our game concentration, so its better to put it in an extension. To make our code more clear.
extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}
