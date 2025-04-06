//
//  LayoutAssetView.swift
//  AVCamera
//
//  Created by Adaicon on 2025/4/5.
//

import Foundation
import UIKit
import AVFoundation

public class LayoutAssetView: PassthroughView {
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    
    var playEndNotificationToken: NSObjectProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        self.isUserInteractionEnabled = false
        setupPlayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupPlayer() {
        guard let assetURL = Bundle.main.url(forResource: "video", withExtension: "MOV") else {
            return
        }
        let asset = AVAsset(url: assetURL)
        
        var size: CGSize = .zero
        if let firstVideoTrack = asset.tracks.first {
            size = firstVideoTrack.naturalSize
        }
        
        let assetRatio = size.height / size.width
        let viewRatio = self.frame.height / self.frame.width
        let center = CGPoint(x: self.bounds.width / 2.0, y: self.bounds.height / 2.0)
        if assetRatio >= viewRatio {
            self.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: size.width / self.frame.width * self.frame.height)
        } else {
            self.frame = CGRect(x: 0, y: 0, width: size.height / self.frame.height * self.frame.width, height: self.frame.height)
        }
        self.center = center
        
        playerItem = AVPlayerItem(asset: asset)
        playerItem?.addObserver(self, forKeyPath:#keyPath(AVPlayerItem.status), options: [NSKeyValueObservingOptions.new] , context: nil)
        player = AVPlayer(playerItem: playerItem)
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        
        self.layer.addSublayer(playerLayer)
    }
    
    func seekToZero() {
        player?.seek(to: .zero)
        player?.play()
    }
    
    func addPlayerItemEndObserver() {
        guard let playerItem else {
            return
        }
        playEndNotificationToken = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: playerItem, queue: .main) { [weak self] _ in
            self?.seekToZero()
        }
    }
    
    deinit {
        if let playEndNotificationToken {
            NotificationCenter.default.removeObserver(playEndNotificationToken)
        }
    }
    
    // MARK: KVO
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayerItem.status) {
            DispatchQueue.main.async(execute: {
                if let status = change?[.newKey] as? Int,
                   AVPlayerItem.Status(rawValue: status) == .readyToPlay {
                    self.playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
                    self.addPlayerItemEndObserver()
                    self.player?.play()
                }
            })
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
}
