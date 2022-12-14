import UIKit
import AVKit
import CoreMotion

class GameViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var isGameOver: Bool = false
    var index = 0
    var linesArray: [UIView] = [UIView()]
    var speedBarrier: Double = 0.00
    var result: Int = 0
    var player: AVAudioPlayer?
    var motionManager = CMMotionManager()
    var shakeActive: Bool = false
    
    @IBOutlet private weak var carImageView: UIImageView!
    @IBOutlet private weak var leftButton: UIButton!
    @IBOutlet private weak var rightButton: UIButton!
    @IBOutlet private weak var barrierImageView: UIImageView!
    @IBOutlet private weak var resultLabel: UILabel!
    @IBOutlet private weak var roadBackground: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        createLines(pointX: 125)
        createLines(pointX: Int(self.view.frame.maxX) - 125)
        
        setControl()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioSound()
        createBackground()
        buttonsDesign()
        setSpeed()
        setCar()
        setBarrier()
        setVolumeMusic()
        
        carImageView.center.y = view.frame.height - carImageView.frame.height
    }
    
    private func setVolumeMusic() {
        if UserDefaults.standard.value(forKey: "volumeMusic") == nil {
            player?.volume = 0.5
        } else {
            switch UserDefaults.standard.value(forKey: "volumeMusic") as! String {
            case "1":
                player?.volume = 0.1
            case "2":
                player?.volume = 0.3
            case "3":
                player?.volume = 0.5
            case "4":
                player?.volume = 0.7
            case "5":
                player?.volume = 1.0
            default:
                break
            }
        }
    }
    
    private func accelerometerControl() {
        leftButton.isHidden = true
        rightButton.isHidden = true
        
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.01
            
            motionManager.startAccelerometerUpdates(to: OperationQueue.main) { (data, error) in
                if let trueData = data {
                    self.carImageView.center.x += CGFloat(trueData.acceleration.x) * 3

                    if Int(trueData.acceleration.x * 100) > 40 {
                        self.carImageView.transform = CGAffineTransform(rotationAngle: 0.10)
                        
                        if self.view.frame.width + 10 <= self.carImageView.frame.maxX {
                            self.endGame()
                        }
                    }
                    
                    else if Int(trueData.acceleration.x * 100) > -40 && Int(trueData.acceleration.x * 100) < 40 {
                        self.carImageView.transform = CGAffineTransform(rotationAngle: 0)
                    }
                    
                    else if Int(trueData.acceleration.x * 100) < -40 {
                        self.carImageView.transform = CGAffineTransform(rotationAngle: -0.10)
                        
                        if self.view.frame.origin.x + 10 >= self.carImageView.frame.minX {
                            self.endGame()
                        }
                    }
                }
            }
        }
    }
    
    private func audioSound() {
        if let audioURL = Bundle.main.url(forResource: "car", withExtension: "mp3") {
            self.player = try? AVAudioPlayer(contentsOf: audioURL)
            player?.play()
        }
    }
    
    private func createBackground() {
        let roadBg = UIImage(named: "roadBG.jpg")
        roadBackground.image = roadBg
        
        self.view.insertSubview(roadBackground, at: 0)
    }
    
    private func buttonsControl() {
        let pressRightButton = UILongPressGestureRecognizer(target: self, action: #selector(longPressRight))
        pressRightButton.minimumPressDuration = 0
        rightButton.addGestureRecognizer(pressRightButton)
        
        let pressLeftButton = UILongPressGestureRecognizer(target: self, action: #selector(longPressLeft))
        pressLeftButton.minimumPressDuration = 0
        leftButton.addGestureRecognizer(pressLeftButton)
    }
    
    @objc func longPressRight(gestureReconizer: UILongPressGestureRecognizer) {
        carImageView.transform = CGAffineTransform(rotationAngle: 0.10)

            Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { timer in
                if self.view.frame.width + 10 <= self.carImageView.frame.maxX {
                    timer.invalidate()
                    self.endGame()
                }
                
                self.carImageView.center.x += 10
                
                if gestureReconizer.state != UIGestureRecognizer.State.began {
                    self.carImageView.transform = CGAffineTransform(rotationAngle: 0)
                    timer.invalidate()
                }
            })
    }
    
    @objc func longPressLeft(gestureReconizer: UILongPressGestureRecognizer) {
        carImageView.transform = CGAffineTransform(rotationAngle: -0.10)

            Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { timer in
                if self.view.frame.origin.x + 10 >= self.carImageView.frame.minX {
                    timer.invalidate()
                    self.endGame()
                }
                
                self.carImageView.center.x -= 10
                
                if gestureReconizer.state != UIGestureRecognizer.State.began {
                    self.carImageView.transform = CGAffineTransform(rotationAngle: 0)
                    timer.invalidate()
                }
            })
    }
    
    private func openEnterNameViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let enterNameController = storyboard.instantiateViewController(identifier: "EnterNameViewController") as? EnterNameViewController {
            enterNameController.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(enterNameController, animated: false)
        }
    }
    
    private func endGame() {
        player?.stop()
        isGameOver = true
        openEnterNameViewController()
    }
    
    private func setSpeed() {
        if UserDefaults.standard.value(forKey: "speedCar") == nil {
            speedBarrier = 0.025
        } else {
            switch UserDefaults.standard.value(forKey: "speedCar") as! String {
            case "1":
                speedBarrier = 0.055
            case "2":
                speedBarrier = 0.045
            case "3":
                speedBarrier = 0.035
            case "4":
                speedBarrier = 0.025
            case "5":
                speedBarrier = 0.015
            default:
                break
            }
        }
    }
    
    private func setCar() {
        switch UserDefaults.standard.value(forKey: "carColor") as? String {
            case "red":
                createCar(name: "redCar")
            case "grey":
                createCar(name: "greyCar")
            default:
                createCar(name: "greyCar")
        }
    }
    
    private func setBarrier() {
        switch UserDefaults.standard.value(forKey: "barrier") as? String {
        case "stone":
            createBarrier(name: "item.png")
        case "pit":
            createBarrier(name: "item2.png")
        case "bush":
            createBarrier(name: "item3.png")
        default:
            createBarrier(name: "item.png")
        }
    }
    
    private func setControl() {
        switch UserDefaults.standard.value(forKey: "control") as? String {
        case "buttons":
            buttonsControl()
        case "accelerometer":
            accelerometerControl()
        default:
            buttonsControl()
        }
    }
    
    private func createCar(name: String) {
        let image = UIImage(named: name)
        carImageView.image = image
        carImageView.contentMode = .scaleAspectFill
        carImageView.layer.shadowColor = UIColor.black.cgColor
        carImageView.layer.shadowOffset = CGSize(width: 5, height: 5)
        carImageView.layer.shadowOpacity = 0.3
        carImageView.frame.size.width = 90
        carImageView.frame.size.height = 200
        
        self.view.bringSubviewToFront(carImageView)
    }
    
    private func createBarrier(name: String) {
        let image = UIImage(named: name)
        barrierImageView.image = image
        barrierImageView.contentMode = .scaleAspectFit
        barrierImageView.frame.origin.x = CGFloat(Int.random(in: 50 ..< Int(view.frame.width - 100)))
        barrierImageView.frame.origin.y = 0
        barrierImageView.bringSubviewToFront(barrierImageView)
        
        moveBarriersDown()
    }
    
    private func moveBarriersDown() {
        Timer.scheduledTimer(withTimeInterval: speedBarrier, repeats: true, block: { timer in
            self.barrierImageView.frame.origin.y += 5
            
            if !self.shakeActive && self.carImageView.frame.intersects(self.barrierImageView.frame) {
                timer.invalidate()
                self.endGame()
            }
            else {
                if self.barrierImageView.frame.origin.y >= self.view.frame.height {
                    timer.invalidate()
                    
                    self.result += 1
                    self.resultLabel.text = "\(self.result)"
                    
                    UserDefaults.standard.set(self.result, forKey: "myPoints")
                    
                    self.setBarrier()
                }
                else {
                    self.result += 0
                    self.resultLabel.text = "\(self.result)"
                    UserDefaults.standard.set(self.result, forKey: "myPoints")
                    
                }
            }
        })
    }
    
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            shakeActive = true
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { timer in
            self.shakeActive = false
        })
    }
    
    private func createLines(pointX: Int) {
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true, block: { _ in
            
            let line = UIView(frame: CGRect(x: pointX, y: -50, width: 10, height: 80))
            line.backgroundColor = #colorLiteral(red: 1, green: 0.4868369016, blue: 0.07675121238, alpha: 1)
            line.layer.opacity = 0.5
           
            self.index += 1
            self.linesArray.append(line)
            self.view.addSubview(line)
            self.view.insertSubview(line, at: 1)
        
            UIView.animate(withDuration: 1.5, delay: 0, options: .curveLinear) {
            
            for index in 0 ... self.linesArray.count - 1 {
                self.linesArray[index].frame.origin.y = self.view.frame.height
            }
        }})
    }
    
    private func buttonsDesign() {
        leftButton.layer.cornerRadius = leftButton.frame.height / 2
        rightButton.layer.cornerRadius = rightButton.frame.height / 2
    }
}
