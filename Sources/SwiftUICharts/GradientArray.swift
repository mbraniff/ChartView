//
//  GradientArray.swift
//  budget-book-keeper
//
//  Created by Matthew Braniff on 5/7/23.
//

import Foundation
import SwiftUI

public struct GradientArray {
    let startColor: UIColor
    let endColor: UIColor?
    let autoFraction: Bool
    
    init(startColor: UIColor, endColor: UIColor? = nil, autoFraction: Bool = true) {
        self.startColor = startColor
        self.endColor = endColor
        self.autoFraction = autoFraction
    }
    
    func getArray(count: Int, maxPercentage: Double = 1.0) -> [Color] {
        var gradientArray = [Color]()
        
        var overrideFraction: Double? = nil
        if self.autoFraction && count < 4 {
            switch count {
            case 1:
                if self.endColor != nil {
                    overrideFraction = 1.0
                } else {
                    overrideFraction = 0.0
                }
            case 2:
                overrideFraction = 0.25
            case 3:
                overrideFraction = 0.3
            default:
                overrideFraction = nil
            }
        }
        
        for i in 1..<count+1 {
            let fraction = Double(i)/Double(count)
            if let endColor = self.endColor {
                guard let color = Color(myColor: startColor.interpolate(to: endColor, fraction: overrideFraction != nil ? overrideFraction!*fraction : maxPercentage*fraction)) else { return [] }
                gradientArray.append(color)
            } else {
                guard let color = Color(myColor: startColor.interpolateBrightness(fraction: overrideFraction != nil ? overrideFraction!*fraction : maxPercentage*fraction)) else { return [] }
                gradientArray.append(color)
            }
        }
        
        return gradientArray
    }
}

extension UIColor {
    func interpolate(to endColor: UIColor, fraction: Double) -> UIColor {
        var f = max(0, fraction)
        f = min(1, fraction)
        
        guard let c1 = self.cgColor.components, let c2 = endColor.cgColor.components else { return self }
        
        let r = Double(c1[0] + (c2[0] - c1[0]) * f)
        let g = Double(c1[1] + (c2[1] - c1[1]) * f)
        let b = Double(c1[2] + (c2[2] - c1[2]) * f)
        let a = Double(c1[3] + (c2[3] - c1[3]) * f)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    func interpolateBrightness(fraction: Double) -> UIColor {
        var f = max(0, fraction)
        f = min(1, fraction)
        
        guard let c1 = self.cgColor.components else { return self }
        
        let r = Double(c1[0] + (1.0 - c1[0]) * f)
        let g = Double(c1[1] + (1.0 - c1[1]) * f)
        let b = Double(c1[2] + (1.0 - c1[2]) * f)
        
        return UIColor(red: r, green: g, blue: b, alpha: c1[3])
    }
}

extension Color {
    public init?(myColor: UIColor) {
        let uiColor = UIColor(cgColor: myColor.cgColor)
        self.init(uiColor)
    }
}
