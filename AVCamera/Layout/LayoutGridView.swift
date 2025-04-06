//
//  LayoutGridView.swift
//  AVCamera
//
//  Created by Adaicon on 2025/4/5.
//

import Foundation
import UIKit

public class LayoutGridView: UIView {
    let tapGes = UITapGestureRecognizer()
    let panGes = UIPanGestureRecognizer()
    let pinchGes = UIPinchGestureRecognizer()
    var assetView :LayoutAssetView!
    var lastOffset: CGPoint = .zero
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.clipsToBounds = true
        
        addGestureRecognizer(tapGes)
        tapGes.addTarget(self, action: #selector(handleTapGesture(_:)))
        self.addGestureRecognizer(tapGes)
        
        addGestureRecognizer(panGes)
        panGes.addTarget(self, action: #selector(handlePanGesture(_:)))
        self.addGestureRecognizer(panGes)
        
        addGestureRecognizer(pinchGes)
        pinchGes.addTarget(self, action: #selector(handlePinchGesture(_:)))
        self.addGestureRecognizer(pinchGes)
        
        assetView = LayoutAssetView(frame: self.bounds)
        self.addSubview(assetView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: gesture
    
    @objc func handleTapGesture(_ gesture: UIGestureRecognizer) {
        print("handleTapGesture")
    }
    
    /**
     处理平移：
     缩放后，获取到的平移是基于缩放后的坐标系统的，也就是说默认 x scale
     比如缩放前，获取到的数据offset=(100,50)；缩放 2 倍后，获取到的数据 offset=(100*2, 50*2)
     */
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let offset = gesture.translation(in: self)
        switch gesture.state {
        case .began:
            lastOffset = offset
        case .changed:
            var deltaX = (offset.x - lastOffset.x) / assetView.transform.a
            var deltaY = (offset.y - lastOffset.y) / assetView.transform.a
            
            let frame = assetView.frame
            let bounds = self.bounds
            
            /**
             if left > 0 {
                left = 0
             } else if right < width {
                right = width
             }
             
             if top > 0 {
                top = 0
             } else if bottom < height {
                bottom = height
             }
             */
            
            if frame.minX + deltaX > 0 { // 检查左边界
                deltaX = -frame.minX
            } else if frame.maxX + deltaX < bounds.width { // 检查右边界
                deltaX = bounds.width - frame.maxX
            }
            
            if frame.minY + deltaY > 0 { // 检查上边界
                deltaY = -frame.minY
            } else if frame.maxY + deltaY < bounds.height { // 检查下边界
                deltaY = bounds.height - frame.maxY
            }
            
            assetView.transform = CGAffineTransformTranslate(assetView.transform, deltaX, deltaY)
            lastOffset = offset
        default:
            lastOffset = .zero
        }
    }
    
    /**
     处理缩放：
     缩放后，再 offset。offset 是基于原坐标系的，需要进行转换
     例如 scale 放大 2 倍, offset=(100, 50)，则应进行如下设置
     view.transform = CGAffineTransformMakeScale(2.0, 2.0) // 先 scale 两倍
     view.transfrom = GAffineTransformTranslate(view.transform, 100 * 2, 50 * 2) // 再基于原坐标 offset(100, 50)
     */
    @objc func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        var deltaScale = gesture.scale
        switch gesture.state {
        case .changed:
            if deltaScale * assetView.transform.a < 1.0 {
                deltaScale = 1.0 / assetView.transform.a
            }
            assetView.transform = CGAffineTransformScale(assetView.transform, deltaScale, deltaScale)
        default:
            print("")
        }
        gesture.scale = 1.0
    }
}
