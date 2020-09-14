//
//  UIElementsGenerator.swift
//  DistanceCalculator
//
//  Created by Piotr on 10/08/2020.
//  Copyright © 2020 Piotr. All rights reserved.
//

import Foundation
import UIKit

struct UIElementsGenerator {
    static func getTexfield(placeHolder: String) -> UITextField {
        let textField: UITextField = UITextField()
        textField.placeholder = placeHolder
        return textField
    }
}
