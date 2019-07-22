//
//  ViewController.swift
//  StoreSearch
//
//  Created by yuancheng on 21/7/19.
//  Copyright © 2019 yuancheng. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    struct TableViewCellIdentifiers {
        // static value can be used without an instance so you don't need to initialize TableViewCellIdentifiers before you can use it
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
    }

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // data model
    var searchResults = [SearchResult]()
    var hasSearched = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // add a 64 points margin to the top, 20 for the status bar and 44 for the search bar
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        // change the cell height to 80
        tableView.rowHeight = 80
        // register nib files for use
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        cellNib = UINib(nibName:TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        // display keyboard when app has open
        searchBar.becomeFirstResponder()
    }

    // MARK:- Private Methods
    // This method first builds a URL string by placing the search text behind the “term=” parameter, and then turns this string into a URL object. Because URL(string:) is a failable initializer, it returns an optional. You force unwrap that using url! to return an actual URL object.
    func iTunesURL(searchText: String) -> URL {
        //This calls the addingPercentEncoding(withAllowedCharacters:) method to create a new string where all the special characters are escaped, and you use that string for the search term.
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = String(format:
            "https://itunes.apple.com/search?term=%@", encodedText)
        let url = URL(string: urlString)
        return url!
    }
    
    // this method is the call to String(contentsOf:encoding:) which returns a new string object with the data it receives from the server at the other end of the URL
    func performStoreRequest(with url: URL) -> Data? {
        do {
            return try Data(contentsOf:url)
        } catch {
            print("Download Error: \(error.localizedDescription)")
            showNetworkError()
            return nil
        }
    }
    
    // You use a JSONDecoder object to convert the response data from the server to a temporary ResultArray object from which you exctract the results property, which is the searchResult array
    func parse(data: Data) -> [SearchResult] {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultArray.self, from:data)
            return result.results
        } catch {
            print("JSON Error: \(error)")
            return []
        }
    }
    
    func showNetworkError() {
        let alert = UIAlertController(title: "Whoops...", message: "There was an error accessing the iTunes Store." +
            " Please try again.", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

}

// MRAK: - Search Bar Delegate Methods
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !searchBar.text!.isEmpty {
            // dismiss the keyboard
            searchBar.resignFirstResponder()
            // empty the previous stored data every time user click Search button
            searchResults = []
            hasSearched = true
            let url = iTunesURL(searchText: searchBar.text!)
            print("URL: '\(url)'")
            if let data = performStoreRequest(with: url) {
                // pass the parsed JSON data to data model
                searchResults = parse(data: data)
                // sort the searchResults array alphabetically
                searchResults.sort(by: <)
            }
            tableView.reloadData()
        }
    }
    
    // attach the search bar to the top of the screen
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

// MARK: - Table View Delegate Methods
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    // number of cells to display
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !hasSearched {
            return 0
        } else if searchResults.count == 0 {
            return 1
        } else {
            return searchResults.count
        }
    }
    
    // assign data to cells to display
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // assign values from searchResults data model to the cell. nameLabel and artistNameLabel are customer cell's outlets properties defined in the nib file
        if searchResults.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.nothingFoundCell, for: indexPath)
        } else {
            // using the customer table view cell SearchResultCell
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            let searchResult = searchResults[indexPath.row]
            cell.nameLabel.text = searchResult.name
            if searchResult.artistName.isEmpty {
                cell.artistNameLabel.text = "Unknown"
            } else {
                cell.artistNameLabel.text = String(format: "%@ (%@)", searchResult.artistName, searchResult.type)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // make sure user can't select cell when there is no searchResults
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0 {
            return nil
        } else {
            return indexPath
        }
    }
}
