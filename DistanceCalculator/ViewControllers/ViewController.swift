//
//  ViewController.swift
//  IKOL-ZadanieRekutacyjne
//
//  Created by Piotr on 12/05/2020.
//  Copyright © 2020 Piotr. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    @IBOutlet weak var worldImageView: UIImageView!
    @IBOutlet weak var enterButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        enterButton.layer.cornerRadius = enterButton.frame.height/3
        enterButton.layer.masksToBounds = false
    }
}

extension UIViewController{
    
    func setCustomNavigationButton(){
        let menuBtn = UIButton(type: .custom)
        menuBtn.setImage(UIImage(named:"arrow"), for: .normal)
        menuBtn.addTarget(self, action: Selector(("back")), for: UIControl.Event.touchUpInside)
        menuBtn.layer.shadowColor = UIColor.gray.cgColor
        menuBtn.layer.shadowOpacity = 0.5
        menuBtn.layer.shadowOffset = .zero
        menuBtn.layer.shadowRadius = 3
        menuBtn.layer.masksToBounds = false
        
        let menuBarItem = UIBarButtonItem(customView: menuBtn)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 38)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 38)
        currHeight?.isActive = true
        self.navigationItem.leftBarButtonItem = menuBarItem
    }
    
    @objc private func back(){
        self.navigationController?.popViewController(animated: true)
    }
}

