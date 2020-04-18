//
//  ViewController.swift
//  SliderDemo
//  Copyright © 2020 zxf. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var slider: SliderView!
    
    var steper: UIStepper!
    
    var systemSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .yellow
        
        slider = SliderView(frame: CGRect(x: 30, y: 200, width: view.bounds.width - 60, height: 70))
        view.addSubview(slider)

        
        slider.valueDidChanged = {
            print($0)
        }
        
        steper = UIStepper(frame: CGRect(x: 30, y: 150, width: 100, height: 40))
        view.addSubview(steper)
        steper.minimumValue = Double(slider.minValue)
        steper.maximumValue = Double(slider.maxValue)
        steper.stepValue = Double((slider.maxValue - slider.minValue) / CGFloat(10))
        steper.addTarget(self, action: #selector(steperValueChange), for: .valueChanged)
        
        systemSlider = UISlider(frame: CGRect(x: 30, y: 300, width: view.bounds.width - 60, height: 70))
        view.addSubview(systemSlider)
    }
    
    @objc
    func steperValueChange() {
        slider.updateValue(value: CGFloat(steper.value))
    }


}

