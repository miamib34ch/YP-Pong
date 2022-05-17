//
//  PongViewController+LaunchBall.swift
//  Pong
//
//  Created by Timofey on 17.05.2022.
//

import Foundation
import UIKit

// NOTE: Это расширение определяет функцию используемую для запуска мяча
extension PongViewController {

    /// Функция запуска мяча. Генерирует рандомный вектор скорости мяча и запускает мяч по этому вектору
    func launchBall() {
        let ballPusher = UIPushBehavior(items: [ballView], mode: .instantaneous)
        self.ballPushBehavior = ballPusher

        ballPusher.pushDirection = makeRandomVelocityVector()
        ballPusher.active = true

        self.dynamicAnimator?.addBehavior(ballPusher)
    }

    /// Функция генерации вектора скорости запуска мяча с почти рандомным направлением
    private func makeRandomVelocityVector() -> CGVector {
        // NOTE: Генерируем рандомное число от 0 до 1
        let randomSeed = Double(arc4random_uniform(1000)) / 1000

        // NOTE: Создаем рандомный угол примерно между Pi/6 (30 градусов) и Pi/3 (60 градусов)
        let angle = Double.pi * (0.16 + 0.16 * randomSeed)

        // NOTE: Берем в качестве амплитуды (силы) запуска мяча 1.5 пикселя экрана
        let amplitude = 1.5 / UIScreen.main.scale

        // NOTE: разложение вектора скорости на оси X и Y
        let x = amplitude * cos(angle)
        let y = amplitude * sin(angle)

        // NOTE: используя сгенерированный угол, возвращаем его в одном из 4 вариаций
        switch arc4random() % 4 {
        case 0:
            // направо, вниз
            return CGVector(dx: x, dy: y)

        case 1:
            // направо, вверх
            return CGVector(dx: x, dy: -y)

        case 2:
            // налево, вниз
            return CGVector(dx: -x, dy: y)

        default:
            // налево, вверх
            return CGVector(dx: -x, dy: -y)
        }
    }
}
