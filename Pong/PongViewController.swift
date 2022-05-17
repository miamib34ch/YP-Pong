/// Импортируем библиотеку UI-компонентов (элементы интерфейса)
import UIKit
import AVFoundation

/// Это класс единственного экрана нашего приложения
///
/// В классе есть элементы отображения игры:
/// - `ballView` - мяч
/// - `userPaddleView` - платформа игрока
/// - `enemyPaddleView` - платформа сопернка
///
/// Также в классе данного экрана настраивается физика взаимодействия элементов
/// в функции `enableDynamics()`
///
/// А еще в этом классе реализована обработка движения пальца по экрану,
/// с помощью обработки этого жеста игрок может двигать свою платформу и отталкивать мяч
///
class PongViewController: UIViewController {

    // MARK: - Overriden Properties

    /// Эта переопределенная переменная определяет допустимые ориентации экрана
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }

    // MARK: - Subviews

    /// Это переменная отображения мяча
    @IBOutlet var ballView: UIView!

    /// Это переменная отображения платформы игрока
    @IBOutlet var userPaddleView: UIView!

    /// Это переменная отображения платформы соперника
    @IBOutlet var enemyPaddleView: UIView!

    /// Это переменная отображения разделяющей линии
    @IBOutlet var lineView: UIView!

    /// Это переменная отображения лэйбла со счетом игрока
    @IBOutlet var userScoreLabel: UILabel!

    // MARK: - Instance Properties

    /// Это переменная обработчика жеста движения пальцем по экрану
    var panGestureRecognizer: UIPanGestureRecognizer?

    /// Это переменная в которой мы будем запоминать последнее положение платформы пользователя,
    /// перед тем как пользователь начал двигать пальцем по экрану
    var lastUserPaddleOriginLocation: CGFloat = 0

    /// Это переменная таймера, который будет обновлять положение платформы соперника
    var enemyPaddleUpdateTimer: Timer?

    /// Это флаг `Bool`, имеет два возможных значения:
    /// - `true` - можно трактовать как "да"
    /// - `false` - можно трактовать как "нет"
    ///
    /// Он отвечает за необходимость запустить мяч по следующему нажатию на экран
    ///
    var shouldLaunchBallOnNextTap: Bool = false

    /// Это флаг `Bool`, который указывает "был ли запущен мяч"
    var hasLaunchedBall: Bool = false

    var enemyPaddleUpdatesCounter: UInt8 = 0

    // NOTE: Все переменные ниже вплоть до 77-ой строки необходимы для настроек физики
    // Мы не будем вдаваться в подробности того, что это такое и как устроено
    var dynamicAnimator: UIDynamicAnimator?
    var ballPushBehavior: UIPushBehavior?
    var ballDynamicBehavior: UIDynamicItemBehavior?
    var userPaddleDynamicBehavior: UIDynamicItemBehavior?
    var enemyPaddleDynamicBehavior: UIDynamicItemBehavior?
    var collisionBehavior: UICollisionBehavior?

    // NOTE: Все переменный вплоть до 84-ой строки используются для реагирования
    // на стлокновения мяча - проигрывание звука столкновения и вибро-отклик
    var audioPlayers: [AVAudioPlayer] = []
    var backgroundSoundAudioPlayer: AVAudioPlayer? = {
        guard
            let backgroundSoundURL = Bundle.main.url(forResource: "background", withExtension: "wav"),
            let audioPlayer = try? AVAudioPlayer(contentsOf: backgroundSoundURL)
        else { return nil }

        audioPlayer.volume = 0.5
        audioPlayer.numberOfLoops = -1

        return audioPlayer
    }()
    var audioPlayersLock = NSRecursiveLock()
    var softImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
    var lightImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    var rigidImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .rigid)

    /// Эта переменная хранит счет пользователя
    var userScore: Int = 0 {
        didSet {
            /// При каждом обновлении значения переменной - обновляем текст в лэйбле
            updateUserScoreLabel()
        }
    }

    // MARK: - Instance Methods

    /// Эта функция запускается 1 раз когда представление экрана загрузилось
    /// и вот-вот покажется в окне отображения
    override func viewDidLoad() {
        super.viewDidLoad()

        /*
        NOTE: 👨‍💻 Заметка по настройке экрана игры 👨‍💻

        Код на 130-ей строке настраивает все необходимое для игры.
        Сейчас этот код выделен серым, потому что слэша со звездочкой
        над этим текстом и под этим текстом `/* */` делают его комменатрием.

        Комментарии в коде - это, как правило, заметки разработчиков о работе кусочка кода.
        Комментарии не учитываются при работе программы, а просто игнорируются,
        поэтому сейчас код не запустится.

        Убери два слэша в начале 130-ей строки, чтобы программа заработала!
        */

        configurePongGame()
    }

    /// Эта функция вызывается, когда экран PongViewController повяился на экране телефона
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // NOTE: Включаем динамику взаимодействия
        self.enableDynamics()

        self.backgroundSoundAudioPlayer?.play()
    }

    /// Эта функция вызывается, когда экран первый раз отрисовал весь свой интерфейс
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        ballView.layer.cornerRadius = ballView.bounds.size.height / 2
    }

    /// Эта функция обрабатывает начало всех касаний экрана
    override func touchesBegan(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        super.touchesBegan(touches, with: event)

        // NOTE: Если нужно запустить мяч и мяч еще не был запущен - запускаем мяч
        if shouldLaunchBallOnNextTap, !hasLaunchedBall {
            hasLaunchedBall = true

            launchBall()
        }
    }

    // MARK: - Private Methods

    /// Эта функция выполняет выполняет всю конфигурацию (настройку) экрана
    ///
    /// - включает обработку жеста движения пальцем по экрану
    /// - включает динамику взаимодействия элементов
    /// - указывает что при следующем нажатии мяч должен запуститься
    ///
    private func configurePongGame() {
        // NOTE: Настраиваем лэйбл со счетом игрока
        updateUserScoreLabel()

        // NOTE: Включаем обработку жеста движения пальцем по экрану
        self.enabledPanGestureHandling()

        // NOTE: Включаем логику платформы противника "следовать за мечом"
        self.enableEnemyPaddleFollowBehavior()

        // NOTE: Указываем, что при следующем нажатии на экран нужно запустить мяч
        self.shouldLaunchBallOnNextTap = true

        // NOTE: запускаем фоновую музыку
        self.backgroundSoundAudioPlayer?.prepareToPlay()
    }

    private func updateUserScoreLabel() {
        userScoreLabel.text = "\(userScore)"
    }
}