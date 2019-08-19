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
    func chooseCard(at index: Int){
        if cards[index].isFaceUp {
            cards[index].isFaceUp = false
        } else {
            cards[index].isFaceUp = true
        }
    }
    
    init(numberOfPairsOfCards: Int){
        for _ in 1...numberOfPairsOfCards {
            let card = Card()
            cards += [card, card]
        }
        // TODO: shuffle the cards
    }
}
