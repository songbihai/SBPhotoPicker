//
//  UIViewController+SBPhotoPicker.swift
//  SBPhotoPickerExample
//
//  Created by 宋碧海 on 16/11/2.
//  Copyright © 2016年 songbihai. All rights reserved.
//

import UIKit

public extension UIViewController {
    
    func sb_presentImagePickerController(_ imagePicker: SBPhotoPickerViewController, animated: Bool, select: ((_ asset: SBPhoto) -> Void)?, deselect: ((_ asset: SBPhoto) -> Void)?, cancel: (([SBPhoto]) -> Void)?, finish: (([SBPhoto]) -> Void)?, completion: (() -> Void)?) {
        SBPhotoPickerViewController.authorize(fromViewController: self) { (authorized) -> Void in
            guard authorized == true else { return }
            
            imagePicker.photosViewController.selectionClosure = select
            imagePicker.photosViewController.deselectionClosure = deselect
            imagePicker.photosViewController.cancelClosure = cancel
            imagePicker.photosViewController.finishClosure = finish
            
            self.present(imagePicker, animated: animated, completion: completion)
        }
    }
    
    func showAlert(_ title: String?, message: String?, cancel: String?) {
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction.init(title: cancel, style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
