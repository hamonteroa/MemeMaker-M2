//
//  Meme.swift
//  MemeMaker
//
//  Created by Hector Montero on 12/29/16.
//  Copyright © 2016 Hector Montero. All rights reserved.
//

import Foundation
import UIKit

class Meme {
    let topText: String
    let bottomText: String
    let originalImage: UIImage
    let memedImage: UIImage
    
    init(topText: String, bottomText: String, originalImage: UIImage, memedImage: UIImage) {
        self.topText = topText
        self.bottomText = bottomText
        self.originalImage = originalImage
        self.memedImage = memedImage
    }
    
}
