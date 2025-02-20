//
//  CameraController.swift
//  AVCamera
//
//  Created by Adaicon on 2025/2/19.
//

import Foundation
import AVFoundation

protocol CameraControllerDelegate: AnyObject {
    func deviceConfigurationFailed(error: NSError?)
    func mediaCaptureFailed(error: NSError?)
    func assetLibraryWriteFailed(error: NSError?)
}

public class CameraController: NSObject {
    weak var delegate: CameraControllerDelegate?
    let captureSession: AVCaptureSession
    
    private var activeVideoInput: AVCaptureDeviceInput?
    private let photoOutput: AVCapturePhotoOutput
    private let movieOutput: AVCaptureMovieFileOutput
    private var photoOutputSetting: AVCapturePhotoSettings
    
    let videoQueue: DispatchQueue
    
    private(set) var cameraCount: Int = 0
    private(set) var cameraHasTorch: Bool = false
    private(set) var cameraHasFlash: Bool = false
    private(set) var cameraSupportsTapToFocus: Bool = false
    private(set) var cameraSupportsTapToExpose: Bool = false
    
    var torchMode: AVCaptureDevice.TorchMode?
    var flashMode: AVCaptureDevice.FlashMode?
    
    public override init() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        photoOutput = AVCapturePhotoOutput()
        movieOutput = AVCaptureMovieFileOutput()
        photoOutputSetting = AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])
        
        videoQueue = DispatchQueue(label: "com.avcamera.VideoQueue")
        
        super.init()
    }
    
    // session configuration
    func setupSession() throws -> Bool {
        guard let videoDevice = AVCaptureDevice.default(for: .video) else {
            return false
        }
        guard let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            return false
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
            activeVideoInput = videoInput
        }
        
        guard let audioDevice = AVCaptureDevice.default(for: .audio) else {
            return false
        }
        guard let audioInput = try? AVCaptureDeviceInput(device: audioDevice) else {
            return false
        }
        
        if captureSession.canAddInput(audioInput) {
            captureSession.addInput(audioInput)
        }
        
        
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }
        
        return true
    }
    
    func startSession() {
        if !captureSession.isRunning {
            videoQueue.async { [self] in // 为什么要放在异步队列里呢，耗时函数，会阻塞主线程
                captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        if captureSession.isRunning {
            videoQueue.async { [self] in
                captureSession.stopRunning()
            }
        }
    }
    
    // camera device support
    func switchCameras() -> Bool {
        if canSwitchCameras() == false {
            return false
        }
        
        guard let switchDevice = inactiveCamera(),
              let videoInput = try? AVCaptureDeviceInput(device: switchDevice),
              let currentInput = activeVideoInput else {
            return false
        }
                
        captureSession.beginConfiguration()
        captureSession.removeInput(currentInput)
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
            activeVideoInput = videoInput
        } else {
            captureSession.addInput(currentInput)
        }
        
        captureSession.commitConfiguration()
        
        return true
    }
    
    func canSwitchCameras() -> Bool {
        if let backDevice = cameraWithPosition(devicePosition: .back),
           let frontDevice = cameraWithPosition(devicePosition: .front) {
            return true
        }
        return false
    }
    
    func focusAtPoint(point: CGPoint) {
        
    }
    
    func exposeAtPoint(point: CGPoint) {
        
    }
    
    func resetFocusAndExpostModes() {
        
    }
    
    // media
    func capturePhoto() {
        
    }
    
    func startRecording() {
        
    }
    
    func stopRecording() {
        
    }
    
    func isRecording() -> Bool {
        return true
    }
    
    // private
    private func activeCamera() -> AVCaptureDevice? {
        return activeVideoInput?.device
    }
    
    private func inactiveCamera() -> AVCaptureDevice? {
        var position: AVCaptureDevice.Position
        if activeCamera()?.position == .back {
            position = .front
        } else {
            position = .back
        }
        return cameraWithPosition(devicePosition: position)
    }
    
    private func cameraWithPosition(devicePosition: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: devicePosition)
        
        if discoverySession.devices.count > 0 {
            return discoverySession.devices.first
        }
        return nil
    }
}
