//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by yuan cheng on 22/7/19.
//  Copyright © 2019 yuancheng. All rights reserved.
//

import UIKit
import MessageUI

class DetailViewController: UIViewController {
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
    
    enum AnimationStyle {
        case slide
        case fade
    }
    var dismissStyle = AnimationStyle.fade
    
    // data model
    // You provide a didSet observer to perform certain functionality when the value of a property changes. After searchResult has changed, you call the updateUI() method to set the text on the labels.
    var searchResult: SearchResult! {
        didSet {
            if isViewLoaded {
                updateUI()
            }
        }
    }
    var downloadTask: URLSessionDownloadTask?
    
    // for iPhone is true, for iPad is false
    var isPopUp = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    deinit {
        print("deinit \(self)")
        // cancel image downloading if pop up view is destoried
        downloadTask?.cancel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // change the tint color for this view, the color will apply to this view and all the subviews of this view.
        view.tintColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
        // ask the Pop-up View for its layer and then set the corner radius of that layer to 10 points. All views have a Core Animation layer
        popupView.layer.cornerRadius = 10
        
        if isPopUp {
            // This creates a new gesture recognizer that listens to taps anywhere in this view controller and calls the close() method in response
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
            gestureRecognizer.cancelsTouchesInView = false
            gestureRecognizer.delegate = self
            view.addGestureRecognizer(gestureRecognizer)
            // make the background color clear
            view.backgroundColor = UIColor.clear
        } else {
            // for iPad, we don't want detailView to pop up, but fill the detail pane instead
            view.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
            popupView.isHidden = true
            // The title property is used by the UINavigationController to put the title text in the navigation bar
            if let displayName = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String {
                title = displayName
            }
        }
        
        // pass values from data model to UI
        if searchResult != nil {
            updateUI()
        }
    }
    
    // MARK:- Action Methods
    @IBAction func close() {
        dismissStyle = .slide
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openInStore() {
        if let url = URL(string: searchResult.storeURL) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    // MARK:- Helper Methods
    func updateUI() {
        nameLabel.text = searchResult.name
        if searchResult.artistName.isEmpty {
            artistNameLabel.text = NSLocalizedString("Unknown", comment: "Artist Name: Unknown")
        } else {
            artistNameLabel.text = searchResult.artistName
        }
        
        kindLabel.text = searchResult.type
        genreLabel.text = searchResult.genre
        
        // Show price
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        //formatter.currencySymbol = searchResult.currency
        let priceText: String
        if searchResult.price == 0 {
            priceText = NSLocalizedString("Free", comment: "Item Price: Free")
        } else if let text = formatter.string(
            from: searchResult.price as NSNumber) {
            priceText = text
        } else {
            priceText = ""
        }
        priceButton.setTitle(priceText, for: .normal)
        
        // Get image
        if let largeURL = URL(string: searchResult.imageLarge) {
            downloadTask = artworkImageView.loadImage(url: largeURL)
        }
        
        popupView.isHidden = false
    }
    
    // MARK:- Navigation
    // tells the MenuViewController object who its delegate is.
    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?) {
        if segue.identifier == "ShowMenu" {
            let controller = segue.destination as! MenuViewController
            controller.delegate = self
        }
    }

}

// this extension handles all methods related to the transition between SearchView and DetailView
extension DetailViewController: UIViewControllerTransitioningDelegate {
    // The methods from this delegate protocol tell UIKit what objects it should use to perform the transition to the Detail View Controller. It will now use your new DimmingPresentationController class instead of the standard presentation controller.
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    // fade in animation between switching Views
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            return BounceAnimationController()
    }
    
    // popup view slide up animation
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch dismissStyle {
        case .slide:
            return SlideOutAnimationController()
        case .fade:
            return FadeOutAnimationController()
        }
    }
}

// returns true when the touch was on the background view
extension DetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return (touch.view === self.view)
    }
}

// calls dismiss(animated:) to hide the popover before showing the mail compose sheet
extension DetailViewController: MenuViewControllerDelegate {
    func menuViewControllerSendEmail(_: MenuViewController) {
        dismiss(animated: true) {
            if MFMailComposeViewController.canSendMail() {
                let controller = MFMailComposeViewController()
                controller.mailComposeDelegate = self
                controller.setSubject(NSLocalizedString("Support Request", comment: "Email subject"))
                controller.setToRecipients(["chengyuan82281681@hotmail.com"])
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
}

extension DetailViewController: MFMailComposeViewControllerDelegate {
    // dismiss the mail compose sheet when click 'cancel' or 'send'
    func mailComposeController(_ controller:
        MFMailComposeViewController, didFinishWith result:
        MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}
