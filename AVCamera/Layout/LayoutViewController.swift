//
//  LayoutViewController.swift
//  AVCamera
//
//  Created by Adaicon on 2025/4/5.
//

import Foundation
import UIKit

public class LayoutViewController: UIViewController {
    let backButton = {
        var btn = UIButton(frame: CGRect(x: 44, y: 44, width: 44, height: 44))
        btn.setImage(UIImage(named: "back"), for: .normal)
        btn.backgroundColor = .red
        return btn
    }()
    
    var layoutContainerView: LayoutContainerView!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        setupUI()
    }
    
    func setupUI() {
        self.view.backgroundColor = .gray
        
        let frame = CGRect(x: 0, y: 44, width: self.view.bounds.width, height: self.view.bounds.width * 16.0 / 9.0)
        layoutContainerView = LayoutContainerView(frame: frame)
        self.view.addSubview(layoutContainerView)
        
        backButton.addTarget(self, action: #selector(clickBackButton), for: .touchUpInside)
        self.view.addSubview(backButton)
    }
    
    @objc func clickBackButton() {
        self.dismiss(animated: true)
    }
}
