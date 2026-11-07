import UIKit
import Capacitor

// Écran principal de l'app : enregistre le lecteur audio natif d'Effem auprès de Capacitor.
class MainViewController: CAPBridgeViewController {
    override open func capacitorDidLoad() {
        bridge?.registerPluginInstance(EffemPlayerPlugin())
    }
}
