//
//  SimpleTextField.swift
//  Clickey
//
//  Created by Sem Shafiq on 12/08/15.
//  Copyright © 2015 Clickey. All rights reserved.
//

import UIKit

class SmartTextField: UITextField {

    enum ValidationResult {
        case None
        case Success
        case Error
    }
    
    var errorTitle = "Attention!"
    var errorMessage = ""
    var isValid = false
    
    var indicationImageView: UIImageView!
    var activityIndicator: UIActivityIndicatorView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addIndicatorView()
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        let rect = CGRectMake(0, 0, bounds.width - 20, bounds.height)
        return rect
    }
    
    func addIndicatorView(){
        
        indicationImageView = UIImageView(image: UIImage(named: "blank"))
        indicationImageView.center = CGPointMake(frame.width-indicationImageView.frame.width, bounds.midY)
        indicationImageView.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleBottomMargin]
        indicationImageView.userInteractionEnabled = true
        addSubview(indicationImageView)
        //indicationImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onIndicatorTap"))
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activityIndicator.autoresizingMask = [UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleBottomMargin, UIViewAutoresizing.FlexibleTopMargin]
        activityIndicator.center = CGPointMake(bounds.width - activityIndicator.frame.width, bounds.midY)
        addSubview(activityIndicator)
        activityIndicator.hidden = true
    }
    
    func showError(){
        hideWaiting()
//        indicationImageView.image = R.image.warning
        indicationImageView.image = indicationImageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
//        indicationImageView.tintColor = UIColor.clickeyWarmPinkColor()
    }
    
    func showSuccess(){
        removeSign()
        /*hideWaiting()
        indicationImageView.image = UIImage(named: "checkmark")
        indicationImageView.image = indicationImageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        indicationImageView.tintColor = UIColor.clickeySlimeGreenColor()*/
    }
    
    func showWaiting(){
        indicationImageView.image = UIImage(named: "blank")
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
    }
    
    func hideWaiting(){
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
    }
    
    func removeSign(){
        hideWaiting()
        indicationImageView.image = UIImage(named: "blank")
    }
    
    func onIndicatorTap(){
        if errorMessage.isEmpty{
            NSNotificationCenter.defaultCenter().postNotificationName("showMessage", object: self, userInfo: ["title": errorTitle, "message": errorMessage])
        }
    }

}
