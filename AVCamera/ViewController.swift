//
//  ViewController.swift
//  AVCamera
//
//  Created by Adaicon on 2025/3/11.
//

import Foundation
import UIKit

class ViewController: UIViewController {
    private let cameraBtn: UIButton = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
    
    private let playerBtn: UIButton = UIButton(frame: CGRect(x: 100, y: 300, width: 100, height: 100))
    
    private let cameraViewController = {
        var vc = CameraViewController()
        vc.modalPresentationStyle = .fullScreen
        return vc
    }()
    
    override func viewDidLoad() {
        self.view.backgroundColor = .white
        
        cameraBtn.backgroundColor = .red.withAlphaComponent(0.5)
        cameraBtn.addTarget(self, action: #selector(clickCameraBtn), for: .touchUpInside)
        self.view.addSubview(cameraBtn)
        
        playerBtn.backgroundColor = .yellow.withAlphaComponent(0.5)
        playerBtn.addTarget(self, action: #selector(clickPlayerBtn), for: .touchUpInside)
        self.view.addSubview(playerBtn)
    }
    
    @objc func clickCameraBtn() {
        present(cameraViewController, animated: true)
    }
    
    @objc func clickPlayerBtn() {
        let playerViewController = PlayerViewController()
        playerViewController.modalPresentationStyle = .fullScreen
        present(playerViewController, animated: true)
    }
}
