//
//  LayoutContainerView.swift
//  AVCamera
//
//  Created by Adaicon on 2025/4/5.
//

import Foundation
import UIKit

public class LayoutContainerView: PassthroughView {
    let colorArr: [UIColor] = [.red.withAlphaComponent(0.5),
                               .green.withAlphaComponent(0.5),
                               .blue.withAlphaComponent(0.5),
                               .yellow.withAlphaComponent(0.5),
                               .gray.withAlphaComponent(0.5)]
    
    let rows = 1, columns = 2
    var viewArr = [LayoutGridView]()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        let baseWidth = self.bounds.width / Double(columns)
        let baseHeight = self.bounds.height / Double(rows)
        for i in 0..<rows {
            for j in 0..<columns {
                let x = baseWidth * Double(j)
                let y = baseHeight * Double(i)
                let w = baseWidth
                let h = baseHeight
                let view = LayoutGridView(frame: CGRect(x: x, y: y, width: w, height: h))
                view.backgroundColor = colorArr[(i+j) % 5]
                viewArr.append(view)
                self.addSubview(view)
            }
        }
    }
}
