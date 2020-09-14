//
//  CoordinatesViewController.swift
//  IKOL-ZadanieRekutacyjne
//
//  Created by Piotr on 13/05/2020.
//  Copyright © 2020 Piotr. All rights reserved.
//

import UIKit
import CoreLocation

class CoordinatesViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var firstPointLatitude: UITextField!
    @IBOutlet weak var firstPointLongitude: UITextField!
    @IBOutlet weak var secondPointLatitude: UITextField!
    @IBOutlet weak var secondPointLongitude: UITextField!
    @IBOutlet weak var calculateButton: UIButton!
    
    private var distanceValue: Int = 0
    
    private var firstPointCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2D()
    private var secondPointCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    private var textFieldsTupleArray: [(textfield: UITextField, isCorrect: Bool, type: String)] = [(textfield: UITextField, isCorrect: Bool, type: String)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calculateButton.layer.cornerRadius = calculateButton.frame.height / 3
        
        setCustomNavigationButton()
        
        textFieldsTupleArray.append((textfield: firstPointLatitude, isCorrect: false, type: "latitude"))
        textFieldsTupleArray.append((textfield: firstPointLongitude, isCorrect: false, type: "longitude"))
        textFieldsTupleArray.append((textfield: secondPointLatitude, isCorrect: false, type: "latitude"))
        textFieldsTupleArray.append((textfield: secondPointLongitude, isCorrect: false, type: "longitude"))
        
        for textfieldTuple in textFieldsTupleArray {
            textfieldTuple.textfield.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
            textfieldTuple.textfield.delegate = self
        }
        
        self.hideKeyboard()
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        
        if textField.text?.last == "," {
            textField.text?.remove(at: textField.text!.index(before: textField.text!.endIndex))
            textField.text! += "."
        }
        
        if let index = textFieldsTupleArray.firstIndex(where: { $0.textfield == textField}) {
            if let textFieldText: String = textField.text {
                if let textFieldDoubleValue: Double = Double(textFieldText) {
                    if textFieldsTupleArray[index].type == "latitude" && (-90.0...90.0).contains(textFieldDoubleValue) {                    textFieldsTupleArray[index].isCorrect = true
                        textField.setDefaultView()
                    } else if textFieldsTupleArray[index].type == "longitude" && (-180.0...180.0).contains(textFieldDoubleValue) {
                        textFieldsTupleArray[index].isCorrect = true
                        textField.setDefaultView()
                    } else {
                        textFieldsTupleArray[index].isCorrect = false
                        textField.setErrorView()
                    }
                } else {
                    textFieldsTupleArray[index].isCorrect = false
                    textField.setErrorView()
                }
            } else {
                textFieldsTupleArray[index].isCorrect = false
                textField.setErrorView()
            }
        } else {
            textField.setErrorView()
        }
    }
    
    @IBAction func buttonClicked(_ sender: UIButton) {
        
        if checkCoordinates(ofTuplesArray: textFieldsTupleArray) {
            firstPointCoordinates.latitude = Double(firstPointLatitude.text!)!
            firstPointCoordinates.longitude = Double(firstPointLongitude.text!)!
            secondPointCoordinates.latitude = Double(secondPointLatitude.text!)!
            secondPointCoordinates.longitude = Double(secondPointLongitude.text!)!
            
            let distance = firstPointCoordinates.distance(from: secondPointCoordinates)
            distanceValue = Int(distance)
            
            self.performSegue(withIdentifier: "goToResult", sender: self)
        } else {
            highlightIncorrectTextFields(ofTuplesArray: textFieldsTupleArray)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToResult" {
            if let destinationVC = segue.destination as? ResultViewController {
                destinationVC.distance = distanceValue
                destinationVC.firstPoint = firstPointCoordinates
                destinationVC.seconPoint = secondPointCoordinates
            }
            
        }
    }
    
    private func checkCoordinates(ofTuplesArray: [(textfield: UITextField, isCorrect: Bool, type: String)]) -> Bool {
        for textfieldTuple in textFieldsTupleArray where !textfieldTuple.isCorrect {
                // TODO Change to false when ended 
                return true
        }
        return true
    }
    
    private func highlightIncorrectTextFields(ofTuplesArray: [(textfield: UITextField, isCorrect: Bool, type: String)]) {
        for textfieldTuple in textFieldsTupleArray where !textfieldTuple.isCorrect {
            textfieldTuple.textfield.setErrorView()
        }
    }
}

extension CLLocationCoordinate2D {
    
    func distance(from: CLLocationCoordinate2D) -> CLLocationDistance {
        let destination = CLLocation(latitude: from.latitude, longitude: from.longitude)
        return CLLocation(latitude: latitude, longitude: longitude).distance(from: destination)
    }
}

extension UIViewController {
    
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UITextField {
    
    func setErrorView() {
        let shake = CABasicAnimation(keyPath: "position")
        let xDelta = CGFloat(5)
        shake.duration = 0.15
        shake.repeatCount = 1
        shake.autoreverses = true
        
        let fromPoint = CGPoint(x: self.center.x - xDelta, y: self.center.y)
        let fromValue = NSValue(cgPoint: fromPoint)
        
        let toPoint = CGPoint(x: self.center.x + xDelta, y: self.center.y)
        let toValue = NSValue(cgPoint: toPoint)
        
        shake.fromValue = fromValue
        shake.toValue = toValue
        shake.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.layer.add(shake, forKey: "position")
        
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 5
    }
    func setDefaultView() {
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 5
    }
}
