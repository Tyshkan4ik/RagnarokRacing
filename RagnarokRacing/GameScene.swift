//
//  GameScene.swift
//  RagnarokRacing
//
//  Created by Виталий Троицкий on 29.04.2023.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    //массив, содержащий все текущие изображения фонового леса
    var forests = [SKSpriteNode]()
    //размер секции фонового леса
    lazy var forestSize = CGSize.zero
    //настройка скорости движения направо для игры
    //это значение может увеличиваться по мере продвижения пользователя в игре
    var scrollSpeed: CGFloat = 5.0
    //время последнего вызова для метода обновления
    var lastUpdateTime: TimeInterval?
    
    override func didMove(to view: SKView) {
        //меняем точку привязки спрайтов. Поменяли на нижний левый угол, по дефолту середина.
        anchorPoint = CGPoint.zero
        
    }
    
    /// создаем спрайт леса с дорогой и добавляем его к сцене. Метод принемает CGPoin тем самым знает куда поместить фоновый лес
    func spawnForest(atPosition position: CGPoint) -> SKSpriteNode {
        let forest = SKSpriteNode(imageNamed: "forestBackground")
        //спрайт помещается в положение переданное в метод
        forest.position = position
        forest.size = self.size
        //добавляем обьект к сцене
        addChild(forest)
        //обновляем свойство forestSize реальным значением размера фона
        forestSize = forest.size
        //добавляем новый лес к массиву
        forests.append(forest)
        //возвращаем новый лес
        return forest
    }
    
    //перемещаем лес влево
    func updateForest(withScrollAmount currentScrollAmount: CGFloat) {
        //отслеживаем самое большое значение по оси х для всех существующих обьектов фона, нужна для того чтобы отслеживать где находится правый край фона и в какой момент добавлять новый фон
        var farthestRightForestX: CGFloat = 0.0
        
        for forest in forests {
            //расчитываем новое положение по оси х для спрайта forest
            let newX = forest.position.x - currentScrollAmount
            
            //Если фон сместился за пределы экрана удаляем его
            if newX < -forestSize.width {
                forest.removeFromParent()
                
                if let forestIndex = forests.firstIndex(of: forest) {
                    forests.remove(at: forestIndex)
                }
            } else {
                //для фона оставшегося на экране обновляем положение
                forest.position = CGPoint(x: newX, y: forest.position.y)
                
                //обновляем значение для крайнего правого фона
                if forest.position.x > farthestRightForestX {
                    farthestRightForestX = forest.position.x
                }
            }
        }
        //цикл while обеспечивающий постоянное заполнение экрана фоном пока фон меньше экрана
        while farthestRightForestX < frame.width {
            var forestX = farthestRightForestX + forestSize.width
            let forestY = frame.midY
            
            let newForest = spawnForest(atPosition: CGPoint(x: forestX, y: forestY))
            farthestRightForestX = newForest.position.x
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // определяем время, прошедшее с момента последнего высова update
        // elapsedTime - показатель отслеживания временных интервалов в секунду
        var elapsedTime: TimeInterval = 0.0
        if let lastTimeStamp = lastUpdateTime {
            elapsedTime = currentTime - lastTimeStamp
        }
        lastUpdateTime = currentTime
        
        //расчитываем скорость перемещения
        let expectedElapsedTime: TimeInterval = 1.0 / 40.0
        
        //рассчитаем насколько далеко должны сдвигаться обьекты при данном обновлении
        let scrollAdjustment = CGFloat(elapsedTime / expectedElapsedTime)
        let currentScrollAmount = scrollSpeed * scrollAdjustment
        
        updateForest(withScrollAmount: currentScrollAmount)
       
    }
}
