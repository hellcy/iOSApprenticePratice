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
        static let loadingCell = "LoadingCell"
    }

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    // data model
    var searchResults = [SearchResult]()
    var hasSearched = false
    var isLoading = false
    var dataTask: URLSessionDataTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // add a 64 points margin to the top, 20 for the status bar and 44 for the search bar
        tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
        // change the cell height to 80
        tableView.rowHeight = 80
        // register nib files for use
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        cellNib = UINib(nibName:TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
        
        // display keyboard when app has open
        searchBar.becomeFirstResponder()
    }
    
    // MARK: - Action Methods
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        performSearch()
    }
    
    // MARK:- Private Methods
    // This method first builds a URL string by placing the search text behind the “term=” parameter, and then turns this string into a URL object. Because URL(string:) is a failable initializer, it returns an optional. You force unwrap that using url! to return an actual URL object.
    func iTunesURL(searchText: String, category: Int) -> URL {
        //This calls the addingPercentEncoding(withAllowedCharacters:) method to create a new string where all the special characters are escaped, and you use that string for the search term.
        let kind: String
        switch category {
        case 1: kind = "musicTrack"
        case 2: kind = "software"
        case 3: kind = "ebook"
        default: kind = ""
        }
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let urlString = "https://itunes.apple.com/search?term=\(encodedText)&limit=200&entity=\(kind)"
        
        let url = URL(string: urlString)
        return url!
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
    func performSearch() {
        if !searchBar.text!.isEmpty {
            // dismiss the keyboard
            searchBar.resignFirstResponder()
            // If there is an active data task, this cancels it, making sure that no old searches can ever get in the way of the new search.
            dataTask?.cancel()
            isLoading = true
            tableView.reloadData()
            // empty the previous stored data every time user click Search button
            searchResults = []
            hasSearched = true
            // 1 Create the URL object using the search text
            let url = iTunesURL(searchText: searchBar.text!, category: segmentedControl.selectedSegmentIndex)
            // 2 Get a shared URLSession instance, which uses the default configuration with respect to caching, cookies, and other web stuff
            let session = URLSession.shared
            // 3 Create a data task. Data tasks are for fetching the contents of a given URL. The code from the completion handler will be invoked when the data task has received a response from the server.
            dataTask = session.dataTask(with: url, completionHandler: {
                data, response, error in
                // 4 response holds the server’s response code and headers, and data contains the actual data fetched from the server, in this case a blob of JSON.
                if let error = error as NSError?, error.code == -999 {
                    // Search was cancelled
                    return
                } else if let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 200 {
                    if let data = data {
                        self.searchResults = self.parse(data: data)
                        self.searchResults.sort(by: <)
                        DispatchQueue.main.async {
                            // update the user interface
                            self.isLoading = false
                            self.tableView.reloadData()
                        }
                        return
                    }
                } else {
                    print("Failure! \(response!)")
                }
                
                // something went wrong
                DispatchQueue.main.async {
                    self.hasSearched = false
                    self.isLoading = false
                    self.tableView.reloadData()
                    self.showNetworkError()
                }
            })
            // 5 once you have created the data task, you need to call resume() to start it. This sends the request to the server on a background thread. So, the app is immediately free to continue (URLSession is as asynchronous as they come).
            dataTask?.resume()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
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
        if isLoading {
            return 1
        } else if !hasSearched {
            return 0
        } else if searchResults.count == 0 {
            return 1
        } else {
            return searchResults.count
        }
    }
    
    // assign data to cells to display
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loadingCell, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        }
        // assign values from searchResults data model to the cell. nameLabel and artistNameLabel are customer cell's outlets properties defined in the nib file
        else if searchResults.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.nothingFoundCell, for: indexPath)
        } else {
            // using the customer table view cell SearchResultCell
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            let searchResult = searchResults[indexPath.row]
            cell.configure(for: searchResult)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // make sure user can't select cell when there is no searchResults
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0 || isLoading {
            return nil
        } else {
            return indexPath
        }
    }
}
