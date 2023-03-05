//
//  UIViewController+Extension.swift
//  ImageList
//
//  Created by Александр Зиновьев on 23.02.2023.
//

import UIKit

extension UIViewController{
    func showAlert(title: String, message: String, actions: [Action]) {
        // Create alert controller
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        // Crate actions array
        let actions = actions.map { $0.toConvertToAlertAction() }
        
        // Add actions to alert controller
        actions.forEach { alertController.addAction($0) }
        
        // Present alert controller
        present(alertController, animated: true, completion: nil)
    }
}

struct Action {
    let title: String
    let style: UIAlertAction.Style
    let handler: ((UIAlertAction) -> Void)?
}

private extension Action {
    func toConvertToAlertAction() -> UIAlertAction {
        return UIAlertAction(
            title: self.title,
            style: self.style,
            handler: self.handler
        )
    }
}
