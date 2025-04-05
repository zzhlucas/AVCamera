//
//  ViewController.swift
//  AVCamera
//
//  Created by Adaicon on 2025/3/11.
//

import Foundation
import UIKit

class ViewController: UIViewController {
    private let cameraBtn: UIButton = UIButton(frame: CGRect(x: 100, y: 100, width: 200, height: 100))
    private let playerBtn: UIButton = UIButton(frame: CGRect(x: 100, y: 250, width: 200, height: 100))
    private let layoutBtn: UIButton = UIButton(frame: CGRect(x: 100, y: 400, width: 200, height: 100))
    
    private let cameraViewController = {
        var vc = CameraViewController()
        vc.modalPresentationStyle = .fullScreen
        return vc
    }()
    
    override func viewDidLoad() {
        self.view.backgroundColor = .white
        
        cameraBtn.backgroundColor = .red.withAlphaComponent(0.5)
        cameraBtn.setTitle("Camera Test", for: .normal)
        cameraBtn.addTarget(self, action: #selector(clickCameraBtn), for: .touchUpInside)
        self.view.addSubview(cameraBtn)
        
        playerBtn.backgroundColor = .yellow.withAlphaComponent(0.5)
        playerBtn.setTitle("Player Test", for: .normal)
        playerBtn.addTarget(self, action: #selector(clickPlayerBtn), for: .touchUpInside)
        self.view.addSubview(playerBtn)
        
        layoutBtn.backgroundColor = .blue.withAlphaComponent(0.5)
        layoutBtn.setTitle("Layout Test", for: .normal)
        layoutBtn.addTarget(self, action: #selector(clickLayoutBtn), for: .touchUpInside)
        self.view.addSubview(layoutBtn)
    }
    
    @objc func clickCameraBtn() {
        present(cameraViewController, animated: true)
    }
    
    @objc func clickPlayerBtn() {
        let playerViewController = PlayerViewController()
        playerViewController.modalPresentationStyle = .fullScreen
        present(playerViewController, animated: true)
    }
    
    @objc func clickLayoutBtn() {
        let layoutViewController = LayoutViewController()
        layoutViewController.modalPresentationStyle = .fullScreen
        present(layoutViewController, animated: true)
    }
}
