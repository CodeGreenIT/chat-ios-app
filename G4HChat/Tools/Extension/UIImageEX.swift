//
//  UIImageEX.swift
//  G4HChat
//
//  Created by Codegreen on 10/02/2018.
//  Copyright © 2018 Codegreen. All rights reserved.
//

import Foundation
import UIKit
extension UIImage {
    func base64Str() -> String? {
        guard let data = UIImagePNGRepresentation(self) else {
            return nil
        }
        return data.base64EncodedString()
    }

    /// Return image's size will less or equal size
    ///
    /// - Parameter size: maxium size
    /// - Returns: resized image
    func resizeIfNeed(size: CGSize) -> UIImage? {
        let appropriateSize = self.calMaxSize(size: size)
        return self.resizedImage(newSize: appropriateSize)
    }

    func calMaxSize(size: CGSize) -> CGSize {
        let maxH = size.height
        let maxW = size.width
        let factor = self.size.width / self.size.height
        var w: CGFloat = 0
        var h: CGFloat = 0
        if self.size.height <= maxH && self.size.width <= maxW {
            w = self.size.width
            h = self.size.height
        } else if self.size.height < self.size.width {
            w = maxW
            h = maxW / factor
        } else {
            h = maxH
            w = factor * maxH
        }
        return CGSize(width: w, height: h)
    }

    func resizedImage(newSize: CGSize) -> UIImage? {
        // Guard newSize is different
        guard self.size != newSize else { return self }

        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0,
                             width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    /// The short side equal min
    ///
    /// - Parameter min: minimum length of image
    /// - Returns: resized image
    func resizedImage(min: CGFloat) -> UIImage? {
        let size = self.size
        var h: CGFloat = 0
        var w: CGFloat = 0
        if size.height > size.width {
            w = min
            h = size.height / size.width * min
        } else {
            h = min
            w = size.width / size.height * min
        }
        let new = CGSize(width: w, height: h)
        return self.resizedImage(newSize: new)
    }

    /// Image center crop, image's size must greater or equal target
    ///
    /// - Parameters:
    ///   - width: target width
    ///   - height: target height
    /// - Returns: croped image
    func crop(width: CGFloat, height: CGFloat) -> UIImage? {
        guard self.size.width >= width && self.size.height >= height else {return nil}

        let posX = (self.size.width - width) / 2
        let posY = (self.size.height - height) / 2

        let rect: CGRect = CGRect(x: posX, y: posY, width: width, height: height)
        let cgImg = self.cgImage?.cropping(to: rect)
        let resized = UIImage(cgImage: cgImg!, scale: self.scale, orientation: self.imageOrientation)
        return resized
    }

    func squreCrop() -> UIImage? {
        var width = self.size.width
        var height = self.size.height
        if width > height {
            width = height
        } else {
            height = width
        }
        return self.crop(width: width, height: height)
    }
}
