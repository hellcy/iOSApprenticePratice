//
//  Concentration.swift
//  Concentrartion
//
//  Created by yuan cheng on 19/8/19.
//  Copyright © 2019 Yuan Cheng. All rights reserved.
//

import Foundation

class Concentration {
    // cards are private(set) becasue we want UI to display the cards, which means they can GET the cards, but to SET properties of cards, such as isFaceUp, isMatched are my job, so we don't allow others to SET cards.
    private(set) var cards = [Card]()
    private var indexOfOneAndOnlyFaceUpCard: Int? {
        get {
            var foundIndex: Int?
            for index in cards.indices {
                if cards[index].isFaceUp {
                    if foundIndex == nil {
                        foundIndex = index
                    } else {
                        return nil
                    }
                }
            }
            return foundIndex
        }
        set {
            // turn all cards face down except the card with index == newValue
            for index in cards.indices {
                cards[index].isFaceUp = (index == newValue)
            }
        }
    }
    func chooseCard(at index: Int){
        // make sure users don't give a index that are not in the cards.
        assert(cards.indices.contains(index))
        // only do thing with cards that are not matched yet
        if !cards[index].isMatched {
            if let matchIndex = indexOfOneAndOnlyFaceUpCard, matchIndex != index {
                // check if cards match
                if cards[matchIndex].identifier == cards[index].identifier {
                    cards[matchIndex].isMatched = true
                    cards[index].isMatched = true
                }
                cards[index].isFaceUp = true
            } else {
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
