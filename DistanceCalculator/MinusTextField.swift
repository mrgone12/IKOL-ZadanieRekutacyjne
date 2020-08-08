//
//  MinusTextField.swift
//  IKOL-ZadanieRekutacyjne
//
//  Created by Piotr on 18/05/2020.
//  Copyright © 2020 Piotr. All rights reserved.
//

import UIKit

import UIKit

class DecimalMinusTextField: UITextField {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.keyboardType = UIKeyboardType.decimalPad
    }
    
    fileprivate func getAccessoryButtons() -> UIView
    {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
        view.backgroundColor = UIColor(named: Constans.Colors.minusBackgroundBlue)
        
        let minusButton = UIButton(type: UIButton.ButtonType.custom)
        let doneButton = UIButton(type: UIButton.ButtonType.custom)
        minusButton.setTitle("+/-", for: UIControl.State())
        doneButton.setTitle("Done", for: UIControl.State())
        
        let buttonWidth = view.frame.size.width/3
        minusButton.frame = CGRect(x: 0, y: 0, width: buttonWidth, height: 44);
        doneButton.frame = CGRect(x: view.frame.size.width - buttonWidth, y: 0, width: buttonWidth, height: 44)
        
        minusButton.addTarget(self, action: #selector(DecimalMinusTextField.minusTouchUpInside(_:)), for: UIControl.Event.touchUpInside)
        doneButton.addTarget(self, action: #selector(DecimalMinusTextField.doneTouchUpInside(_:)), for: UIControl.Event.touchUpInside)
        
        view.addSubview(minusButton)
        view.addSubview(doneButton)
        
        return view
    }
    
   
    
    @objc func minusTouchUpInside(_ sender: UIButton!) {

        let text = self.text!
        if(text.count > 0) {
            let index: String.Index = text.index(text.startIndex, offsetBy: 1)
            let firstChar = text[..<index]
            if firstChar == "-" {
                self.text = String(text[index...])
            } else {
                self.text = "-" + text
            }
        }
    }
    
    @objc func doneTouchUpInside(_ sender: UIButton!) {
        self.resignFirstResponder()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.inputAccessoryView = getAccessoryButtons()
    }


}
