//
//  UIColor.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 26.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

extension UIColor {
    // MARK: Blue
    class var veryLightBlue: UIColor { return           #colorLiteral(red: 0.9137254902, green: 0.9490196078, blue: 1, alpha: 1) }
    class var lightBlueGrayTwo: UIColor { return        #colorLiteral(red: 0.8039215686, green: 0.862745098, blue: 0.9529411765, alpha: 1) }
    class var paleLilac: UIColor { return               #colorLiteral(red: 0.8784313725, green: 0.8862745098, blue: 1, alpha: 1) }
    class var lightPeriwinkleTwo: UIColor { return      #colorLiteral(red: 0.8039215686, green: 0.8235294118, blue: 0.9960784314, alpha: 1) }
    class var lavender: UIColor { return                #colorLiteral(red: 0.737254902, green: 0.7568627451, blue: 0.9490196078, alpha: 1) }
    class var robinEggBlue: UIColor { return            #colorLiteral(red: 0.568627451, green: 0.8784313725, blue: 1, alpha: 1) }
    class var lightBlue: UIColor { return               #colorLiteral(red: 0.3058823529, green: 0.768627451, blue: 0.9490196078, alpha: 1) }
    class var teambrellaLightBlue: UIColor { return     #colorLiteral(red: 0.3058823529, green: 0.768627451, blue: 0.9490196078, alpha: 1) }
    class var darkSkyBlue: UIColor { return             #colorLiteral(red: 0.2078431373, green: 0.6705882353, blue: 0.8470588235, alpha: 1) }
    class var perrywinkle: UIColor { return             #colorLiteral(red: 0.4705882353, green: 0.5098039216, blue: 0.8980392157, alpha: 1) }
    class var blueWithAHintOfPurple: UIColor { return   #colorLiteral(red: 0.2549019608, green: 0.3058823529, blue: 0.8, alpha: 1) }
    class var warmBlue: UIColor { return                #colorLiteral(red: 0.3215686275, green: 0.368627451, blue: 0.8666666667, alpha: 1) }
    class var frenchBlue: UIColor { return              #colorLiteral(red: 0.2588235294, green: 0.3058823529, blue: 0.7098039216, alpha: 1) }
    class var teambrellaBlue: UIColor { return          #colorLiteral(red: 0.1333333333, green: 0.2, blue: 0.5176470588, alpha: 1) }
    
    // MARK: Green
    class var tealish: UIColor { return                 #colorLiteral(red: 0.1215686275, green: 0.7529411765, blue: 0.7098039216, alpha: 1) }
    
    // MARK: Yellow
    class var lightGold: UIColor { return               #colorLiteral(red: 1, green: 0.8196078431, blue: 0.3215686275, alpha: 1) }
    
    // MARK: Red
    class var lipstick: UIColor { return                #colorLiteral(red: 0.862745098, green: 0.1411764706, blue: 0.3490196078, alpha: 1) }
    
    // MARK: White
    class var white50: UIColor { return                 #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 0.5) }
    
    // MARK: Gray
    class var paleGray: UIColor { return                #colorLiteral(red: 0.9098039216, green: 0.9294117647, blue: 0.9490196078, alpha: 1) }
    class var paleGray40: UIColor { return              #colorLiteral(red: 0.9098039216, green: 0.9294117647, blue: 0.9490196078, alpha: 0.3983572346) }
    class var lightBlueGray: UIColor { return           #colorLiteral(red: 0.8705882353, green: 0.9019607843, blue: 0.9529411765, alpha: 1) }
    class var cloudyBlue: UIColor { return              #colorLiteral(red: 0.8078431373, green: 0.8470588235, blue: 0.8745098039, alpha: 1) }
    class var blueyGray: UIColor { return               #colorLiteral(red: 0.5843137255, green: 0.6470588235, blue: 0.6941176471, alpha: 1) }
    class var bluishGray: UIColor { return              #colorLiteral(red: 0.4823529412, green: 0.5529411765, blue: 0.6039215686, alpha: 1) }
    class var battleshipGray: UIColor { return          #colorLiteral(red: 0.4, green: 0.4549019608, blue: 0.4901960784, alpha: 1) }
    class var charcoalGray: UIColor { return            #colorLiteral(red: 0.2352941176, green: 0.2784313725, blue: 0.3254901961, alpha: 1) }
    class var dark: UIColor { return                    #colorLiteral(red: 0.1725490196, green: 0.2235294118, blue: 0.2823529412, alpha: 1) }
    
    var redValue: CGFloat { return CIColor(color: self).red }
    var greenValue: CGFloat { return CIColor(color: self).green }
    var blueValue: CGFloat { return CIColor(color: self).blue }
    var alphaValue: CGFloat { return CIColor(color: self).alpha }

}
