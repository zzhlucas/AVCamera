//
//  PassthroughView.swift
//  AVCamera
//
//  Created by Adaicon on 2025/3/15.
//

import UIKit

class PassthroughView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view == self {
            return nil
        }
        return nil
    }
}
