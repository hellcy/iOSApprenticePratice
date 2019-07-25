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
    private let search = Search()
    
    var landscapeVC: LandscapeViewController?
    
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
    func showNetworkError() {
        let alert = UIAlertController(title: NSLocalizedString("Whoops...",
           comment: "Error alert: title"), message: NSLocalizedString(
            "There was an error reading from the iTunes Store. Please try again.",
            comment: "Error alert: message"), preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        // 1 It should never happen that the app instantiates a second landscape view when you’re already looking at one. The guard statement codifies this requirement.
        guard landscapeVC == nil else { return }
        // 2 Find the scene with the ID “LandscapeViewController” in the storyboard and instantiate it
        landscapeVC = storyboard!.instantiateViewController( withIdentifier: "LandscapeViewController") as? LandscapeViewController
        if let controller = landscapeVC {
            controller.search = search
            // 3 Set the size and position of the new view controller. This makes the landscape view just as big as the SearchViewController, covering the entire screen.
            controller.view.frame = view.bounds
            controller.view.alpha = 0
            // 4
            view.addSubview(controller.view)
            addChild(controller)
            // The call to animate(alongsideTransition:completion:) takes two closures: the first is for the animation itself, the second is a “completion handler” that gets called after the animation finishes. The completion handler gives you a chance to delay the call to didMove(toParentViewController:) until the animation is over
            coordinator.animate(alongsideTransition: { _ in
                controller.view.alpha = 1
                // dismiss the keyboard when transition to landscape
                self.searchBar.resignFirstResponder()
            }, completion: { _ in
                controller.didMove(toParent: self)
                // dismiss the detailView if it exists
                if self.presentedViewController != nil {
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
    
    func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        if let controller = landscapeVC {
            // tell the view controller that it is leaving the view controller hierarchy (it no longer has a parent).
            controller.willMove(toParent: nil)
            coordinator.animate(alongsideTransition: { _ in
                controller.view.alpha = 0
            }, completion: { _ in
                //  remove its view from the screen
                controller.view.removeFromSuperview()
                // disposes of the view controller.
                controller.removeFromParent()
                //  remove the last strong reference to the LandscapeViewController object
                self.landscapeVC = nil
                // remove detailView
                if self.presentedViewController != nil {
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
    
    // MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            if case .results(let list) = search.state {
                let detailViewController = segue.destination as! DetailViewController
                // get the correct searchResult to show in the DetailViewController using indexPath
                let indexPath = sender as! IndexPath
                let searchResult = list[indexPath.row]
                detailViewController.searchResult = searchResult
            }
        }
    }
    
    // This method is invoked whenever the trait collection for the view controller changes.
    // Trait collection includes:
    // The horizontal size class
    // The vertical size class
    // The display scale (is this a Retina screen or not?)
    // The user interface idiom (is this an iPhone or iPad?)
    // The preferred Dynamic Type font size
    // And a few other things
    override func willTransition(
        to newCollection: UITraitCollection,
        with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        switch newCollection.verticalSizeClass {
        case .compact:
            showLandscape(with: coordinator)
        case .regular, .unspecified:
            hideLandscape(with: coordinator)
        }
    }

}

// MRAK: - Search Bar Delegate Methods
extension SearchViewController: UISearchBarDelegate {
    func performSearch() {
        if let category = Search.Category(rawValue: segmentedControl.selectedSegmentIndex) {
            search.performSearch(for: searchBar.text!, category: category,
            // You now pass a closure to performSearch(for:category:completion:). The code in this closure gets called after the search completes, with the success parameter being either true or false
            completion: { success in
                if !success {
                    self.showNetworkError()
                }
                self.tableView.reloadData()
            })
            tableView.reloadData()
            self.landscapeVC?.searchResultsReceived()
            searchBar.resignFirstResponder()
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
        switch search.state {
        case .notSearchedYet:
            return 0
        case .loading:
            return 1
        case .noResults:
            return 1
        // .results has an array of SearchResult objects associated with it, you can bind this array to a temporary variable, list, and then use that variable inside the case to read how many items are in the array. That’s how you make use of the associated value.
        case .results(let list):
            return list.count
        }
    }
    
    // assign data to cells to display
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch search.state {
        case .notSearchedYet:
            fatalError("Should never get here")
        case .loading:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TableViewCellIdentifiers.loadingCell,
                for: indexPath)
            
            let spinner = cell.viewWithTag(100) as!
            UIActivityIndicatorView
            spinner.startAnimating()
            return cell
            
        case .noResults:
            return tableView.dequeueReusableCell(
                withIdentifier: TableViewCellIdentifiers.nothingFoundCell,
                for: indexPath)
            
        // using the customer table view cell SearchResultCell
        case .results(let list):
            let cell = tableView.dequeueReusableCell(
                withIdentifier: TableViewCellIdentifiers.searchResultCell,
                for: indexPath) as! SearchResultCell
            
            let searchResult = list[indexPath.row]
            cell.configure(for: searchResult)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ShowDetail", sender: indexPath)
    }
    
    // make sure user can't select cell when there is no searchResults
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch search.state {
        case .notSearchedYet, .loading, .noResults:
            return nil
        case .results:
            return indexPath
        }
    }
}
