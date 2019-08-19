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
    lazy var game = Concentration(numberOfPairsOfCards: (cardButtons.count + 1) / 2)
    var flipCount = 0 {
        didSet{
            flipCountLabel.text = "Flips: \(flipCount)"
        }
    }
    @IBOutlet weak var flipCountLabel: UILabel!
    @IBOutlet var cardButtons: [UIButton]!
    
    @IBAction func touchCard(_ sender: UIButton) {
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
    
    func updateViewFromModel() {
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
    
    var emojiArray = ["🦇","😱","🎃","👻","🙀","👿","🍭","🍎"]
    
    // create an empty Dictionary
    var emoji = [Int:String]()

    func emoji(for card: Card) -> String {
        if emoji[card.identifier] == nil {
            if emojiArray.count > 0 {
                let randomIndex = Int(arc4random_uniform(UInt32(emojiArray.count)))
                emoji[card.identifier] = emojiArray.remove(at: randomIndex)
            }
        }
        // check for nil because the value may not be in the Dictionary
        return emoji[card.identifier] ?? "?"
    }
}

