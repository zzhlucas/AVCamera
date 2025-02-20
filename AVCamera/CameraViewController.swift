//
//  CameraViewController.swift
//  AVCamera
//
//  Created by Adaicon on 2025/2/16.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    let cameraPreviewView: CameraPreviewView = CameraPreviewView(frame: .zero)
    let cameraController: CameraController = CameraController()
    
    let takePhotoButton = UIButton(frame: .zero)
    let photoPresetButton = UIButton(frame: .zero)
    let highPresetButton = UIButton(frame: .zero)
    let timeLabel = UILabel(frame: .zero)

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        cameraController.delegate = self
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = .black
        
        takePhotoButton.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
        takePhotoButton.center = CGPoint(x: self.view.frame.width / 2.0, y: self.view.frame.height - 56)
        takePhotoButton.layer.cornerRadius = 28
        takePhotoButton.addTarget(self, action: #selector(takePhotoButtonTapped), for: .touchUpInside)
        takePhotoButton.backgroundColor = .white
        self.view.addSubview(takePhotoButton)
        setupCameraView()
        
        photoPresetButton.frame = CGRect(x: 0, y: 100, width: 150, height: 56)
        photoPresetButton.backgroundColor = .yellow.withAlphaComponent(0.5)
        photoPresetButton.setTitle("Preset.photo", for: .normal)
        photoPresetButton.addTarget(self, action: #selector(photoPresetButtonTapped), for: .touchUpInside)
        self.view.addSubview(photoPresetButton)
        
        highPresetButton.frame = CGRect(x: 200, y: 100, width: 150, height: 56)
        highPresetButton.backgroundColor = .yellow.withAlphaComponent(0.5)
        highPresetButton.setTitle("Prest.high", for: .normal)
        highPresetButton.addTarget(self, action: #selector(highPresetButtonTapped), for: .touchUpInside)
        self.view.addSubview(highPresetButton)
        
        timeLabel.frame = CGRect(x: 0, y: 200, width: self.view.frame.width, height: 56)
        timeLabel.backgroundColor = .yellow.withAlphaComponent(0.5)
        self.view.addSubview(timeLabel)
        
        if let result = try? cameraController.setupSession(),
           result == true {
            cameraPreviewView.session = cameraController.captureSession
            cameraController.startSession()
        }
    }
    
    @objc func takePhotoButtonTapped() {
        cameraController.capturePhoto()
    }
    
    @objc func photoPresetButtonTapped() {
        cameraController.captureSession.sessionPreset = .photo
    }
    
    @objc func highPresetButtonTapped() {
        cameraController.captureSession.sessionPreset = .high
    }
    
    func setupCameraView() {
        let width = self.view.frame.width
        let height = width * 16.0 / 9.0
        cameraPreviewView.frame = CGRect(x: 0, y: 44, width: width, height: height)
        cameraPreviewView.backgroundColor = UIColor.black
        self.view.addSubview(cameraPreviewView)
    }
}

extension CameraViewController: CameraControllerDelegate {
    func deviceConfigurationFailed(error: NSError?) {
        
    }
    
    func mediaCaptureFailed(error: NSError?) {
        
    }
    
    func assetLibraryWriteFailed(error: NSError?) {
        
    }
    
    func didCapturePhoto(timeGap: TimeInterval, size: CGSize) {
        timeLabel.text = String(format: "耗时：%.5f, 分辨率=\(size.width)x\(size.height)", timeGap)
    }
}
