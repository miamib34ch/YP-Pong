import UIKit
import AVFoundation

/// Это главный класс обработки состояний приложения
///
/// В нем происходит настройка приложения на запуске и трэкинг перехода между разными состояниями
///
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    /// Этот метод вызывается 1 раз как только приложение запустилось
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        configureAudioSession()
        return true
    }

    // MARK: - UISceneSession Lifecycle

    /// Этот метод определяет настройки главной "сцены" отображения приложения
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(
            name: "Default Configuration",
            sessionRole: connectingSceneSession.role
        )
    }

    // MARK: - AVAudioSession

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .ambient,
                mode: .default,
                options: [.mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error setting up and activating AVAudioSession: \(error)")
        }
    }
}

