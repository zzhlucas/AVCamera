//
//  PlayerViewController.swift
//  AVCamera
//
//  Created by Adaicon on 2025/3/11.
//

import Foundation
import UIKit
import AVFoundation

class PlayerViewController: UIViewController, PlayerViewDelegate {
    var playerContainerView = UIView()
    var interactionContainerView = PassthroughView()
    var playerViewArray = [PlayerViewV2]()
    
    let rows = 1, columns = 2
    
    let backButton = {
        var btn = UIButton(frame: CGRect(x: 44, y: 44, width: 44, height: 44))
        btn.setImage(UIImage(named: "back"), for: .normal)
        btn.backgroundColor = .red
        return btn
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        setupUI()
    }
    
    func setupUI() {
        self.view.backgroundColor = .gray
        
        let containerWidth = self.view.bounds.width
        let containerHeight = self.view.bounds.width * 16.0 / 9.0
        
        playerContainerView.frame = CGRect(x: 0, y: 44, width: containerWidth, height: containerHeight)
        self.view.addSubview(playerContainerView)
        
        let baseWidth = containerWidth / CGFloat(columns)
        let baseHeight = containerHeight / CGFloat(rows)
        
        for row in 0..<rows {
            for column in 0..<columns {
                let time = 2.0 * Double(row + column)
                DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: {
                    let frame = CGRect(x: baseWidth * CGFloat(column), y: baseHeight * CGFloat(row), width: baseWidth, height: baseHeight)
                    let view = PlayerViewV2(frame: frame)
                    view.index = row * self.columns + column
                    view.maxDurtion = 5.0
                    self.playerContainerView.addSubview(view)
                    
                    for i in 0..<self.playerViewArray.count {
                        self.playerViewArray[i].seekToZero()
                    }
                    
                    view.delegate = self
                    
                    self.playerViewArray.append(view)
                })
            }
        }
        
        interactionContainerView.frame = playerContainerView.frame
        self.view.addSubview(interactionContainerView)
        
        backButton.addTarget(self, action: #selector(clickBackButton), for: .touchUpInside)
        interactionContainerView.addSubview(backButton)
    }
    
    
    // MARK: private
    
    @objc func clickBackButton() {
        self.dismiss(animated: true)
    }
    
    // MARK: PlayerViewDelegate
    
    public func playerDidEnd() {
        for i in 0..<playerViewArray.count {
            playerViewArray[i].seekToZero()
        }
    }
}
