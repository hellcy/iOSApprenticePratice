//
//  Search.swift
//  StoreSearch
//
//  Created by yuancheng on 24/7/19.
//  Copyright © 2019 yuancheng. All rights reserved.
//

import Foundation

// The typealias declaration allows you to create a more convenient name for a data type, in order to save some keystrokes and to make the code more readable. Here, you declare a type for your own closure, named SearchComplete. This is a closure that returns no value (it is Void) and takes one parameter, a Bool
typealias SearchComplete = (Bool) -> Void

class Search {
    enum State {
        case notSearchedYet
        case loading
        case noResults
        case results([SearchResult])
    }
    
    // With private(set) you tell Swift that reading is OK for other objects, but assigning (or setting) new values to this variable may only happen inside the Search class.
    private(set) var state: State = .notSearchedYet
    
    private var dataTask: URLSessionDataTask? = nil
    
    enum Category: Int {
        case all = 0
        case music = 1
        case software = 2
        case ebooks = 3
        
        var type: String {
            switch self {
            case .all: return ""
            case .music: return "musicTrack"
            case .software: return "software"
            case .ebooks: return "ebook"
            }
        }
    }
    
    func performSearch(for text: String, category: Category, completion: @escaping SearchComplete) {
        if !text.isEmpty {
            // If there is an active data task, this cancels it, making sure that no old searches can ever get in the way of the new search.
            dataTask?.cancel()
            state = .loading
            // 1 Create the URL object using the search text
            let url = iTunesURL(searchText: text, category: category)
            // 2 Get a shared URLSession instance, which uses the default configuration with respect to caching, cookies, and other web stuff
            let session = URLSession.shared
            // 3 Create a data task. Data tasks are for fetching the contents of a given URL. The code from the completion handler will be invoked when the data task has received a response from the server.
            dataTask = session.dataTask(with: url, completionHandler: {
                data, response, error in
                var newState = State.notSearchedYet
                var success = false
                // Was the search cancelled?
                // 4 response holds the server’s response code and headers, and data contains the actual data fetched from the server, in this case a blob of JSON.
                if let error = error as NSError?, error.code == -999 {
                    return
                }
                if let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 200, let data = data {
                    var searchResults = self.parse(data: data)
                    if searchResults.isEmpty {
                        newState = .noResults
                    } else {
                        searchResults.sort(by: <)
                        newState = .results(searchResults)
                    }
                    success = true
                }

                DispatchQueue.main.async {
                    self.state = newState
                    completion(success)
                } 
            })
            // 5 once you have created the data task, you need to call resume() to start it. This sends the request to the server on a background thread. So, the app is immediately free to continue (URLSession is as asynchronous as they come).
            dataTask?.resume()
        }
    }
    
    // This method first builds a URL string by placing the search text behind the “term=” parameter, and then turns this string into a URL object. Because URL(string:) is a failable initializer, it returns an optional. You force unwrap that using url! to return an actual URL object.
    private func iTunesURL(searchText: String, category: Category) -> URL {
        //This calls the addingPercentEncoding(withAllowedCharacters:) method to create a new string where all the special characters are escaped, and you use that string for the search term.
        let kind = category.type
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let urlString = "https://itunes.apple.com/search?term=\(encodedText)&limit=200&entity=\(kind)"
        
        let url = URL(string: urlString)
        return url!
    }
    
    // You use a JSONDecoder object to convert the response data from the server to a temporary ResultArray object from which you exctract the results property, which is the searchResult array
    private func parse(data: Data) -> [SearchResult] {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultArray.self, from:data)
            return result.results
        } catch {
            print("JSON Error: \(error)")
            return []
        }
    }
}
