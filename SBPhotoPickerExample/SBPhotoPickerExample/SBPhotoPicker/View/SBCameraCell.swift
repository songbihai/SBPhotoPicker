//
//  SBCameraCell.swift
//  SBPhotoPickerExample
//
//  Created by 宋碧海 on 16/11/1.
//  Copyright © 2016年 songbihai. All rights reserved.
//

import UIKit
import AVFoundation

class SBCameraCell: UICollectionViewCell {
    static let identifier: String = "kSBCameraCell"
    fileprivate var imageView: UIImageView!
    fileprivate var cameraBackground: UIView!
    var takePhotoIcon: UIImage? {
        didSet {
            imageView.image = takePhotoIcon
            imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    var settings: SBPhotoPickerSettings? {
        didSet {
            if let setting = settings {
                if !setting.takeCaremra {
                    contentView.backgroundColor = UIColor.gray
                    return
                }
            }
            guard AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .authorized else {
                return
            }
            
            do {
                session = AVCaptureSession()
                session?.sessionPreset = AVCaptureSessionPresetMedium
                
                let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
                let input = try AVCaptureDeviceInput(device: device)
                session?.addInput(input)
                
                if let captureLayer = AVCaptureVideoPreviewLayer(session: session) {
                    captureLayer.frame = bounds
                    captureLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                    cameraBackground.layer.addSublayer(captureLayer)
                    
                    self.captureLayer = captureLayer
                }
            } catch {
                session = nil
            }
        }
    }
    
    var session: AVCaptureSession?
    var captureLayer: AVCaptureVideoPreviewLayer?
    let sessionQueue = DispatchQueue(label: "AVCaptureVideoPreviewLayer", attributes: [])
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addAllSubviews()
    }
    
    fileprivate func addAllSubviews() {
        cameraBackground = UIView()
        cameraBackground.translatesAutoresizingMaskIntoConstraints = false
        cameraBackground.backgroundColor = UIColor.white
        contentView.addSubview(cameraBackground)
        
        contentView.addConstraint(NSLayoutConstraint.init(item: cameraBackground, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: cameraBackground, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: cameraBackground, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: cameraBackground, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1.0, constant: 0))
        
        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        
        contentView.addConstraint(NSLayoutConstraint.init(item: imageView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: imageView, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint.init(item: imageView, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1.0, constant: 0))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        captureLayer?.frame = bounds
    }
    
    func startLiveBackground() {
        sessionQueue.async { () -> Void in
            self.session?.startRunning()
        }
    }
    
    func stopLiveBackground() {
        sessionQueue.async { () -> Void in
            self.session?.stopRunning()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
