//
//  TestViewControllerV2.swift
//  AVCamera
//
//  Created by Adaicon on 2025/4/14.
//

import UIKit
import Foundation

public class TestViewControllerV2: UIViewController, UIGestureRecognizerDelegate {
    let viewA = UIView()
    let viewB = {
        let image = UIImage(named: "image")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    let viewC = UIView()
    var touchPoint: CGPoint = .zero
    var lastOffset: CGPoint = .zero

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置 viewA 并添加到主视图
        viewA.frame = CGRect(x: 50, y: 100, width: 300, height: 300)
        viewA.backgroundColor = .lightGray
        self.view.addSubview(viewA)
        viewA.layer.masksToBounds = true

        // 设置 viewB 并添加到 viewA
        var frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        if let imageSize = viewB.image?.size {
            frame = CGRect(x: 0, y: 0, width: 300 * imageSize.width / imageSize.height, height: 300)
        }
        viewB.frame = frame
        viewB.center = CGPoint(x: 150, y: 150)
        viewB.backgroundColor = .red
        viewA.addSubview(viewB)

        // 添加 UIPinchGestureRecognizer 到 viewA
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        viewA.addGestureRecognizer(pinchGesture)
        pinchGesture.delegate = self
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        pan.maximumNumberOfTouches = 1
        pan.delegate = self
        viewA.addGestureRecognizer(pan)
        
        viewC.frame = CGRect(x: 0, y: 0, width: 2, height: 2)
        viewC.backgroundColor = .green
        viewA.addSubview(viewC)
    }

    @objc func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        guard let view = gesture.view else { return }

        var scale = gesture.scale
        
        if gesture.state == .began {
            touchPoint = gesture.location(in: view)
            viewC.center = touchPoint
            
            touchPoint = viewB.convert(touchPoint, from: viewA)
            let frame = viewB.frame
            viewB.layer.anchorPoint = CGPoint(x: touchPoint.x / viewB.bounds.width, y: touchPoint.y / viewB.bounds.height)
            viewB.frame = frame
        }
        
        if gesture.state == .changed {
            if scale * viewB.transform.a < 1.0 {
                scale = 1.0 / viewB.transform.a
            }
            viewB.transform = viewB.transform.scaledBy(x: scale, y: scale)
            let offset = boundaryDetect(childView: viewB, offset: CGPoint(x: 0, y: 0))
            viewB.transform = viewB.transform.translatedBy(x: offset.x, y: offset.y)
        }
        
        if gesture.state == .ended {
            let frame = viewB.frame
            viewB.layer.anchorPoint = CGPoint(x: 0.5, y:0.5)
            viewB.frame = frame
        }
        gesture.scale = 1.0  // 重置手势缩放比例
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
            currentOffset = boundaryDetect(childView: viewB, offset: currentOffset)
            viewB.transform = CGAffineTransformTranslate(viewB.transform, currentOffset.x, currentOffset.y)
            lastOffset = offset
        default:
            lastOffset = .zero
        }
    }
    
    func boundaryDetect(childView: UIView, offset: CGPoint) -> CGPoint {
        let frame = childView.frame
        let bounds = viewA.bounds

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
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
