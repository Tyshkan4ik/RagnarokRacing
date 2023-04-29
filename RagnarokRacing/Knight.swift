//
//  Knight.swift
//  RagnarokRacing
//
//  Created by Виталий Троицкий on 29.04.2023.
//

import SpriteKit

class Knight: SKSpriteNode {
    // скорость
    var velocity = CGPoint.zero
    var minimumY: CGFloat = 0.0
    var jumpSpeed: CGFloat = 20.0
    // на земле
    var isOnGround = true
}
