//
//  CameraController.swift
//  AVCamera
//
//  Created by Adaicon on 2025/2/19.
//

import Foundation
import AVFoundation
import UIKit
import Photos

protocol CameraControllerDelegate: AnyObject {
    func deviceConfigurationFailed(error: NSError?)
    func mediaCaptureFailed(error: NSError?)
    func assetLibraryWriteFailed(error: NSError?)
    func didCapturePhoto(timeGap: TimeInterval, size: CGSize)
}

public class CameraController: NSObject {
    weak var delegate: CameraControllerDelegate?
    let captureSession: AVCaptureSession
    var isCaptureLivePhoto: Bool = false
    
    private var activeVideoInput: AVCaptureDeviceInput?
    private let photoOutput: AVCapturePhotoOutput
    private let movieOutput: AVCaptureMovieFileOutput
    private var currentDate = Date().timeIntervalSince1970
    
    private var livePhotoMovieURL: URL?
    
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
        captureSession.sessionPreset = .photo
        
        photoOutput = AVCapturePhotoOutput()
        movieOutput = AVCaptureMovieFileOutput()
        
        videoQueue = DispatchQueue(label: "com.avcamera.serial.VideoQueue")
        
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
    
    func setupLivePhoto(isUseLivePhoto: Bool) {
        if isUseLivePhoto == isCaptureLivePhoto {
            return
        }
        if (isUseLivePhoto) {
            stopSession()
            videoQueue.async { [self] in
                captureSession.removeOutput(movieOutput)
                photoOutput.isLivePhotoCaptureEnabled = photoOutput.isLivePhotoCaptureSupported
            }
            startSession()
        } else {
            stopSession()
            videoQueue.async { [self] in
                if captureSession.canAddOutput(movieOutput) {
                    captureSession.addOutput(movieOutput)
                }
                photoOutput.isLivePhotoCaptureEnabled = false
            }
            startSession()
        }
        isCaptureLivePhoto = isUseLivePhoto
    }
    
    func startSession() {
        videoQueue.async { [self] in
            if !captureSession.isRunning {
                captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        videoQueue.async { [self] in
            if captureSession.isRunning {
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
        if let _ = cameraWithPosition(devicePosition: .back),
           let _ = cameraWithPosition(devicePosition: .front) {
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
        if isCaptureLivePhoto {
            captureLivePhoto()
        } else {
            captureStillImage()
        }
    }
    
    private func captureLivePhoto() {
        guard let device = activeCamera() else {
            return
        }
        
        let photoOutputSetting = AVCapturePhotoSettings()
        photoOutputSetting.flashMode = .auto
        
        // 配置 live photo 参数
        let livePhotoMovieFileName = UUID().uuidString
        let livePhotoMovieURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(livePhotoMovieFileName).mov")
        
        self.livePhotoMovieURL = livePhotoMovieURL
                
        photoOutputSetting.livePhotoMovieFileURL = livePhotoMovieURL
        photoOutputSetting.embedsDepthDataInPhoto = false
        
        // 触发拍摄
        photoOutput.capturePhoto(with: photoOutputSetting, delegate: self)
        
    }
    
    private func captureStillImage() {
        guard let device = activeCamera() else {
            return
        }
        
        do {
            // 锁定设备以配置格式
            try device.lockForConfiguration()
            // 遍历设备支持的所有格式
            for format in device.formats {
                let description = format.formatDescription
                // 获取当前格式下的最大照片尺寸
                let dimensions = CMVideoFormatDescriptionGetDimensions(description)
                let maxWidth = Int(dimensions.width)
                let maxHeight = Int(dimensions.height)
                print("最大照片尺寸 - 宽度: \(maxWidth), 高度: \(maxHeight)")
            }
            // 解锁设备
            device.unlockForConfiguration()
        } catch {
            print("配置设备时出错: \(error)")
            return
        }
        
        let photoOutputSetting = AVCapturePhotoSettings()
        photoOutputSetting.flashMode = .auto
//        photoOutputSetting.maxPhotoDimensions = CMVideoDimensions(width: 1080, height: 1920)
        currentDate = Date().timeIntervalSince1970
        print("date = \(currentDate)")
        photoOutput.capturePhoto(with: photoOutputSetting, delegate: self)
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
    
    // MARK: - 保存到相册
    private func saveLivePhotoToAlbum(photoURL: URL, videoURL: URL) {
        PHPhotoLibrary.shared().performChanges {
            let creationRequest = PHAssetCreationRequest.forAsset()
            let options = PHAssetResourceCreationOptions()
            
            // 添加照片和视频资源
            creationRequest.addResource(with: .photo, fileURL: photoURL, options: nil)
            creationRequest.addResource(with: .pairedVideo, fileURL: videoURL, options: options)
        } completionHandler: { success, error in
            DispatchQueue.main.async {
                if success {
                    print("Live Photo保存成功")
                } else {
                    print("保存失败: \(error?.localizedDescription ?? "未知错误")")
                }
            }
        }
    }
    
    private func saveImageToAlbum(image: UIImage) {
        PHPhotoLibrary.shared().performChanges({
            // 创建一个请求来保存图片，暂时保存
//            let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { [weak self] success, error in
            if let error = error {
                // 保存失败
                print("保存图片到相册时出错: \(error.localizedDescription)")
            } else if success {
                // 保存成功
                print("图片已成功保存到相册")
            }
        }
    }
    
    private func getMaxPhotoSize(for device: AVCaptureDevice) -> CGSize? {
        var maxSize: CGSize = .zero
        
        do {
            try device.lockForConfiguration()
            
            // 遍历所有支持的格式
            for format in device.formats {
                let dimensions = CMVideoFormatDescriptionGetDimensions(
                    format.formatDescription
                )
                let size = CGSize(width: Int(dimensions.width), height: Int(dimensions.height))
                
                // 比较并记录最大尺寸
                if size.width * size.height > maxSize.width * maxSize.height {
                    maxSize = size
                }
            }
            
            device.unlockForConfiguration()
            
            return maxSize.width > 0 ? maxSize : nil
            
        } catch {
            return nil
        }
    }
}

extension CameraController: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let _ = error {
            return
        }
        if isCaptureLivePhoto {
            guard let photoData = photo.fileDataRepresentation() else { return }
            let photoURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("temp_photo.jpg")
            try? photoData.write(to: photoURL)
        } else {
            if let imageData = photo.fileDataRepresentation(),
               let image = UIImage(data: imageData) {
                let time = Date().timeIntervalSince1970 - currentDate
                self.delegate?.didCapturePhoto(timeGap: time, size: CGSize(width: image.size.width, height: image.size.height))
                PHPhotoLibrary.requestAuthorization { [weak self] status in
                    switch status {
                    case.authorized:
                        // 权限已授予，保存图片
                        self?.saveImageToAlbum(image: image)
                    case.denied,.restricted:
                        // 权限被拒绝或受限
                        print("没有权限访问相册")
                    case.notDetermined:
                        // 权限未确定，这种情况通常不会在这里出现
                        print("相册权限未确定")
                    case .limited:
                        print("相册权限是limited")
                    @unknown default:
                        break
                    }
                }
            }
        }
    }
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingLivePhotoToMovieFileAt outputFileURL: URL, duration: CMTime, photoDisplayTime: CMTime, resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        // 处理视频文件（已自动保存到指定URL）
        // 当视频部分也处理完成后，保存Live Photo
        if let livePhotoMovieURL = self.livePhotoMovieURL {
            let photoURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("temp_photo.jpg")
            saveLivePhotoToAlbum(photoURL: photoURL, videoURL: livePhotoMovieURL)
            self.livePhotoMovieURL = nil
        }
    }
}
