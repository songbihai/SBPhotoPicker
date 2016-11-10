//
//  ViewController.swift
//  SBPhotoPickerExample
//
//  Created by 宋碧海 on 16/10/26.
//  Copyright © 2016年 songbihai. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func btnAction(_ sender: UIButton) {
        let vc = SBPhotoPickerViewController()
        vc.takePhotos = true
        vc.fullscreen = true
//        vc.takeCaremra = true
        sb_presentImagePickerController(vc, animated: true, select: { (photo) in
                print("select: \(photo)")
            }, deselect: { (photo) in
                print("deselect: \(photo)")
            }, cancel: { (photos) in
                print("cancel: \(photos.count)")
            }, finish: { (photos) in
                print("finish: \(photos.count)")
            }) { 
                
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

