//
//  GameScene.swift
//  RagnarokRacing
//
//  Created by Виталий Троицкий on 29.04.2023.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    //MARK: - Properties
    
    //массив, содержащий все текущие изображения фонового леса
    var forests = [SKSpriteNode]()
    //размер секции фонового леса
    lazy var forestSize = CGSize.zero
    //настройка скорости движения направо для игры
    //это значение может увеличиваться по мере продвижения пользователя в игре
    var scrollSpeed: CGFloat = 4
    //константа для гравитации (как быстро обьекты падают на землю)
    let gravitySpeed: CGFloat = 0.5
    
    //время последнего вызова для метода обновления
    var lastUpdateTime: TimeInterval?
    
    //создаем персонажа
    var knight = Knight()
    var arrayKnight: [SKTexture] = []
    
    //создаем монстра
    var poring = SKSpriteNode()
    var testPosition: CGFloat = 0.0
    var arrayPoring: [SKTexture] = []
    var porings = [SKSpriteNode]()
    lazy var poringSize = CGSize.zero
    
    //MARK: - Methods
    
    override func didMove(to view: SKView) {
        //меняем точку привязки спрайтов. Поменяли на нижний левый угол, по дефолту середина.
        anchorPoint = CGPoint.zero
        spawnKnight()
        animateKnight()
        tapRecognizer()
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
    
    /// Перемещаем лес влево
    /// - Parameter currentScrollAmount: Показатель насколько далеко должны сдвигаться обьекты
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
            let forestX = farthestRightForestX + forestSize.width
            let forestY = frame.midY
            
            let newForest = spawnForest(atPosition: CGPoint(x: forestX, y: forestY))
            farthestRightForestX = newForest.position.x
        }
    }
    
    /// Создаем персонажа
    func spawnKnight() {
        let knightAnimatedAtlas = SKTextureAtlas(named: "knightPeko")
        var walkFrames: [SKTexture] = []
        let numImages = knightAnimatedAtlas.textureNames.count
        for i in 1...numImages {
            let knightTextureName = "knight\(i)"
            walkFrames.append(knightAnimatedAtlas.textureNamed(knightTextureName))
        }
        arrayKnight = walkFrames
        let firstFrameTexture = arrayKnight[0]
        knight = Knight(texture: firstFrameTexture)
        
        //Задаем начальное положение персонажу, zPosition и minimumY
        //определяем х-положение персонажа. Задаес положение в четверь горизонтали сцены, то есть половине от frame.midX
        let knightX = frame.midX / 2.0
        // расчитываем положение персонажа по оси У. 64 - это растояние от нижней точки экрана до положения персонажа.
        let knightY = knight.frame.height / 2.0 + 90.0
        //задаем начальное положение персонажу
        knight.position = CGPoint(x: knightX, y: knightY)
        // условно говоря это номер слоя над бэкграудом, наш фон на слое №0 по дефолту, а тут мы выставили 10, тем самым оставили слои чтобы разместить другие элементы между, если нужно.
        knight.zPosition = 10
        //задаем переменной минимумУ значение ниже которого персанаж опустится не сможет после прыжка.
        knight.minimumY = knightY
        addChild(knight)
    }
    
    /// Анимируем персонажа, эффект что он бежит
    func animateKnight() {
        knight.run(SKAction.repeatForever(
            SKAction.animate(
                with: arrayKnight,
                timePerFrame: 0.1,
                resize: false,
                restore: true
            )),
                   withKey:"walkingInPlaceKnight")
    }
    
    /// Создаем монстра
    /// - Parameter positionX: Позиция по оси Х
    /// - Returns: Спрайт монстра
    func spawnPoring(atPosition positionX: CGFloat) -> SKSpriteNode {
        let poringAnimatedAtlas = SKTextureAtlas(named: "poring")
        
        var walkFrames: [SKTexture] = []
        let numImages = poringAnimatedAtlas.textureNames.count
        for i in 1...numImages {
            let poringTextureName = "poring\(i)"
            walkFrames.append(poringAnimatedAtlas.textureNamed(poringTextureName))
        }
        arrayPoring = walkFrames
        let firstFrameTexture = arrayPoring[0]
        poring = SKSpriteNode(texture: firstFrameTexture)
        
        //спрайт помещается в положение переданное в метод
        poring.position = CGPoint(x: positionX, y: knight.frame.height / 2.0 + 55.0)
        //poring.size = self.size
        poring.zPosition = 10
        //добавляем обьект к сцене
        addChild(poring)
        //обновляем свойство forestSize реальным значением размера фона
        poringSize = poring.size
        //добавляем новый лес к массиву
        porings.append(poring)
        //возвращаем новый лес
        return poring
    }
    
    /// Перемещаем монстра влево
    /// - Parameter currentScrollAmount: Показатель насколько далеко должны сдвигаться обьекты
    func updatePoring(withScrollAmount currentScrollAmount: CGFloat) {
        //отслеживаем самое большое значение по оси х для всех существующих обьектов фона, нужна для того чтобы отслеживать где находится правый край обьекта и в какой момент добавлять новый обьект
        var farthestRightPoringX: CGFloat = 0.0
        
        for poring in porings {
            //расчитываем новое положение по оси х для спрайта poring
            let newX = poring.position.x - currentScrollAmount
            
            //Если монстр сместился за пределы экрана удаляем его
            if newX < -poringSize.width {
                poring.removeFromParent()
                
                if let poringIndex = porings.firstIndex(of: poring) {
                    porings.remove(at: poringIndex)
                }
            } else {
                //для монстра оставшегося на экране обновляем положение
                poring.position = CGPoint(x: newX, y: poring.position.y)
                
                //обновляем значение для крайнего правого монстра
                if poring.position.x > farthestRightPoringX {
                    farthestRightPoringX = poring.position.x
                }
            }
        }
        //цикл while обеспечивающий постоянное заполнение экрана монстрами пока монстр меньше экрана
        let arrayElements = Array(200...1000)
        while farthestRightPoringX < frame.width {
            //создаем рандомное значения расстояния между монстрами
            let randomValue = arrayElements.randomElement()!
            let poringX = frame.maxX + CGFloat(randomValue)
            
            let newForest = spawnPoring(atPosition: poringX)
            farthestRightPoringX = newForest.position.x
        }
        animatePoring()
        animatePoringJumping()
    }
    
    /// Анимируем монстра (шевелится)
    func animatePoring() {
        poring.run(SKAction.repeatForever(
            SKAction.animate(
                with: arrayPoring,
                timePerFrame: 0.1,
                resize: false,
                restore: true
            )),
                   withKey:"walkingInPlacePoring")
    }
    
    /// Анимируем монстра (прыгает)
    func animatePoringJumping() {
        let moveUp = SKAction.moveBy(x: 0, y: 10, duration: 0.25)
        let sequence = SKAction.sequence([moveUp, moveUp.reversed()])
        poring.run(SKAction.repeatForever(sequence), withKey:  "Jumping")
    }
    
    /// Добавляем распознователь нажатия, чтобы знать когда пользователь нажал на экран
    func tapRecognizer() {
        //каждый раз когда пользователь нажмет на экран будет вызываться handleTap
        let tapMethod = #selector(GameScene.handleTap(tapGesture:))
        //создаем распознователь нажатий
        let tapGesture = UITapGestureRecognizer(target: self, action: tapMethod)
        //добавляет новый распознователь жестов к представлению сцене
        view?.addGestureRecognizer(tapGesture)
    }
    
    ///Обновление положение персонажа при прыжке
    func updateKnight() {
        //устанавливаем новое значение скорости персонажа с учетом влияния гравитации
        let velocityY = knight.velocity.y - gravitySpeed
        knight.velocity = CGPoint(x: knight.velocity.x, y: velocityY)
        
        //устанавливаем новое положение персонажа по оси У на основе его скорости
        let newKnightY: CGFloat = knight.position.y + knight.velocity.y
        knight.position = CGPoint(x: knight.position.x, y: newKnightY)
        
        //проверяем приземлился ли персонаж на землю
        if knight.position.y < knight.minimumY {
            //останавливаем падение, чтобы персанаж не проволился под землю
            knight.position.y = knight.minimumY
            //скорость прыжка приравниваем к нулю
            knight.velocity = CGPoint.zero
            //говорим что персонаж на земле
            knight.isOnGround = true
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
        let currentScrollAmountPoring = currentScrollAmount * 1.2
        
        updateForest(withScrollAmount: currentScrollAmount)
        updatePoring(withScrollAmount: currentScrollAmountPoring)
        updateKnight()
    }
    
    /// Метод для прыжка персонажа
    @objc
    func handleTap(tapGesture: UITapGestureRecognizer) {
        // персонаж подпрыгивает только если он находится на земле
        if knight.isOnGround {
            //задаем для персонажа скорость по оси У, равную его изначальной скорости прыжка
            knight.velocity = CGPoint(x: 0.0, y: knight.jumpSpeed)
            //отмечаем что персонаж не на земле
            knight.isOnGround = false
        }
    }
}
