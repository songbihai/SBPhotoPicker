//
//  SBPhotosViewController.swift
//  SBPhotoPickerExample
//
//  Created by 宋碧海 on 16/11/1.
//  Copyright © 2016年 songbihai. All rights reserved.
//

import UIKit
import Photos

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


final class SBPhotosViewController: UICollectionViewController {
    var selectionClosure: ((_ photo: SBPhoto) -> Void)?
    var deselectionClosure: ((_ photo: SBPhoto) -> Void)?
    var cancelClosure: ((_ photos: [SBPhoto]) -> Void)?
    var finishClosure: ((_ photos: [SBPhoto]) -> Void)?
    
    let settings: SBPhotoPickerSettings
    
    var selectedIndexPaths = [IndexPath]()
    var selections = [SBPhoto]()
    var photoCollection: SBPhotoCollection!
    var photoCollections: [SBPhotoCollection]!
    var fetchResult: PHFetchResult<PHAsset>!
    var cameraDataSource: SBCameraCollectionViewDataSource
    
    fileprivate let cameraAvailable: Bool = UIImagePickerController.isSourceTypeAvailable(.camera)
    fileprivate let photosManager = PHCachingImageManager.default()
    fileprivate let imageContentMode: PHImageContentMode = .aspectFill
    fileprivate var composedDataSource: SBComposedCollectionViewDataSource?
    
    var imageSize: CGSize = CGSize.zero
    
    var doneBarButton: UIBarButtonItem?
    var cancelBarButton: UIBarButtonItem?
    var albumTitleView: SBAlbumTitleView?
    
    lazy var albumsViewController: SBAlbumsTableViewController = {

        let vc = SBAlbumsTableViewController()
        vc.tableView.dataSource = self.albumsDataSource
        vc.tableView.delegate = self
        return vc
    }()
    
    fileprivate lazy var alphaView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = UIColor.white
        view.alpha = 0.3
        return view
    }()
    
    fileprivate var defaultSelections: SBPhotoCollection!
    fileprivate var doneBarButtonTitle: String?
    fileprivate let expandAnimator = SBZoomAnimator() //push动画
    fileprivate let shrinkAnimator = SBZoomAnimator() //pop动画
    fileprivate var albumsDataSource: SBAlbumTableViewDataSource
    
    init(photoCollections: [SBPhotoCollection], defaultSelections: SBPhotoCollection, settings aSettings: SBPhotoPickerSettings) {
        albumsDataSource = SBAlbumTableViewDataSource(photoCollections: photoCollections)
        self.defaultSelections = defaultSelections
        self.photoCollections = photoCollections
        cameraDataSource = SBCameraCollectionViewDataSource.init(settings: aSettings, cameraAvailable: cameraAvailable)
        settings = aSettings
        super.init(collectionViewLayout: SBCollectionViewLayout())
        
        PHPhotoLibrary.shared().register(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func loadView() {
        super.loadView()
        
        collectionView?.backgroundColor = UIColor.white
        collectionView?.allowsMultipleSelection = true
        collectionView?.showsVerticalScrollIndicator = false
        
        title = " "
        
        doneBarButton?.target = self
        doneBarButton?.action = #selector(SBPhotosViewController.doneButtonPressed(_:))
        cancelBarButton?.target = self
        cancelBarButton?.action = #selector(SBPhotosViewController.cancelButtonPressed(_:))
        albumTitleView?.albumButton?.addTarget(self, action: #selector(SBPhotosViewController.albumButtonPressed(_:)), for: .touchUpInside)
        navigationItem.leftBarButtonItem = cancelBarButton
        navigationItem.rightBarButtonItem = doneBarButton
        navigationItem.titleView = albumTitleView
        
        if let album = albumsDataSource.photoCollections.first {
            initializePhotosDataSource(album, selections: defaultSelections.fetchResult )
            updateAlbumTitle(album)
            synchronizeCollectionView()
        }

        navigationController?.delegate = self
        
        self.registerCellIdentifiersForCollectionView(collectionView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alphaView.frame = view.bounds
        view.addSubview(alphaView)
        albumsViewController.view.frame = CGRect(x: 0, y: -view.bounds.height + 64, width: view.bounds.width, height: view.bounds.height - 64)
        view.addSubview(albumsViewController.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateDoneButton()
    }
    
    func cancelButtonPressed(_ sender: UIBarButtonItem) {
        guard let closure = cancelClosure else {
            dismiss(animated: true, completion: nil)
            return
        }
        
        dispatch_async_safely_to_queue(DispatchQueue.global(qos: .default), {
            closure(self.selections)
        })
        
        dismiss(animated: true, completion: nil)
    }
    
    func doneButtonPressed(_ sender: UIBarButtonItem) {
        guard let closure = finishClosure else {
            dismiss(animated: true, completion: nil)
            return
        }
        
        dispatch_async_safely_to_queue(DispatchQueue.global(qos: .default), {
            closure(self.selections)
        })
        
        dismiss(animated: true, completion: nil)
    }
    
    func albumButtonPressed(_ sender: UIButton) {
        self.albumTitleView?.isSelected = !self.albumTitleView!.isSelected
        if self.albumTitleView!.isSelected {
            UIView.animate(withDuration: 0.35, animations: {
                self.alphaView.isHidden = false
                self.albumsViewController.view.layer.transform = CATransform3DMakeTranslation(0, self.view.bounds.height, 0)
                self.albumTitleView?.albumButton.setImage(self.albumTitleView?.arrowDownImage, for: UIControlState.normal)
            })
        }else {
            UIView.animate(withDuration: 0.35, animations: {
                self.alphaView.isHidden = true
                self.albumsViewController.view.layer.transform = CATransform3DIdentity
                self.albumTitleView?.albumButton.setImage(self.albumTitleView?.arrowDownImage, for: UIControlState.normal)
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func registerCellIdentifiersForCollectionView(_ collectionView: UICollectionView?) {
        collectionView?.register(SBPhotoCell.self, forCellWithReuseIdentifier: SBPhotoCell.identifier)
        collectionView?.register(SBCameraCell.self, forCellWithReuseIdentifier: SBCameraCell.identifier)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
}

// MARK: UINavigationControllerDelegate
extension SBPhotosViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            return expandAnimator
        } else {
            return shrinkAnimator
        }
    }
}

// MARK: PHPhotoLibraryChangeObserver（逻辑现还有问题）
extension SBPhotosViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let collectionView = collectionView else {
            return
        }
        
        dispatch_async_safely_to_main_queue {
            if let photosChanges = changeInstance.changeDetails(for: self.fetchResult) {

                if photosChanges.hasIncrementalChanges && (photosChanges.removedIndexes?.count > 0 || photosChanges.insertedIndexes?.count > 0 || photosChanges.changedIndexes?.count > 0) {
                    
                    self.fetchResult = photosChanges.fetchResultAfterChanges
                    self.photoCollection = SBPhotoCollection()
                    self.fetchResult.enumerateObjects(using: { (asset, idx, stop) in
                        self.photoCollection.append(SBPhoto(asset: asset))
                    })
                    
                    if let removed = photosChanges.removedIndexes {
                        collectionView.deleteItems(at: removed.sb_indexPathsForSection(0))
                    }
                    
                    if let inserted = photosChanges.insertedIndexes {
                        collectionView.insertItems(at: inserted.sb_indexPathsForSection(0))
                    }
                } else if photosChanges.hasIncrementalChanges == false {
                    self.fetchResult = photosChanges.fetchResultAfterChanges
                    self.photoCollection = SBPhotoCollection()
                    self.fetchResult.enumerateObjects(using: { (asset, idx, stop) in
                        self.photoCollection.append(SBPhoto(asset: asset))
                    })
                    
                    collectionView.reloadData()
                }
            }
        }
    }
}

// MARK: private method
private extension SBPhotosViewController {
    
    func updateDoneButton() {

        if let subViews = navigationController?.navigationBar.subviews {
            for view in subViews {
                if let btn = view as? UIButton, checkIfRightButtonItem(btn) {

                    if doneBarButtonTitle == nil {
                        doneBarButtonTitle = btn.title(for: UIControlState.normal)
                    }
                    
                    if let doneBarButtonTitle = doneBarButtonTitle {
                        if (self.selections.count == 1 && self.settings.maxNumberOfSelections == 1) {
                            btn.sb_setTitleWithoutAnimation("\(doneBarButtonTitle)", forState: UIControlState.normal)
                        } else if self.selections.count > 0 {
                            btn.sb_setTitleWithoutAnimation("\(doneBarButtonTitle) (\(self.selections.count))", forState: UIControlState.normal)
                        } else {
                            btn.sb_setTitleWithoutAnimation(doneBarButtonTitle, forState: UIControlState.normal)
                        }
                        
                        doneBarButton?.isEnabled = self.selections.count > 0
                    }
                    
                    break
                }
            }
        }
    }

    func checkIfRightButtonItem(_ btn: UIButton) -> Bool {
        guard let rightButton = navigationItem.rightBarButtonItem else {
            return false
        }
        
        let wasRightEnabled = rightButton.isEnabled
        let wasButtonEnabled = btn.isEnabled
        
        rightButton.isEnabled = false
        btn.isEnabled = false
        
        rightButton.isEnabled = true
        let isRightButton = btn.isEnabled
        
        rightButton.isEnabled = wasRightEnabled
        btn.isEnabled = wasButtonEnabled
        
        return isRightButton
    }
    
    func updateAlbumTitle(_ album: SBPhotoCollection) {
        if let title = album.title {
            albumTitleView?.albumTitle = title
        }
    }
    
    func initializePhotosDataSource(_ album: SBPhotoCollection, selections: PHFetchResult<PHAsset>? = nil) {
        self.photoCollection = album
        composedDataSource = SBComposedCollectionViewDataSource(dataSources: [cameraDataSource, self])
        collectionView?.dataSource = composedDataSource;
        collectionView?.delegate = self
    }
    
    func synchronizeCollectionView() {
        guard let collectionView = collectionView else {
            return
        }
        collectionView.reloadData()
    }
}

// MARK: UITableViewDelegate
extension SBPhotosViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < self.photoCollections.count {
            let album = self.photoCollections[indexPath.row]
            initializePhotosDataSource(album)
            updateAlbumTitle(album)
            synchronizeCollectionView()
            self.albumTitleView?.isSelected = false
            
            UIView.animate(withDuration: 0.35, animations: {
                self.albumsViewController.view.layer.transform = CATransform3DIdentity
                self.alphaView.isHidden = true
                self.albumTitleView?.albumButton.setImage(self.albumTitleView?.arrowDownImage, for: UIControlState.normal)
            }) 
        }
    }
}

// MARK: UIImagePickerControllerDelegate（拍照选中的逻辑有问题）
extension SBPhotosViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        
        var placeholder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
            placeholder = request.placeholderForCreatedAsset
            }, completionHandler: { success, error in
                guard let placeholder = placeholder, let asset = PHAsset.fetchAssets(withLocalIdentifiers: [placeholder.localIdentifier], options: nil).firstObject, success == true else {
                    picker.dismiss(animated: true, completion: nil)
                    return
                }
                
                dispatch_async_safely_to_main_queue {
                    self.selections.append(SBPhoto(asset: asset))
                    self.selectedIndexPaths.append(IndexPath.init(item: 1, section: 0))
                    self.updateDoneButton()
                    
                    dispatch_async_safely_to_queue(DispatchQueue.global(qos: .default), {
                        self.selectionClosure?(SBPhoto(asset: asset))
                    })
                    
                    picker.dismiss(animated: true, completion: nil)
                }
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: 确定item的大小
extension SBPhotosViewController {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if let collectionViewFlowLayout = collectionView?.collectionViewLayout as? SBCollectionViewLayout {
            let itemSpacing: CGFloat = settings.itemSpacing
            let cellsPerRow = settings.cellsPerRow(traitCollection.verticalSizeClass, traitCollection.horizontalSizeClass)
            
            collectionViewFlowLayout.itemSpacing = itemSpacing
            collectionViewFlowLayout.itemsPerRow = cellsPerRow
            
            self.imageSize = collectionViewFlowLayout.itemSize
            
            updateDoneButton()
        }
    }
}

extension SBPhotosViewController {
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let composedDataSource = composedDataSource, composedDataSource.dataSources[indexPath.section].isEqual(cameraDataSource) {
            let cameraController = UIImagePickerController()
            cameraController.allowsEditing = false
            cameraController.sourceType = .camera
            cameraController.delegate = self
            
            self.present(cameraController, animated: true, completion: nil)
            
            return false
        }
        return collectionView.isUserInteractionEnabled && selections.count < settings.maxNumberOfSelections
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //预览
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? SBCameraCell else {
            return
        }
        cell.startLiveBackground()
    }
}

// MARK: UICollectionViewDataSource
extension SBPhotosViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoCollection.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        UIView.setAnimationsEnabled(false)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SBPhotoCell.identifier, for: indexPath) as! SBPhotoCell
        cell.accessibilityIdentifier = "photo_cell_\(indexPath.item)"
        cell.settings = settings
        
        if cell.tag != 0 {
            photosManager.cancelImageRequest(PHImageRequestID(cell.tag))
        }
        if indexPath.item < photoCollection.count {
            if let photo = photoCollection[indexPath.item] {
                
                cell.tag = Int((photo.requestImage(imageSize,contentMode: imageContentMode)  { (result) in
                        cell.imageView.image = result
                    })!)
                cell.photo = photo
                cell.selectedButtonClick = { [unowned self](selected) in
                    if selected {
                        //选中
                        self.didSelectItem(indexPath)
                    }else {
                        //取消选中
                        self.didDeselectItem(indexPath)
                    }
                }
                if let asset = photoCollection[indexPath.item] {
                    if let index = selections.index(of: asset) {
                        cell.selectionString = String(index+1)
                        asset.selected = true
                        cell.selectedPhoto = true
                    } else {
                        cell.selectedPhoto = false
                        asset.selected = false
                    }
                }
            }
        }
        UIView.setAnimationsEnabled(true)
        return cell
    }
}

// MARK: 处理选中或取消选中的逻辑
private extension SBPhotosViewController {
    func didSelectItem(_ indexPath: IndexPath) {
        guard let cell = collectionView?.cellForItem(at: indexPath) as? SBPhotoCell, let photo = self.photoCollection[indexPath.item] else {
            return
        }
        cell.selectedPhoto = true
        photo.selected = true
        self.selections.append(photo)
        self.selectedIndexPaths.append(indexPath)
        
        cell.selectionString = String(self.selections.count)
        updateDoneButton()
        dispatch_async_safely_to_queue(DispatchQueue.global(qos: .default), {
            self.selectionClosure?(photo)
        })
    }
    
    func didDeselectItem(_ indexPath: IndexPath) {
        guard let cell = collectionView?.cellForItem(at: indexPath) as? SBPhotoCell, let photo = self.photoCollection[indexPath.item], let index = self.selections.index(of: photo) else {
            return
        }
        photo.selected = false
        cell.selectedPhoto = false
        self.selections.remove(at: index)
        self.selectedIndexPaths.remove(at: index)
        updateDoneButton()
        if selectedIndexPaths.count != 0 {
            UIView.setAnimationsEnabled(false)
            collectionView?.reloadItems(at: selectedIndexPaths)
            UIView.setAnimationsEnabled(true)
        }
        dispatch_async_safely_to_queue(DispatchQueue.global(qos: .default), {
            self.deselectionClosure?(photo)
        })
    }
}

