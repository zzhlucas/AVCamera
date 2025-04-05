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
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        addGestureRecognizer(tapGes)
        tapGes.addTarget(self, action: #selector(handleTapGesture(_:)))
        
        addGestureRecognizer(panGes)
        tapGes.addTarget(self, action: #selector(handlePanGesture(_:)))
        
        addGestureRecognizer(pinchGes)
        tapGes.addTarget(self, action: #selector(handlePinchGesture(_:)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: gesture
    
    @objc func handleTapGesture(_ gesture: UIGestureRecognizer) {
        print("handleTapGesture")
    }
    
    @objc func handlePanGesture(_ gesture: UIGestureRecognizer) {
        print("handlePanGesture")
    }
    
    @objc func handlePinchGesture(_ gesture: UIGestureRecognizer) {
        print("handlePinchGesture")
    }
}
