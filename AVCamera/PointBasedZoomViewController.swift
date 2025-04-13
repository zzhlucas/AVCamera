//
//  PointBasedZoomViewController.swift
//  AVCamera
//
//  Created by Adaicon on 2025/4/13.
//

import Foundation
import UIKit

public class PointBasedZoomViewController: UIViewController, UIGestureRecognizerDelegate {
    let viewA = UIView()
    let viewC = UIView()
    var initialCenter = CGPoint()
    var pinchCenter: CGPoint = .zero
    var lastOffset: CGPoint = .zero

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置 viewA 并添加到主视图
        viewA.frame = CGRect(x: 50, y: 400, width: 100, height: 100)
        viewA.backgroundColor = .lightGray
        self.view.addSubview(viewA)

        // 添加 UIPinchGestureRecognizer 到 viewA
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        viewA.addGestureRecognizer(pinchGesture)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        pan.maximumNumberOfTouches = 1
        pan.delegate = self
        viewA.addGestureRecognizer(pan)
        
        viewC.frame = CGRect(x: 0, y: 0, width: 4, height: 4)
        viewC.backgroundColor = .green
        viewA.addSubview(viewC)
    }

    @objc func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        guard let view = gesture.view else { return }

        let scale = gesture.scale
        
        if gesture.state == .began {
            pinchCenter = gesture.location(in: view)
            viewC.center = pinchCenter
            
            let frame = viewA.frame
            viewA.layer.anchorPoint = CGPoint(x: pinchCenter.x / viewA.bounds.width, y: pinchCenter.y / viewA.bounds.height)
            viewA.frame = frame
        }
        
        if gesture.state == .changed {
            viewA.transform = viewA.transform.scaledBy(x: scale, y: scale)
        }
        
        if gesture.state == .ended {
            let frame = viewA.frame
            viewA.layer.anchorPoint = CGPoint(x: 0.5, y:0.5)
            viewA.frame = frame
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
            lastOffset = offset
            viewA.transform = CGAffineTransformTranslate(viewA.transform, deltaX, deltaY)
        default:
            lastOffset = .zero
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
