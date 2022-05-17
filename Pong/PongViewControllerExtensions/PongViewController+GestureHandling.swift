//
//  PongViewController+GestureHandling.swift
//  Pong
//
//  Created by Timofey on 17.05.2022.
//

import UIKit

// NOTE: В этом расширении мы настраиваем логику обработки жестов
extension PongViewController {

    // MARK: - Pan Gesture Handling

    /// Эта функция настраивает обработку жеста движения пальцем по экрану
    func enabledPanGestureHandling() {
        // NOTE: Создаем объект обработчика жеста
        let panGestureRecognizer = UIPanGestureRecognizer()

        // NOTE: Добавляем обработчик жеста к представлению экрана
        view.addGestureRecognizer(panGestureRecognizer)

        // NOTE: Указываем обработчику какую функцию вызывать при обработке жеста
        panGestureRecognizer.addTarget(self, action: #selector(self.handlePanGesture(_:)))

        // NOTE: Сохраняем объект обработчика жеста в переменную класса
        self.panGestureRecognizer = panGestureRecognizer
    }

    /// Эта функция обработки жеста.
    /// Она вызывается каждый раз, когда пользователь двигает пальцем по экрану или касается его
    @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        // NOTE: Смотрим на состояние обработчика жеста
        switch recognizer.state {
        case .began:
            // NOTE: Жест начал распознаваться, запоминаем текущую позицию платформы
            // Это состояние, когда пользователь только коснулся экрана
            lastUserPaddleOriginLocation = userPaddleView.frame.origin.x

        case .changed:
            // NOTE: Произошло изменение касания,
            // вычисляем смещение пальца и обновляем положение плафтормы
            let translation: CGPoint = recognizer.translation(in: view)
            let translatedOriginX: CGFloat = lastUserPaddleOriginLocation + translation.x

            let platformWidthRatio = userPaddleView.frame.width / view.bounds.width
            let minX: CGFloat = 0
            let maxX: CGFloat = view.bounds.width * (1 - platformWidthRatio)
            userPaddleView.frame.origin.x = min(max(translatedOriginX, minX), maxX)
            dynamicAnimator?.updateItem(usingCurrentState: userPaddleView)

        default:
            // NOTE: При любом другом состоянии ничего не делаем
            break
        }
    }
}
