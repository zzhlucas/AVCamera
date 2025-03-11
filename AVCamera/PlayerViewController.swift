//
//  PlayerViewController.swift
//  AVCamera
//
//  Created by Adaicon on 2025/3/11.
//

import Foundation
import UIKit
import AVFoundation

class PlayerViewController: UIViewController {
    
    var playerItemObservation: NSKeyValueObservation?
    
    var player: AVPlayer!
    var playerItem: AVPlayerItem!
    
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
    
    deinit {
        playerItemObservation?.invalidate()
    }
    
    override func viewDidLoad() {
        self.view.backgroundColor = .gray
        
        guard let assetURL = Bundle.main.url(forResource: "video", withExtension: "MOV") else {
            return
        }
        let asset = AVAsset(url: assetURL)
        
        playerItem = AVPlayerItem(asset: asset)
        playerItem.addObserver(self, forKeyPath:"status", options: [NSKeyValueObservingOptions.old, NSKeyValueObservingOptions.new] , context: nil)
        player = AVPlayer(playerItem: playerItem)
//        player?.play()
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = CGRect(x: 0, y: 44, width: self.view.bounds.width, height: self.view.bounds.width * 16.0 / 9.0)
        
        self.view.layer.addSublayer(playerLayer)
        
        backButton.addTarget(self, action: #selector(clickBackButton), for: .touchUpInside)
        self.view.addSubview(backButton)
    }
    
    
    // MARK: private
    
    @objc func clickBackButton() {
        self.dismiss(animated: true)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if playerItem.status == .readyToPlay {
            print("readyToPlay")
            // 设置播放监听
            // 监听时间
            player.play()
        }
    }
}
