//
//  UIViewController+Extension.swift
//  ImageList
//
//  Created by Александр Зиновьев on 23.02.2023.
//

import UIKit

struct Action {
    let title: String
    let style: UIAlertAction.Style
    let handler: ((UIAlertAction) -> Void)?
}

extension UIViewController{
    func showAlert(title: String, message: String, actions: [Action]) {
        // Create alert controller
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Add actions to alert controller
        for action in actions {
            let alertAction = UIAlertAction(title: action.title, style: action.style, handler: action.handler)
            alertController.addAction(alertAction)
        }
        
        // Present alert controller
        present(alertController, animated: true, completion: nil)
    }
}
