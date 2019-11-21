//
//  UIImageView+DownloadImage.swift
//  StoreSearch
//
//  Created by yuan cheng on 22/7/19.
//  Copyright © 2019 yuancheng. All rights reserved.
//

import UIKit
import Alamofire

extension UIImageView {
    func loadImage(url: URL) -> URLSessionDownloadTask {
        let session = URLSession.shared
        // 1 After obtaining a reference to the shared URLSession, you create a download task. This is similar to a data task, but it saves the downloaded file to a temporary location on disk instead of keeping it in memory.
        let downloadTask = session.downloadTask(with: url, completionHandler: {
            [weak self] url, response, error in
            // 2 you’re given a URL where you can find the downloaded file (this URL points to a local file rather than an internet address)
            if error == nil, let url = url,
                let data = try? Data(contentsOf: url), // 3 check error
                let image = UIImage(data: data) {
                // 4 Inside the DispatchQueue.main.async you need to check whether “self” still exists; if not, then there is no more UIImageView to set the image on. For example, if user go to another view, then this view controller and the UIImageView object is no longer exist.
                DispatchQueue.main.async {
                    if let weakSelf = self {
                        weakSelf.image = image
                    }
                }
            }
        })
        // 5 resume to the main thread and return the URLSessionDownloadTask object to the caller, this gives the app an opportunity to cancel the downloading task
        downloadTask.resume()
        return downloadTask
    }
}
