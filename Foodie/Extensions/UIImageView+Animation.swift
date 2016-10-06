//
//  UIImageView+Animation.swift
//  Foodie
//
//  Created by Alton Lau on 2016-04-20.
//  Copyright © 2016 Alton Lau. All rights reserved.
//

import UIKit

extension UIImageView {
    
    /**
     Starts animating the images in the receiver with set delays.
     
     - Parameters:
        - delayFrames: Delay per frame before the next frame appears.
     */
    func startAnimating(delayFrames: [Double] = [Double](), completion: (() -> Void)?) {
        if let animationImages = animationImages {
            let delayFrames: [Double] = delayFrames.count > 0 ? delayFrames : {
                var array = [Double]()
                for _ in animationImages {
                    array.append(DefaultAnimationDelay)
                }
                return array
                }()
            let loop = animationRepeatCount > 0 ? animationRepeatCount : -1
            
            startAnimating(loop: loop, images: animationImages, delayFrames: delayFrames, completion: completion)
        }
    }
    
    private func startAnimating(loop: Int, images: [UIImage], delayFrames: [Double], completion: (() -> Void)?) {
        if loop < 0 {
            updateImageForAnimation(currentFrame: images.startIndex, images: images, delayFrames: delayFrames, completion: {
                self.startAnimating(loop: loop, images: images, delayFrames: delayFrames, completion: .none)
            })
        } else if loop < 2 {
            updateImageForAnimation(currentFrame: images.startIndex, images: images, delayFrames: delayFrames, completion: completion)
        } else {
            updateImageForAnimation(currentFrame: images.startIndex, images: images, delayFrames: delayFrames, completion: {
                let loop = loop - 1
                self.startAnimating(loop: loop, images: images, delayFrames: delayFrames, completion: completion)
            })
        }
    }
    
    private func updateImageForAnimation(currentFrame: Int, images: [UIImage], delayFrames: [Double], completion: (() -> Void)?) {
        image = images[currentFrame]
        
        dispatch_later(delayFrames[currentFrame]) {
            if currentFrame != images.count - 1 {
                let currentFrame = currentFrame + 1
                self.updateImageForAnimation(currentFrame: currentFrame, images: images, delayFrames: delayFrames, completion: completion)
            } else {
                if let completion = completion {
                    completion()
                }
            }
        }
    }
    
}
