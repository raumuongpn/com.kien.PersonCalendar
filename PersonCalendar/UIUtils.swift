//
//  UIUtils.swift
//  PersonCalendar
//
//  Created by Rau Muong on 6/7/17.
//  Copyright © 2017 Macbook. All rights reserved.
//

import Foundation


open class UIUtils {
    
    func buildButton(image: UIImage, title: String, colorText: UIColor) -> UIButton {
        let attributedString = NSMutableAttributedString.init(string: title)
        attributedString.addAttributes([NSFontAttributeName:UIFont.systemFont(ofSize: 16),NSForegroundColorAttributeName:colorText], range: NSMakeRange(0, attributedString.length))
        
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 40) //won't work if you don't set frame
        button.setImage(image, for: .normal)
        button.setAttributedTitle(attributedString, for: .normal)
        button.adjustsImageWhenHighlighted = false
        
        //        let imageSize = button.imageView?.frame.size
        let titleSize = button.titleLabel?.frame.size
        button.imageEdgeInsets = UIEdgeInsetsMake(2, 6, (titleSize?.height)!+2, 6)
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        return button
    }
}

extension UIColor {
    class func colorFromRGB(_ rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
