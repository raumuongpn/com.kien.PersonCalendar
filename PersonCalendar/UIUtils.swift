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
        attributedString.addAttributes([NSFontAttributeName:UIFont.boldSystemFont(ofSize: 10),NSForegroundColorAttributeName:colorText], range: NSMakeRange(0, attributedString.length))
        
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 35) //won't work if you don't set frame
        button.setImage(image, for: .normal)
        button.setAttributedTitle(attributedString, for: .normal)
        button.adjustsImageWhenHighlighted = false
        
        let imageSize = button.imageView?.frame.size
        let titleSize = button.titleLabel?.frame.size
        button.imageEdgeInsets = UIEdgeInsetsMake(0, ((titleSize?.width)!-(imageSize?.width)!), (titleSize?.height)!+2, 0)
        button.titleEdgeInsets = UIEdgeInsetsMake((imageSize?.height)!+2, 0, 0, 0)
        return button
    }
}
