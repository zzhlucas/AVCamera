//
//  CameraPreviewView.swift
//  AVCamera
//
//  Created by Adaicon on 2025/2/19.
//

import Foundation
import AVFoundation
import UIKit

protocol CameraPreviewViewDelegate: AnyObject {
    func tappedToFocusAtPoint(point: CGPoint)
    func tappedToExposeAtPoint(point: CGPoint)
    func tappedToResetFocusAndExpose()
}

public class CameraPreviewView: UIView  {
    var session: AVCaptureSession? {
        get {
            if let value = self.layer as? AVCaptureVideoPreviewLayer {
                return value.session
            }
            return nil
        }
        
        set(newValue) {
            if let value = self.layer as? AVCaptureVideoPreviewLayer {
                value.session = newValue
            }
        }
    }
    weak var delegate: CameraPreviewViewDelegate?
    
    var tapToFocusEnabled: Bool = false
    var tapToExposeEnabled: Bool = false
    
    public override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    func captureDevicePointForPoint(point: CGPoint) -> CGPoint {
        if let layer = self.layer as? AVCaptureVideoPreviewLayer {
            return layer.layerPointConverted(fromCaptureDevicePoint: point)
        }
        return .zero
    }
}
