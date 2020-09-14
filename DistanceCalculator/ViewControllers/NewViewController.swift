//
//  OldViewController.swift
//  DistanceCalculator
//
//  Created by Piotr on 13/08/2020.
//  Copyright © 2020 Piotr. All rights reserved.
//

import UIKit

class NewViewController: UIViewController {

    let firstPointLatitude: UITextField = UIElementsGenerator.getTexfield(placeHolder: "Latitude(-90...+90)")
       let firstPointLongitude: UITextField = UIElementsGenerator.getTexfield(placeHolder: "Longitude(-180...180)")
       let secondPointLatitude: UITextField = UIElementsGenerator.getTexfield(placeHolder: "Latitude(-90...+90)")
       let secondPointLongitude: UITextField = UIElementsGenerator.getTexfield(placeHolder: "Longitude(-180...180)")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
