//
//  ViewController.swift
//  Drawing Pad
//
//  Created by XCodeClub on 2016-11-14.
//  Copyright © 2016 org.cuappdev.drawingpad. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, changeColorProtocol, imageChangedProtocol {

    var imageView: DrawingView!
    var color = UIColor.init(red: 0, green: 0, blue: 0, alpha: 1);
    var thickness = 10
    let drawStyleData = ["Freehand","Line","Square","Circle"];
    
    var drawStyleButton: UIButton!
    var drawStylePicker: UIPickerView!
    var drawStylePickerMask: UIButton!
    var thicknessBar: UISlider!
    var thicknessValueLabel: UILabel!
    var thicknessLabel: UILabel!
    var colorButton: UIButton!
    var colorLabel: UILabel!
    
    var undoButton: UIBarButtonItem!
    var redoButton: UIBarButtonItem!
    var clearButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let backgroundView = UIImageView(frame: view.frame);
        backgroundView.image = #imageLiteral(resourceName: "background");
        view.addSubview(backgroundView);
        
        let backPanelView = UIView(frame: CGRect(x: 0, y: view.frame.height-100, width: view.frame.width, height: 90));
        backPanelView.backgroundColor = UIColor.init(red: 1, green: 1, blue: 204/255, alpha: 0.5);
        view.addSubview(backPanelView);
        
        imageView = DrawingView(frame: CGRect(x: 20, y: 75, width: view.frame.width-40, height: view.frame.height-190), color: color, thickness: thickness, style: drawStyleData[0]);
        imageView.backgroundColor = .white;
        imageView.layer.cornerRadius = 10;
        imageView.clipsToBounds = true;
        imageView.delegate = self;
        view.addSubview(imageView);
        
        titleBarSetUp();
        controlPanelSetUp();
        
    }
    
    func titleBarSetUp() {
        
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 60));
        let navigationItem = UINavigationItem();
        navigationBar.items = [navigationItem];
        view.addSubview(navigationBar);
        
        let spaceButton = UIBarButtonItem(title: "", style: .plain, target: self, action: nil);
        
        undoButton = UIBarButtonItem(image: #imageLiteral(resourceName: "undo"), style: .plain, target: self, action: #selector(undoButtonPressed));
        undoButton.isEnabled = false;
        redoButton = UIBarButtonItem(image: #imageLiteral(resourceName: "redo"), style: .plain, target: self, action: #selector(redoButtonPressed));
        redoButton.isEnabled = false;
        clearButton = UIBarButtonItem(title: "   Clear", style: .plain, target: self, action: #selector(clearButtonPressed));
        navigationItem.leftBarButtonItems = [undoButton, redoButton, clearButton];
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonPressed));
        let importButton = UIBarButtonItem(title: "Import", style: .plain, target: self, action: #selector(importButtonPressed));
        navigationItem.rightBarButtonItems = [saveButton, spaceButton, importButton];
        
    }
    
    func undoButtonPressed() {
        redoButton.isEnabled = true;
        undoButton.isEnabled = imageView.undo();
    }
    
    func redoButtonPressed() {
        undoButton.isEnabled = true;
        redoButton.isEnabled = imageView.redo();
    }
    
    func clearButtonPressed() {
        
        let clearConfirmWindow = UIAlertController(title: "Confirm Selection", message: "The current drawing will be discarded (cannot be undone).", preferredStyle: .alert);
        clearConfirmWindow.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil));
        clearConfirmWindow.addAction(UIAlertAction(title: "Clear", style: .destructive, handler: { (UIAlertAction) in
            self.imageView.clear();
            self.redoButton.isEnabled = false;
            self.undoButton.isEnabled = false;
        }))
        
        present(clearConfirmWindow, animated: true, completion: nil);
        
    }
    
    
    func importButtonPressed() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func saveButtonPressed() {
        if let image = imageView.getImage() {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        }
        
        let saveCompleteWindow = UIAlertController(title: "Image Saved", message: "Drawing has been saved to photo library on local device.", preferredStyle: .alert);
        saveCompleteWindow.addAction(UIAlertAction(title: "Done", style: .default, handler: nil));
        present(saveCompleteWindow, animated: true, completion: nil);
        
    }
    
    func controlPanelSetUp() {
        
        thicknessBar = UISlider(frame: CGRect(x: 200, y: view.frame.height-100, width: view.frame.width-250, height: 50));
        thicknessBar.maximumValue = 100;
        thicknessBar.minimumValue = 2;
        thicknessBar.addTarget(self, action: #selector(thicknessBarChanged), for: .valueChanged);
        thicknessBar.setValue(Float(thickness), animated: false);
        view.addSubview(thicknessBar);
        
        thicknessValueLabel = UILabel(frame: CGRect(x: view.frame.width-40, y: view.frame.height-100, width: 150, height: 50));
        thicknessValueLabel.text = String(Int(thicknessBar.value));
        view.addSubview(thicknessValueLabel);
        
        thicknessLabel = UILabel(frame: CGRect(x: 140, y: view.frame.height-100, width: 50, height: 50));
        thicknessLabel.text = "Width";
        view.addSubview(thicknessLabel);
        
        let clearButtonBackground = UIImageView(frame: CGRect(x: 80, y: view.frame.height-50, width: view.frame.width-100, height: 30));
        clearButtonBackground.image = #imageLiteral(resourceName: "transparency");
        clearButtonBackground.contentMode = .topLeft;
        clearButtonBackground.clipsToBounds = true;
        view.addSubview(clearButtonBackground);
        
        colorButton = UIButton(frame: clearButtonBackground.frame);
        colorButton.backgroundColor = color;
        colorButton.addTarget(self, action: #selector(colorButtonPressed), for: .touchUpInside);
        view.addSubview(colorButton);
        
        colorLabel = UILabel(frame: CGRect(x: 20, y: view.frame.height-50, width: 100, height: 30));
        colorLabel.text = "Color";
        view.addSubview(colorLabel);
        
        drawStyleButton = UIButton(frame: CGRect(x: 20, y: view.frame.height-90, width: 100, height: 30));
        drawStyleButton.backgroundColor = .gray;
        drawStyleButton.layer.cornerRadius = 3;
        drawStyleButton.alpha = 0.8;
        drawStyleButton.setTitle(drawStyleData[0], for: .normal);
        drawStyleButton.addTarget(self, action: #selector(pickDrawStyle), for: .touchUpInside);
        view.addSubview(drawStyleButton);
        
        drawStylePickerMask = UIButton(frame: view.frame);
        drawStylePickerMask.alpha = 0.1;
        drawStylePickerMask.addTarget(self, action: #selector(dismissPicker), for: .touchUpInside);
        drawStylePickerMask.isHidden = true;
        view.addSubview(drawStylePickerMask);
        
        drawStylePicker = UIPickerView(frame: CGRect(x: 0, y: view.frame.height-310, width: view.frame.width, height: 200));
        drawStylePicker.backgroundColor = .white;
        drawStylePicker.alpha = 0.9;
        drawStylePicker.dataSource = self;
        drawStylePicker.delegate = self;
        drawStylePicker.isHidden = true;
        view.addSubview(drawStylePicker);
        
    }
    
    func pickDrawStyle() {
        
        drawStylePicker.isHidden = false;
        drawStylePickerMask.isHidden = false;
        
    }
    
    func thicknessBarChanged() {
        thickness = Int(thicknessBar.value);
        thicknessValueLabel.text = String(Int(thicknessBar.value));
        imageView.changeThickness(thickness: thickness);
    }

    func colorButtonPressed() {
        let colorSelectionVC = ColorSelectionViewController(color: color);
        colorSelectionVC.delegate = self;
        present(colorSelectionVC, animated: true, completion: nil);
    }
    
    func setNewColor(color: UIColor) {
        self.color = color;
        colorButton.backgroundColor = color;
        imageView.changeColor(color: color);
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let photo = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.setImage(image: photo);
        }
        picker.dismiss(animated: true, completion: nil);
    }
    
    func imageHasChanged() {
        undoButton.isEnabled = true;
        redoButton.isEnabled = false;
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return drawStyleData.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return drawStyleData[row];
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        drawStyleButton.setTitle(drawStyleData[row], for: .normal);
        imageView.changeStyle(style: drawStyleData[row]);
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50;
    }
    
    func dismissPicker() {
        drawStylePicker.isHidden = true;
        drawStylePickerMask.isHidden = true;
    }
    
}

