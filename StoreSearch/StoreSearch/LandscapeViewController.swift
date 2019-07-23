//
//  LandscapeViewController.swift
//  StoreSearch
//
//  Created by yuan cheng on 23/7/19.
//  Copyright © 2019 yuancheng. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    // data model
    var searchResults = [SearchResult]()
    
    // A warning: viewWillLayoutSubviews() may be invoked more than once! For example, it’s also called when the landscape view gets removed from the screen again. You use the firstTime variable to make sure you only place the buttons once.
    private var firstTime = true

    override func viewDidLoad() {
        super.viewDidLoad()
        // Remove constraints from main view
        view.removeConstraints(view.constraints)
        // This allows you to position and size your views manually by changing their frame property.
        view.translatesAutoresizingMaskIntoConstraints = true
        // Remove constraints for page control
        pageControl.removeConstraints(pageControl.constraints)
        pageControl.translatesAutoresizingMaskIntoConstraints = true
        // Remove constraints for scroll view
        scrollView.removeConstraints(scrollView.constraints)
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        // Do any additional setup after loading the view.
        
        scrollView.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
        
        pageControl.numberOfPages = 0
    }
    
    // method is called by UIKit as part of the layout phase of your view controller when it first appears on screen. It’s the ideal place for changing the frames of your views by hand.
    // The scroll view should always be as large as the entire screen, so you make its frame equal to the main view’s bounds.
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        pageControl.frame = CGRect(x: 0, y: view.frame.size.height - pageControl.frame.size.height, width: view.frame.size.width, height: pageControl.frame.size.height)
        
        if firstTime {
            firstTime = false
            tileButtons(searchResults)
        }
    }
    
    // MARK:- Actions
    @IBAction func pageChanged(_ sender: UIPageControl) {
        scrollView.contentOffset = CGPoint(
            x: scrollView.bounds.size.width *
                CGFloat(sender.currentPage), y: 0)
    }
    
    // MARK:- Private Methods
    private func tileButtons(_ searchResults: [SearchResult]) {
        var columnsPerPage = 5
        var rowsPerPage = 3
        var itemWidth: CGFloat = 96
        var itemHeight: CGFloat = 88
        var marginX: CGFloat = 0
        var marginY: CGFloat = 20
        
        let viewWidth = scrollView.bounds.size.width
        
        switch viewWidth {
        case 568:
            columnsPerPage = 6
            itemWidth = 94
            marginX = 2
            
        case 667:
            columnsPerPage = 7
            itemWidth = 95
            itemHeight = 98
            marginX = 1
            marginY = 29
            
        case 736:
            columnsPerPage = 8
            rowsPerPage = 4
            itemWidth = 92
            
        default:
            break
        }
        
        // Button size
        let buttonWidth: CGFloat = 82
        let buttonHeight: CGFloat = 82
        let paddingHorz = (itemWidth - buttonWidth)/2
        let paddingVert = (itemHeight - buttonHeight)/2
        
        // Add the buttons
        var row = 0
        var column = 0
        var x = marginX
        // This for in loop steps through the SearchResult objects from the array, but with a twist. By calling the array's enumerated() method, you get a tuple containing not only the next SearchResult object but also its index in the array. A tuple is nothing more than a temporary list with two or more items in it. Here, the tuple is (index, result). This is a neat trick to loop through an array and get both the objects and their indices.
        for (index, result) in searchResults.enumerated() {
            // 1 Create the UIButton object. For debugging purposes, you give each button a title with the array index. If there are 200 results in the search, you also should end up with 200 buttons. Setting the index on the button will help to verify this.
            let button = UIButton(type: .system)
            button.backgroundColor = UIColor.white
            button.setTitle("\(index)", for: .normal)
            // 2 When you make a button by hand, you always have to set its frame
            button.frame = CGRect(x: x + paddingHorz,
                                  y: marginY + CGFloat(row)*itemHeight + paddingVert,
                                  width: buttonWidth, height: buttonHeight)
            // 3 You add the new button object to the UIScrollView as a subview.
            scrollView.addSubview(button)
            // 4 You use the x and row variables to position the buttons, going from top to bottom
            row += 1
            if row == rowsPerPage {
                row = 0; x += itemWidth; column += 1
                
                if column == columnsPerPage {
                    column = 0; x += marginX * 2
                }
            }
        }
        
        // Set scroll view content size
        let buttonsPerPage = columnsPerPage * rowsPerPage
        let numPages = 1 + (searchResults.count - 1) / buttonsPerPage
        scrollView.contentSize = CGSize(
            width: CGFloat(numPages) * viewWidth,
            height: scrollView.bounds.size.height)
        print("Number of pages: \(numPages)")
        
        pageControl.numberOfPages = numPages
        pageControl.currentPage = 0
    }

}

// This is a UIScrollViewDelegate method. You figure out what the index of the current page is by looking at the contentOffset property of the scroll view. This property determines how far the scroll view has been scrolled and is updated while you’re dragging the scroll view. Unfortunately, the scroll view doesn’t simply tell us, “The user has flipped to page X”. So, you have to calculate this yourself. If the content offset gets beyond halfway on the page (width/2), the scroll view will move to the next page. In that case, you update the pageControl’s active page number.
extension LandscapeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.size.width
        let page = Int((scrollView.contentOffset.x + width / 2)
            / width)
        pageControl.currentPage = page
    }
}
