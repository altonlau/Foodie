//
//  UIColor+Theme.swift
//  Foodie
//
//  Created by Alton Lau on 2016-04-24.
//  Copyright © 2016 Alton Lau. All rights reserved.
//

import UIKit

extension UIColor {
    
    public convenience init(hex: String) {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = 1.0
        let colorString = hex.replacingOccurrences(of: "#", with: "")
        
        let scanner = Scanner(string: colorString)
        var hexValue: CUnsignedLongLong = 0
        if scanner.scanHexInt64(&hexValue) {
            switch (colorString.characters.count) {
            case 3:
                red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
                green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
                blue  = CGFloat(hexValue & 0x00F)              / 15.0
            case 4:
                red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
                green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
                blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
                alpha = CGFloat(hexValue & 0x000F)             / 15.0
            case 6:
                red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
                green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
                blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
            case 8:
                red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
            default:
                NSException(name: NSExceptionName(rawValue: "Invalid color value"),
                            reason: "Color value \(hex) is invalid. It should be a hex value of the form #RGB, #ARGB, #RRGGBB, or #AARRGGBB",
                            userInfo: .none).raise()
            }
        } else {
            NSException(name: NSExceptionName(rawValue: "Scan hex error"),
                        reason: "",
                        userInfo: .none).raise()
        }
        
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    
    //# MARK: - Standard Colors
    
    public static var foodieBackground: UIColor {
        return UIColor(hex: "#D3F6FF")
    }
    
    public static var foodie: UIColor {
        return UIColor(hex: "#F07B3C")
    }
    
    
    //# MARK: - Grayscale
    
    public static var foodieGray: UIColor {
        return UIColor(hex: "#6A7B7F")
    }
    
    
    //# MARK: - Theme Colors
    
    public static var foodieLightBlue: UIColor {
        return UIColor(hex: "#F0FCFF")
    }
    
    public static var foodieBlue: UIColor {
        return UIColor(hex: "#E0F9FF")
    }
    
    public static var foodieDarkBlue: UIColor {
        return UIColor(hex: "#6CB9CC")
    }
    
    public static var foodieLightGreen: UIColor {
        return UIColor(hex: "#87D37C")
    }
    
}
