//
//  PlayerViewV2.swift
//  AVCamera
//
//  Created by Adaicon on 2025/4/14.
//

import Foundation
import AVFoundation
import CoreGraphics
import UIKit

class PlayerViewV2: UIView, UIGestureRecognizerDelegate {
    let renderView = {
        let image = UIImage(named: "image")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    var delegate: PlayerViewDelegate?
    
    let viewC = UIView()
    
    var maxDurtion = Double.greatestFiniteMagnitude
    
    var panGes: UIPanGestureRecognizer?
    var tapGes: UITapGestureRecognizer?
    var pinchGes: UIPinchGestureRecognizer?
    
    var lastOffset: CGPoint = .zero
    var index: Int = 0
    var touchPoint: CGPoint = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        
        setupSubviews()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubviews() {
        self.addSubview(renderView)
        
        var frame = self.bounds
        if let imageSize = renderView.image?.size {
            frame = CGRect(x: 0, y: 0, width: frame.height * imageSize.width / imageSize.height, height: frame.height)
        }
        renderView.frame = frame
        renderView.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
    }
    
    func setupGestures() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        pan.maximumNumberOfTouches = 1
        pan.delegate = self
        self.addGestureRecognizer(pan)
        panGes = pan
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        tap.delegate = self
        self.addGestureRecognizer(tap)
        tapGes = tap
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        pinch.delegate = self
        self.addGestureRecognizer(pinch)
        pinchGes = pinch
    }
    
    func seekToZero() {
        
    }
    
    // MARK: gesture
    
    @objc func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        print("tap")
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let offset = gesture.translation(in: gesture.view)
        switch gesture.state {
        case .began:
            lastOffset = offset
        case .changed:
            let deltaX = (offset.x - lastOffset.x)
            let deltaY = (offset.y - lastOffset.y)
            var currentOffset = CGPoint(x: deltaX, y: deltaY)
            currentOffset = boundaryDetect(childView: renderView, offset: currentOffset)
            renderView.transform = CGAffineTransformTranslate(renderView.transform, currentOffset.x, currentOffset.y)
            lastOffset = offset
        default:
            lastOffset = .zero
        }
    }
    
    func boundaryDetect(childView: UIView, offset: CGPoint) -> CGPoint {
        let frame = childView.frame
        let bounds = self.bounds

        var deltaX = offset.x / childView.transform.a
        var deltaY = offset.y / childView.transform.a
        
        if frame.minX + deltaX >= 0 { // 检查左边界
            deltaX = -frame.minX
        } else if frame.maxX + deltaX <= bounds.width { // 检查右边界
            deltaX = bounds.width - frame.maxX
        }

        if frame.minY + deltaY >= 0 { // 检查上边界
            deltaY = -frame.minY
        } else if frame.maxY + deltaY <= bounds.height { // 检查下边界
            deltaY = bounds.height - frame.maxY
        }

        return CGPoint(x: deltaX, y: deltaY)
    }
    
    @objc func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        guard let view = gesture.view else { return }

        var scale = gesture.scale
        
        if gesture.state == .began {
            touchPoint = gesture.location(in: view)
            viewC.center = touchPoint
            
            touchPoint = renderView.convert(touchPoint, from: self)
            let frame = renderView.frame
            renderView.layer.anchorPoint = CGPoint(x: touchPoint.x / renderView.bounds.width, y: touchPoint.y / renderView.bounds.height)
            renderView.frame = frame
        }
        
        if gesture.state == .changed {
            if scale * renderView.transform.a < 1.0 {
                scale = 1.0 / renderView.transform.a
            }
            renderView.transform = renderView.transform.scaledBy(x: scale, y: scale)
            let offset = boundaryDetect(childView: renderView, offset: CGPoint(x: 0, y: 0))
            renderView.transform = renderView.transform.translatedBy(x: offset.x, y: offset.y)
        }
        
        if gesture.state == .ended {
            let frame = renderView.frame
            renderView.layer.anchorPoint = CGPoint(x: 0.5, y:0.5)
            renderView.frame = frame
        }
        gesture.scale = 1.0  // 重置手势缩放比例
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

