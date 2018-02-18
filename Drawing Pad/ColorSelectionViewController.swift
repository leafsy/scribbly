//
//  ColorSelectionViewController.swift
//  Drawing Pad
//
//  Created by XCodeClub on 2016-11-15.
//  Copyright © 2016 org.cuappdev.drawingpad. All rights reserved.
//

import UIKit

protocol changeColorProtocol {
    func setNewColor(color: UIColor);
}

class ColorSelectionViewController: UIViewController {

    var delegate: changeColorProtocol?
    var clearView: UIImageView!
    var redSlider: UISlider!
    var greenSlider: UISlider!
    var blueSlider: UISlider!
    var alphaSlider: UISlider!
    var color: UIColor!
    var colorArray = [UIColor]()
    var saveButton: UIButton!
    var backButton: UIButton!
    
    init(color: UIColor) {
        super.init(nibName: nil, bundle: nil);
        self.color = color;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = color;
        
        clearView = UIImageView(frame: view.frame);
        clearView.image = #imageLiteral(resourceName: "transparency");
        view.addSubview(clearView);
        
        let background = UIView(frame: CGRect(x: 40, y: 80, width: view.frame.width-80, height: view.frame.height-250));
        background.backgroundColor = .lightGray;
        background.layer.cornerRadius = 10;
        background.alpha = 0.75;
        view.addSubview(background);
        
        let redLabel = UILabel(frame: CGRect(x: 70, y: 110, width: 50, height: 30));
        redLabel.text = "R";
        view.addSubview(redLabel);
        let greenLabel = UILabel(frame: CGRect(x: 70, y: 160, width: 50, height: 30));
        greenLabel.text = "G";
        view.addSubview(greenLabel);
        let blueLabel = UILabel(frame: CGRect(x: 70, y: 210, width: 50, height: 30));
        blueLabel.text = "B";
        view.addSubview(blueLabel);
        let alphaLabel = UILabel(frame: CGRect(x: 70, y: 260, width: 80, height: 30));
        alphaLabel.text = "Opacity";
        view.addSubview(alphaLabel);
        
        redSlider = UISlider(frame: CGRect(x: 150, y: 100, width: view.frame.width-220, height: 50));
        redSlider.minimumValue = 0;
        redSlider.maximumValue = 1;
        redSlider.addTarget(self, action: #selector(setColor), for: .valueChanged);
        view.addSubview(redSlider);
        
        greenSlider = UISlider(frame: CGRect(x: 150, y: 150, width: view.frame.width-220, height: 50));
        greenSlider.minimumValue = 0;
        greenSlider.maximumValue = 1;
        greenSlider.addTarget(self, action: #selector(setColor), for: .valueChanged);
        view.addSubview(greenSlider);
        
        blueSlider = UISlider(frame: CGRect(x: 150, y: 200, width: view.frame.width-220, height: 50));
        blueSlider.minimumValue = 0;
        blueSlider.maximumValue = 1;
        blueSlider.addTarget(self, action: #selector(setColor), for: .valueChanged);
        view.addSubview(blueSlider);
        
        alphaSlider = UISlider(frame: CGRect(x: 150, y: 250, width: view.frame.width-220, height: 50));
        alphaSlider.minimumValue = 0;
        alphaSlider.maximumValue = 1;
        alphaSlider.addTarget(self, action: #selector(setColor), for: .valueChanged);
        view.addSubview(alphaSlider);
        
        setSliderValues();
        
        saveButton = UIButton(frame: CGRect(x: 100, y: 430, width: view.frame.width-200, height: 40));
        saveButton.backgroundColor = .darkGray;
        saveButton.setTitle("Save Changes", for: .normal);
        saveButton.layer.cornerRadius = 3;
        saveButton.addTarget(self, action: #selector(saveColor), for: .touchUpInside);
        view.addSubview(saveButton);
        
        backButton = UIButton(frame: CGRect(x: 100, y: 480, width: view.frame.width-200, height: 40));
        backButton.backgroundColor = .darkGray;
        backButton.setTitle("Cancel", for: .normal);
        backButton.layer.cornerRadius = 3;
        backButton.addTarget(self, action: #selector(cancelColor), for: .touchUpInside);
        view.addSubview(backButton);
        
        colorButtonsSetup(color: .red);
        colorButtonsSetup(color: .orange);
        colorButtonsSetup(color: .yellow);
        colorButtonsSetup(color: .green);
        colorButtonsSetup(color: .blue);
        colorButtonsSetup(color: .purple);
        colorButtonsSetup(color: .white);
        colorButtonsSetup(color: .gray);
        colorButtonsSetup(color: .black);
        
    }
    
    func colorButtonsSetup(color: UIColor) {
        
        colorArray.append(color);
        let button = UIButton(frame: CGRect(x: 45+colorArray.count*30, y: 350, width: 20, height: 30));
        button.backgroundColor = color;
        button.layer.borderColor = UIColor.black.cgColor;
        button.layer.borderWidth = 2;
        button.tag = colorArray.count-1;
        button.addTarget(self, action: #selector(colorButtonPressed), for: .touchUpInside);
        view.addSubview(button);
        
    }
    
    func colorButtonPressed(sender: UIButton) {
        color = colorArray[sender.tag];
        view.backgroundColor = color;
        clearView.alpha = 0;
        setSliderValues();
    }
    
    func setSliderValues() {
        var fRed: CGFloat = 0;
        var fGreen: CGFloat = 0;
        var fBlue: CGFloat = 0;
        var fAlpha: CGFloat = 0;
        if color.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            redSlider.value = Float(fRed);
            greenSlider.value = Float(fGreen);
            blueSlider.value = Float(fBlue);
            alphaSlider.value = Float(fAlpha);
            clearView.alpha = CGFloat(1)-fAlpha;
        }
    }
    
    func setColor() {
        color = UIColor.init(red: CGFloat(redSlider.value), green: CGFloat(greenSlider.value), blue: CGFloat(blueSlider.value), alpha: CGFloat(alphaSlider.value));
        view.backgroundColor = color;
        clearView.alpha = CGFloat(1)-CGFloat(alphaSlider.value);
    }
    
    func saveColor() {
        delegate?.setNewColor(color: color);
        cancelColor();
    }
    
    func cancelColor() {
        dismiss(animated: true, completion: nil);
    }
    
}
