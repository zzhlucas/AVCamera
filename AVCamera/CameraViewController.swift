//
//  CameraViewController.swift
//  AVCamera
//
//  Created by Adaicon on 2025/2/16.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    var cameraView: UIView?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.white
        setupCameraView()
        setupCamera()
    }
    
    func setupCameraView() {
        let width = self.view.frame.width
        let height = width * 16.0 / 9.0
        
        cameraView = UIView(frame: CGRect(x: 0, y: 44, width: width, height: height))
        cameraView?.backgroundColor = UIColor.black
        
        if let view = cameraView {
            self.view.addSubview(view)
        }
    }
    
    func setupCamera() {
        var session = AVCaptureSession()
                        
        guard let cameraDevice = AVCaptureDevice.default(for: .video) else {
            return
        }
        
        guard let cameraInput = try? AVCaptureDeviceInput(device: cameraDevice) else {
            return
        }
        
        if session.canAddInput(cameraInput) {
            session.addInput(cameraInput)
        }
        
        var imageOutput = AVCapturePhotoOutput()
        if session.canAddOutput(imageOutput) {
            session.addOutput(imageOutput)
        }
    }
}


