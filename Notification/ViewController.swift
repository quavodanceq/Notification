
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemMint
    }

    func notificationCameWhen(_ state: AppState) {
        var message: String
        switch state {
        case .running:
            message = "Notification came when app is running"
        case .notLaunched:
            message = "App was launched by tapping the push notification"
        }
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    

}

enum AppState {
    case running
    case notLaunched
}

