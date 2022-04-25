//
//  YPlayerBaseViewController.swift
//  YoutubePlayer
//
//  Created by Mabed on 26/04/2022.
//

import Foundation
import UIKit

class YPlayerBaseViewController: UIViewController {
    
    private lazy var loadingView: UIActivityIndicatorView = {
        let loginSpinner = UIActivityIndicatorView(style: .large)
        loginSpinner.translatesAutoresizingMaskIntoConstraints = false
        loginSpinner.hidesWhenStopped = true
        view.addSubview(loginSpinner)
        loginSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        return loginSpinner
    }()
    
    func showLoadingView() {
        loadingView.startAnimating()
    }
    
    func hideLoadingView() {
        loadingView.stopAnimating()
    }
}
