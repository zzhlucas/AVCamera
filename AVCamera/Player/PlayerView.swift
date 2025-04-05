//
//  PlayerView.swift
//  AVCamera
//
//  Created by Adaicon on 2025/3/15.
//

import Foundation
import AVFoundation
import CoreGraphics
import UIKit

protocol PlayerViewDelegate: NSObjectProtocol {
    func playerDidEnd()
}

class PlayerView: UIView, UIGestureRecognizerDelegate {
    var renderView = UIView()
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    var maxDurtion = Double.greatestFiniteMagnitude
    
    var delegate: PlayerViewDelegate?
    
    var playEndNotificationToken: NSObjectProtocol?
    var timeObserver: Any?
    
    var panGes: UIPanGestureRecognizer?
    var tapGes: UITapGestureRecognizer?
    var pinchGes: UIPinchGestureRecognizer?
    
    var lastOffset: CGPoint = .zero
    var index: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        
        setupSubviews()
        setupGestures()
        setupPlayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var frame: CGRect {
        didSet {
            if frame.height / frame.width > 16.0 / 9.0 {
                let h = frame.height
                let w = h / 16.0 * 9.0
                renderView.frame = CGRect(x: 0, y: 0, width: w, height: h)
                renderView.center = CGPoint(x: frame.width / 2.0, y: frame.height / 2.0)
            } else {
                let w = frame.width
                let h = w * 16.0 / 9.0
                renderView.frame = CGRect(x: 0, y: 0, width: w, height: h)
                renderView.center = CGPoint(x: frame.width / 2.0, y: frame.height / 2.0)
            }
        }
    }
    
    func setupSubviews() {
        self.addSubview(renderView)
    }
    
    func setupGestures() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        pan.maximumNumberOfTouches = 1
        pan.delegate = self
        self.addGestureRecognizer(pan)
        panGes = pan
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        tap.delegate = self
        self.addGestureRecognizer(tap)
        tapGes = tap
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        pinch.delegate = self
        self.addGestureRecognizer(pinch)
        pinchGes = pinch
    }
    
    func setupPlayer() {
        guard let assetURL = Bundle.main.url(forResource: "video", withExtension: "MOV") else {
            return
        }
        let asset = AVAsset(url: assetURL)
        
        playerItem = AVPlayerItem(asset: asset)
        playerItem?.addObserver(self, forKeyPath:#keyPath(AVPlayerItem.status), options: [NSKeyValueObservingOptions.new] , context: nil)
        player = AVPlayer(playerItem: playerItem)
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = CGRect(x: 0, y: 0, width: renderView.frame.width, height: renderView.frame.height)
        
        renderView.layer.addSublayer(playerLayer)
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
            self?.delegate?.playerDidEnd()
        }
    }
    
    func addPlayerItemTimeObserver() {
        if index != 5 {
            return
        }
        let interval = CMTime(value: 1, timescale: 10)
        
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: { [weak self] time in
            let currentTime = CMTimeGetSeconds(time)
            print("\(String(describing: self?.index)), \(currentTime)")
            if currentTime - 0.01 >= self?.maxDurtion ?? 0 {
                print("\(String(describing: self?.index)), player did end")
                self?.player?.pause()
                if let timeObserver = self?.timeObserver {
                    self?.player?.removeTimeObserver(timeObserver)
                }
                self?.delegate?.playerDidEnd()
                
            }
        })
    }
    
    deinit {
        if let playEndNotificationToken {
            NotificationCenter.default.removeObserver(playEndNotificationToken)
        }
        if let timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
    }
    
    // MARK: KVO
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayerItem.status) {
            DispatchQueue.main.async(execute: {
                if let status = change?[.newKey] as? Int,
                   AVPlayerItem.Status(rawValue: status) == .readyToPlay {
                    self.playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
                    
                    self.addPlayerItemTimeObserver()
                    self.addPlayerItemEndObserver()
                    
                    self.player?.play()
                }
            })
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    // MARK: gesture
    
    @objc func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        print("tap")
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let offset = gesture.translation(in: self)
        switch gesture.state {
        case .began:
            lastOffset = offset
        case .changed:
            let deltaX = (offset.x - lastOffset.x) / renderView.transform.a
            let deltaY = (offset.y - lastOffset.y) / renderView.transform.a
            lastOffset = offset
            renderView.transform = CGAffineTransformTranslate(renderView.transform, deltaX, deltaY)
        default:
            lastOffset = .zero
        }
    }
    
    @objc func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        let deltaScale = gesture.scale
        switch gesture.state {
        case .changed:
            renderView.transform = CGAffineTransformScale(renderView.transform, deltaScale, deltaScale)
        default:
            print("")
        }
        gesture.scale = 1.0
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

