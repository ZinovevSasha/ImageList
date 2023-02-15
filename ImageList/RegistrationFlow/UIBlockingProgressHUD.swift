//
//  UIBlockingProgressHUD.swift
//  ImageList
//
//  Created by Александр Зиновьев on 07.02.2023.
//

import UIKit
import ProgressHUD

enum UIBlockingProgressHUD {
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animationType = .systemActivityIndicator
        ProgressHUD.show()
    }
    
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}