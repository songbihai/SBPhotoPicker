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
        sb_presentImagePickerController(vc, animated: true, select: { (asset) in
                print("select: \(asset)")
            }, deselect: { (asset) in
                print("deselect: \(asset)")
            }, cancel: { (assets) in
                print("cancel: \(assets.count)")
            }, finish: { (assets) in
                print("finish: \(assets.count)")
            }) { 
                
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

