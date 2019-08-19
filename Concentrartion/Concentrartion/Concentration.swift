//
//  Concentration.swift
//  Concentrartion
//
//  Created by yuan cheng on 19/8/19.
//  Copyright © 2019 Yuan Cheng. All rights reserved.
//

import Foundation

class Concentration {
    var cards = [Card]()
    var indexOfOneAndOnlyFaceUpCard: Int?
    func chooseCard(at index: Int){
        // only do thing with cards that are not matched yet
        if !cards[index].isMatched {
            if let matchIndex = indexOfOneAndOnlyFaceUpCard, matchIndex != index {
                // check if cards match
                if cards[matchIndex].identifier == cards[index].identifier {
                    cards[matchIndex].isMatched = true
                    cards[index].isMatched = true
                }
                cards[index].isFaceUp = true
                indexOfOneAndOnlyFaceUpCard = nil // now we have 2 cards face up, so this variable is set to nil
            } else {
                // no cards or 2 cards face up
                for flipDownIndex in cards.indices {
                    // turn all cards face down
                    cards[flipDownIndex].isFaceUp = false
                }
                cards[index].isFaceUp = true
                indexOfOneAndOnlyFaceUpCard = index
            }
        }
    }
    
    init(numberOfPairsOfCards: Int){
        for _ in 1...numberOfPairsOfCards {
            // here we create a new card, with a unique identifier
            let card = Card()
            // here we add two cards with the same identifier to the array, so we make sure that cards are all in pairs.
            cards += [card, card]
        }
        // TODO: shuffle the cards
    }
}
