//
//  Extensions.swift
//  RNImageProcessor
//
//  Created by Elf on 08.05.2018.
//  Copyright © 2018 Facebook. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hex: String) {
        if hex.hasPrefix("#") {
            let isWithAlpha = hex.count == 9
            let scanner = Scanner(string: hex)
            scanner.scanLocation = 1
            var hexNumber: UInt64 = 0
            scanner.scanHexInt64(&hexNumber)
            
            var r, g, b, a: CGFloat
            if (isWithAlpha) {
                r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                a = CGFloat(hexNumber & 0x000000ff) / 255
                self.init(red: r, green: g, blue: b, alpha: a)
            } else {
                r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                b = CGFloat(hexNumber & 0x0000ff) / 255
                a = 1
                self.init(red: r, green: g, blue: b, alpha: a)
            }
        } else {
            self.init(white: 1, alpha: 1)
        }
    }
}

