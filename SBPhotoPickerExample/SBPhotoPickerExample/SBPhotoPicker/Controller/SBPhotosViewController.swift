//
//  SBPhotosViewController.swift
//  SBPhotoPickerExample
//
//  Created by 宋碧海 on 16/11/1.
//  Copyright © 2016年 songbihai. All rights reserved.
//

import UIKit
import Photos


final class SBPhotosViewController: UICollectionViewController {
    var selectionClosure: ((_ photo: SBPhoto) -> Void)?
    var deselectionClosure: ((_ photo: SBPhoto) -> Void)?
    var cancelClosure: ((_ photos: [SBPhoto]) -> Void)?
    var finishClosure: ((_ photos: [SBPhoto]) -> Void)?
    
    let settings: SBPhotoPickerSettings
    
    var selectedIndexPaths = [IndexPath]()
    var selections = [SBPhoto]()
    var photoCollection: SBPhotoCollection! {
        didSet {
            guard let fetchResult = photoCollection.fetchResult else {
                return
            }
            self.fetchResult = fetchResult
        }
    }
    var photoCollections: [SBPhotoCollection]!
    var fetchResult: PHFetchResult<PHAsset>!
    var cameraDataSource: SBCameraCollectionViewDataSource
    
    fileprivate var selectedAlbumIndex: Int = 0
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
    fileprivate var albumsDataSource: SBAlbumTableViewDataSource {
        didSet {
            
        }
    }
    
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

    override var prefersStatusBarHidden : Bool {
        return settings.fullscreen
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
        albumsViewController.view.frame = CGRect(x: 0, y: -view.bounds.height + (settings.fullscreen ? 44 : 64), width: view.bounds.width, height: view.bounds.height - (settings.fullscreen ? 44 : 64))
        view.addSubview(albumsViewController.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateDoneButton()
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

// MARK: PHPhotoLibraryChangeObserver
extension SBPhotosViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let collectionView = collectionView else {
            return
        }
        
        dispatch_async_safely_to_main_queue {
            if let photosChanges = changeInstance.changeDetails(for: self.fetchResult) {
                
                if photosChanges.hasIncrementalChanges && ((photosChanges.removedIndexes?.count ?? 0) > 0 || (photosChanges.insertedIndexes?.count ?? 0) > 0 || (photosChanges.changedIndexes?.count ?? 0) > 0) {
                    
                    self.fetchResult = photosChanges.fetchResultAfterChanges
                    let title = self.photoCollection.title
                    self.photoCollection = SBPhotoCollection()
                    self.photoCollection.title = title
                    self.selectedIndexPaths = [IndexPath]()
                    self.fetchResult.enumerateObjects(using: { [unowned self](asset, idx, stop) in
                        var assets = self.selections.map({ (photo) -> PHAsset in
                            return photo.asset!
                        })
                        photosChanges.removedObjects.forEach({ (asset) in
                            if let index = assets.index(of: asset) {
                                assets.remove(at: index)
                                self.selections.remove(at: index)
                            }
                        })
                        let photo = SBPhoto(asset: asset)
                        if assets.contains(asset) {
                            photo.selected = true
                            self.selectedIndexPaths.append(IndexPath.init(item: idx, section: self.settings.takePhotos && self.cameraAvailable ? 1 : 0))
                        }else {
                            photo.selected = false
                        }
                        self.photoCollection.append(photo)
                    })
                    self.photoCollections[self.selectedAlbumIndex] = self.photoCollection
                    self.albumsDataSource = SBAlbumTableViewDataSource.init(photoCollections: self.photoCollections)
                    self.albumsViewController.tableView.dataSource = self.albumsDataSource
                    self.albumsViewController.tableView.reloadData()
                    self.updateDoneButton()
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
                        doneBarButtonTitle = btn.title(for: UIControlState())
                    }
                    
                    if let doneBarButtonTitle = doneBarButtonTitle {
                        if (self.selections.count == 1 && self.settings.maxNumberOfSelections == 1) {
                            btn.sb_setTitleWithoutAnimation("\(doneBarButtonTitle)", forState: UIControlState())
                        } else if self.selections.count > 0 {
                            btn.sb_setTitleWithoutAnimation("\(doneBarButtonTitle) (\(self.selections.count))", forState: UIControlState())
                        } else {
                            btn.sb_setTitleWithoutAnimation(doneBarButtonTitle, forState: UIControlState())
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
            selectedAlbumIndex = indexPath.row
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

// MARK: UIImagePickerControllerDelegate
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
                    self.selections.insert(SBPhoto(asset: asset), at: 0)
                    self.selectedIndexPaths.append(IndexPath.init(item: 0, section: (self.settings.takePhotos && self.cameraAvailable) ? 1 : 0))
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
            self.updateDoneButton()
        }
    }
}

extension SBPhotosViewController {
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if let composedDataSource = composedDataSource, composedDataSource.dataSources[indexPath.section].isEqual(cameraDataSource) {
            guard selections.count < settings.maxNumberOfSelections else {
                self.showAlert("最多只能选择\(settings.maxNumberOfSelections)张", message: nil, cancel: "我知道了")
                return collectionView.isUserInteractionEnabled && selections.count < settings.maxNumberOfSelections
            }
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
        guard let cell = cell as? SBCameraCell, settings.takeCaremra else {
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
        if let photo = photoCollection[indexPath.item] {
            
            cell.tag = Int((photo.requestImage(imageSize,contentMode: imageContentMode)  { (result) in
                    cell.imageView.image = result
                })!)
            cell.photo = photo
            cell.selectedButtonClick = { [unowned self](selected) in
                if !selected {
                    //选中
                    self.didSelectItem(indexPath)
                }else {
                    //取消选中
                    self.didDeselectItem(indexPath)
                }
            }
            cell.selectedPhoto = photo.selected
            if photo.selected {
                let assets = selections.map({ (slectedPhoto) -> PHAsset in
                    return slectedPhoto.asset!
                })
                if let index = assets.index(of: photo.asset!) {
                    cell.selectionString = String(index+1)
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
        guard selections.count < settings.maxNumberOfSelections else {
            self.showAlert("最多只能选择\(settings.maxNumberOfSelections)张", message: nil, cancel: "我知道了")
            return
        }
        guard let cell = collectionView?.cellForItem(at: fixIndexPath(indexPath)) as? SBPhotoCell, let photo = self.photoCollection[fixIndexPath(indexPath).item] else {
            return
        }
        cell.selectedPhoto = true
        photo.selected = true
        self.selections.append(photo)
        self.selectedIndexPaths.append(fixIndexPath(indexPath))
        
        cell.selectionString = String(self.selections.count)
        self.updateDoneButton()
        dispatch_async_safely_to_queue(DispatchQueue.global(qos: .default), {
            self.selectionClosure?(photo)
        })
    }
    
    func didDeselectItem(_ indexPath: IndexPath) {
        let assets = self.selections.map { (selectedPhoto) -> PHAsset in
            return selectedPhoto.asset!
        }
        guard let cell = collectionView?.cellForItem(at: fixIndexPath(indexPath)) as? SBPhotoCell, let photo = self.photoCollection[fixIndexPath(indexPath).item], let index = assets.index(of: photo.asset!) else {
            return
        }
        photo.selected = false
        cell.selectedPhoto = false
        self.selections.remove(at: index)
        self.selectedIndexPaths.remove(at: index)
        self.updateDoneButton()
        synchronizeCollectionView()
        dispatch_async_safely_to_queue(DispatchQueue.global(qos: .default), {
            self.deselectionClosure?(photo)
        })
    }
    
    func fixIndexPath(_ indexPath: IndexPath) -> IndexPath {
//        if settings.takePhotos && cameraAvailable {
            return IndexPath(item: indexPath.item, section: 1)
//        }else {
//            return IndexPath(item: indexPath.item, section: indexPath.section)
//        }
    }
}

