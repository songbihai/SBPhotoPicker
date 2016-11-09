//
//  SBAlbumsTableViewController.swift
//  SBPhotoPickerExample
//
//  Created by 宋碧海 on 16/11/2.
//  Copyright © 2016年 songbihai. All rights reserved.
//

import UIKit

class SBAlbumsTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = true
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = 101
        tableView.register(SBAlbumCell.self, forCellReuseIdentifier: SBAlbumCell.identifier)
    }

}
