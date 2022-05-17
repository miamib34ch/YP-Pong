import UIKit

/// Этот класс обрабатывает состояния "сцен" отображения приложения
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    /// В этой функции мы могли бы настроить главное окно отображения приложения
    /// Если бы решили верстать UI в коде, а не в Storyboard'е
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let _ = (scene as? UIWindowScene) else { return }
    }
}

