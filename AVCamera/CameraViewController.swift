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

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.white
        setupCameraView()
        
        if let result = try? cameraController.setupSession(),
           result == true {
            cameraPreviewView.session = cameraController.captureSession
            cameraController.startSession()
        }
    }
    
    func setupCameraView() {
        let width = self.view.frame.width
        let height = width * 16.0 / 9.0
        cameraPreviewView.frame = CGRect(x: 0, y: 44, width: width, height: height)
        cameraPreviewView.backgroundColor = UIColor.black
        self.view.addSubview(cameraPreviewView)
    }
}


