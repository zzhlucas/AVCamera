//
//  TestViewController.swift
//  AVCamera
//
//  Created by Adaicon on 2025/4/13.
//

import UIKit
import Foundation

public class TestViewController: UIViewController {
    let viewA = UIView()
    let viewB = UIView()
    let viewC = UIView()
    var initialCenter = CGPoint()
    var pinchCenter: CGPoint = .zero

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置 viewA 并添加到主视图
        viewA.frame = CGRect(x: 50, y: 100, width: 300, height: 300)
        viewA.backgroundColor = .lightGray
        self.view.addSubview(viewA)

        // 设置 viewB 并添加到 viewA
        viewB.frame = CGRect(x: 50, y: 50, width: 200, height: 200)
        viewB.backgroundColor = .red
        viewA.addSubview(viewB)

        // 添加 UIPinchGestureRecognizer 到 viewA
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        viewA.addGestureRecognizer(pinchGesture)
        
        viewC.frame = CGRect(x: 0, y: 0, width: 2, height: 2)
        viewC.backgroundColor = .green
        viewA.addSubview(viewC)

        // 保存初始中心点
        initialCenter = viewB.center
    }

    @objc func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        guard let view = gesture.view else { return }

        let scale = gesture.scale
        
        if gesture.state == .began {
            pinchCenter = gesture.location(in: view)
            viewC.center = pinchCenter
        }
        
        if gesture.state == .changed {
            viewB.anchorPoint = CGPoint(x: 1, y: 1)
            performZoom(view: viewB, scale: scale, center: pinchCenter)
            viewB.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        }
        gesture.scale = 1.0  // 重置手势缩放比例
    }

    func performZoom(view: UIView, scale: CGFloat, center: CGPoint) {
        // 将捏合中心点转换为 viewB 的本地坐标系
        let anchorInView = view.convert(center, from: view.superview)
        print("anchorInView = \(anchorInView), bounds = \(view.bounds)")

        // 将捏合中心点转换为 viewB 的父视图坐标系
        let anchorInSuperview = view.convert(anchorInView, to: view.superview)

        // 应用缩放
        view.transform = view.transform.scaledBy(x: scale, y: scale)

        // 计算缩放后的捏合中心点
        let newAnchorInSuperview = view.convert(anchorInView, to: view.superview)

        // 计算由于缩放引起的平移
        let translation = CGPoint(x: anchorInSuperview.x - newAnchorInSuperview.x,
                                  y: anchorInSuperview.y - newAnchorInSuperview.y)

        // 应用平移补偿
        view.transform = view.transform.translatedBy(x: translation.x, y: translation.y)
    }
}
