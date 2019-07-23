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
    }
    
    // method is called by UIKit as part of the layout phase of your view controller when it first appears on screen. It’s the ideal place for changing the frames of your views by hand.
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        pageControl.frame = CGRect(x: 0, y: view.frame.size.height - pageControl.frame.size.height, width: view.frame.size.width, height: pageControl.frame.size.height)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
