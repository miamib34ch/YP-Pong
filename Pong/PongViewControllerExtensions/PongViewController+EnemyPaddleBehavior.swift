//
//  PongViewController+EnemyPaddleFollowBehavior.swift
//  Pong
//
//  Created by Timofey on 17.05.2022.
//

import Foundation
import UIKit

// NOTE: В этом расширении класса определены функции,
// которые отвечают за настройку логики платформы противника.
extension PongViewController {

    // MARK: - Enemy Paddle Follow Behavior

    /// Эта функция включает логику "преследования" мяча платформой противника
    func enableEnemyPaddleFollowBehavior() {
        let updatesPerSecond: TimeInterval = 24
        let timePerFrame: TimeInterval = 1.0 / updatesPerSecond

        // NOTE: Создаем таймер которые вызывается 24 раза в секунду
        enemyPaddleUpdateTimer = Timer.scheduledTimer(
            withTimeInterval: timePerFrame,
            repeats: true
        ) { [weak self] _ in
            guard let self = self else { return }

            // NOTE: Считаем тики таймера и "замедляем" платформу противника
            self.enemyPaddleUpdatesCounter += 1
            var diffFactor: CGFloat = 1.0
            if self.enemyPaddleUpdatesCounter == 8 {
                self.enemyPaddleUpdatesCounter = 0
                diffFactor = 0.2
            }

            let platformWidthRatio = self.enemyPaddleView.frame.width / self.view.bounds.width
            let ballCenterX: CGFloat = self.ballView.frame.origin.x + self.ballView.frame.width / 2
            let paddleLeftX: CGFloat = self.enemyPaddleView.frame.origin.x
            let paddleCenterX: CGFloat = paddleLeftX + self.enemyPaddleView.frame.width / 2
            let minX: CGFloat = 0
            let maxX: CGFloat = self.view.bounds.width * (1 - platformWidthRatio)

            let diff = ballCenterX - paddleCenterX
            let clampedDiff = min(max(diff, -Constants.enemyPaddleMaxSpeed), Constants.enemyPaddleMaxSpeed) * diffFactor
            self.enemyPaddleView.frame.origin.x = min(max(paddleLeftX + clampedDiff, minX), maxX)
            self.dynamicAnimator?.updateItem(usingCurrentState: self.enemyPaddleView)
        }
    }
}
