//
//  UIViewController+LoadingView.swift
//  MeetingiOS
//
//  Created by Lucas Costa  on 07/02/20.
//  Copyright © 2020 Bernardo Nunes. All rights reserved.
//

import Foundation

extension UIViewController {
    
    /// Adicionando um loading inicial para a view controller.
    @objc func addInitialLoadingView() -> UIView {
        
        var frameView = CGRect()
        
        if let frame = self.navigationController?.view.frame {
            frameView = frame
        } else {
            frameView = self.view.frame
        }
        
        let loadingView = UIView(frame: frameView)
        loadingView.backgroundColor = self.view.backgroundColor
        
        let loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()
        
        loadingView.addSubview(loadingIndicator)
        loadingIndicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor).isActive = true
        loadingIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor).isActive = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        return loadingView
    }
    
}
