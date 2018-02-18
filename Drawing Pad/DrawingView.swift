//
//  DrawingView.swift
//  Drawing Pad
//
//  Created by XCodeClub on 2016-11-14.
//  Copyright © 2016 org.cuappdev.drawingpad. All rights reserved.
//

import UIKit

protocol imageChangedProtocol {
    func imageHasChanged();
}

class DrawingView: UIView {

    var delegate: imageChangedProtocol?
    var lastTouch: CGPoint?
    var color: UIColor!
    var thickness: Int!
    var style: String!
    var currentImageView: UIImageView!
    var pastImageView: UIImageView!
    var imageHistory = [UIImage?]();
    var historyPointer = 0;
    
    init(frame: CGRect, color: UIColor, thickness: Int, style: String) {
        super.init(frame: frame);
        self.color = color;
        self.thickness = thickness;
        self.style = style;
        imageHistory.append(nil);
        self.isUserInteractionEnabled = true;
        pastImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height));
        currentImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height));
        addSubview(pastImageView);
        addSubview(currentImageView);
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func draw(start: CGPoint, end: CGPoint, color: UIColor, thickness: Int, style: String) {
        
        let opacity = color.cgColor.alpha;
        let color = color.withAlphaComponent(1);
        
        UIGraphicsBeginImageContext(frame.size);
        let context = UIGraphicsGetCurrentContext();
        context?.setStrokeColor(color.cgColor);
        context?.setLineWidth(CGFloat(thickness));
        context?.setLineCap(.round);
        context?.beginPath();
        context?.move(to: start);
        
        if style == "Square" {
            context?.stroke(CGRect(x: start.x, y: start.y, width: end.x-start.x, height: end.y-start.y));
        } else if style == "Circle" {
            var paddingX = CGFloat(thickness);
            var paddingY = CGFloat(thickness);
            if end.x-start.x < 0 {
                paddingX = -paddingX;
            }
            if end.y-start.y < 0 {
                paddingY = -paddingY;
            }
            context?.strokeEllipse(in: CGRect(x: start.x, y: start.y, width: end.x-start.x+paddingX, height: end.y-start.y+paddingY));
        } else {
            if style == "Freehand" {
                currentImageView.image?.draw(in: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height));
            }
            context?.addLine(to: end);
            context?.strokePath();
        }
        
        currentImageView.image = UIGraphicsGetImageFromCurrentImageContext();
        currentImageView.alpha = opacity;
        UIGraphicsEndImageContext();
        
    }
    
    func changeThickness(thickness: Int) {
        self.thickness = thickness;
    }
    
    func changeColor(color: UIColor) {
        self.color = color;
    }
    
    func changeStyle(style: String) {
        self.style = style;
    }
    
    func clear() {
        pastImageView.image = nil;
        imageHistory.removeLast(imageHistory.count-1);
        historyPointer = 0;
    }
    
    func undo() -> Bool {
        if historyPointer > 0 {
            historyPointer -= 1;
            pastImageView.image = imageHistory[historyPointer];
        }
        return historyPointer > 0;
    }
    
    func redo() -> Bool {
        if historyPointer < imageHistory.count-1 {
            historyPointer += 1;
            pastImageView.image = imageHistory[historyPointer];
        }
        return historyPointer < imageHistory.count-1;
    }
    
    func getImage() -> UIImage? {
        return pastImageView.image;
    }
    
    func setImage(image: UIImage) {
        addImagetoHistory(image: image);
    }
    
    func addImagetoHistory(image: UIImage?) {
        delegate?.imageHasChanged();
        if historyPointer < imageHistory.count-1 {
            imageHistory.removeLast(imageHistory.count-historyPointer-1);
        }
        pastImageView.image = image;
        imageHistory.append(image);
        historyPointer += 1;
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let location = touches.first?.location(in: self) {
            draw(start: location, end: location, color: color, thickness: thickness, style: style);
            lastTouch = location;
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let start = lastTouch, let end = touches.first?.location(in: self) {
            draw(start: start, end: end, color: color, thickness: thickness, style: style);
            if style == "Freehand" {
                lastTouch = end;
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIGraphicsBeginImageContext(frame.size);
        pastImageView.image?.draw(in: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height));
        currentImageView.image?.draw(in: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height), blendMode: .normal, alpha: color.cgColor.alpha);
        addImagetoHistory(image: UIGraphicsGetImageFromCurrentImageContext());
        UIGraphicsEndImageContext();
        currentImageView.image = nil;
    }
    
}
