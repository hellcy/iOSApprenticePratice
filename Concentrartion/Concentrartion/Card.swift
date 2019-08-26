//
//  Card.swift
//  Concentrartion
//
//  Created by yuan cheng on 19/8/19.
//  Copyright © 2019 Yuan Cheng. All rights reserved.
//

import Foundation

struct Card : Hashable {
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    var hashValue: Int { return identifier}
    var isFaceUp = false
    var isMatched = false
    private var identifier: Int
    
    // static keyword meaning these instance variable and functions are belong to the type Card, not the variable card. You can't call these instances from outside the struct Card, its a property that only goes with the type Card
    private static var identifierFactory = 0
    private static func getUniqueIdentifier() -> Int {
        identifierFactory += 1
        return identifierFactory
    }
    
    // initilisers tend to make external and internal names the same
    init() {
        self.identifier = Card.getUniqueIdentifier()
    }
}
