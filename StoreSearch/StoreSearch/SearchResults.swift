//
//  SearchResults.swift
//  StoreSearch
//
//  Created by yuancheng on 21/7/19.
//  Copyright © 2019 yuancheng. All rights reserved.
//
import Foundation

private let typeForKind = [
    "album": NSLocalizedString("Album",
                               comment: "Localized kind: Album"),
    "audiobook": NSLocalizedString("Audio Book",
                                   comment: "Localized kind: Audio Book"),
    "book": NSLocalizedString("Book",
                              comment: "Localized kind: Book"),
    "ebook": NSLocalizedString("E-Book",
                               comment: "Localized kind: E-Book"),
    "feature-movie": NSLocalizedString("Movie",
                                       comment: "Localized kind: Feature Movie"),
    "music-video": NSLocalizedString("Music Video",
                                     comment: "Localized kind: Music Video"),
    "podcast": NSLocalizedString("Podcast",
                                 comment: "Localized kind: Podcast"),
    "software": NSLocalizedString("App",
                                  comment: "Localized kind: Software"),
    "song": NSLocalizedString("Song",
                              comment: "Localized kind: Song"),
    "tv-episode": NSLocalizedString("TV Episode",
                                    comment: "Localized kind: TV Episode"),
]

class ResultArray: Codable {
    var resultCount = 0
    var results = [SearchResult]()
}

class SearchResult: Codable, CustomStringConvertible {
    // names have to be exactly the same as the JSON data
    var artistName = ""
    var trackPrice:Double?
    var kind:String?
    var currency = ""
    var imageSmall = ""
    var imageLarge = ""
    
    var trackName:String?
    var trackViewUrl:String?
    var itemPrice:Double?
    var itemGenre:String?

    var collectionName:String?
    var collectionViewUrl:String?
    var collectionPrice:Double?
    var bookGenre:[String]?
    
    // The computed name property is simply preparation for the future in case you want to display different names depending on the result type.
    //  The nilcoalescing operator(??) unwraps the variable to the left of the operator if it has a value, if not, it returns the value to the right of the operator as the default value.
    var name:String {
        return trackName ?? collectionName ?? ""
    }
    
    var description:String {
        return "Kind: \(kind ?? ""), Name: \(name), Artist Name: \(artistName)\n"
    }
    
    var storeURL:String {
        return trackViewUrl ?? collectionViewUrl ?? ""
    }
    var price:Double {
        return trackPrice ?? collectionPrice ?? itemPrice ?? 0.0
    }
    var genre:String {
        if let genre = itemGenre {
            return genre
        } else if let genres = bookGenre {
            return genres.joined(separator: ", ")
        }
        return ""
    }
    
    // unlike in other languages, the case statements in Swift do not need to say break at the end. They do not automatically “fall through” from one case to the other as they do in Objective-C.
    var type: String {
        let kind = self.kind ?? "audiobook"
        return typeForKind[kind] ?? kind
    }
    
    // you use the CodingKeys enumeration to let the Codable protocol know how you want the SearchResult properties matched to the JSON data
    enum CodingKeys: String, CodingKey {
        case imageSmall = "artworkUrl60"
        case imageLarge = "artworkUrl100"
        case itemGenre = "primaryGenreName"
        case bookGenre = "genres"
        case itemPrice = "price"
        case kind, artistName, currency
        case trackName, trackPrice, trackViewUrl
        case collectionName, collectionViewUrl, collectionPrice
    }
}

// You have now overloaded the less-than operator so that it takes two SearchResult objects and returns true if the first one should come before the second, and false otherwise
func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
    return lhs.name.localizedStandardCompare(rhs.name) ==
        .orderedAscending
}
