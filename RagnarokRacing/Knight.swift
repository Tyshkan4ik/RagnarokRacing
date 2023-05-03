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
    var jumpSpeed: CGFloat = 12.0
    // на земле
    var isOnGround = true
    
    /// Создание физического тела
    func setupPhysicsBody() {
        if let knightTexture = texture {
            physicsBody = SKPhysicsBody(texture: knightTexture, size: size)
            physicsBody?.isDynamic = true
            physicsBody?.density = 6.0
            physicsBody?.allowsRotation = false
            physicsBody?.angularDamping = 1.0
            physicsBody?.affectedByGravity = false
            
            //создаем соответствие между категорией и физическим телом персонажа
            physicsBody?.categoryBitMask = PhysicsCategory.knight
            // на персонажа влияет столкновение с монстром и персонаж отталкивается
            physicsBody?.collisionBitMask = PhysicsCategory.poring
            // хотим знать когда у персонажа возникает контакт с перечисленными категориями
            physicsBody?.contactTestBitMask = PhysicsCategory.poring | PhysicsCategory.gem
        }
    }
}
