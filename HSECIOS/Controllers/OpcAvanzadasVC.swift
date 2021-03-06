import UIKit

class OpcAvanzadasVC: UIViewController, UITextFieldDelegate, UITextViewDelegate, UITabBarDelegate {
    
    @IBOutlet weak var tabBar: UITabBar!
    
    @IBOutlet weak var asunto: UITextField!
    
    @IBOutlet weak var asuntoLength: UILabel!
    
    @IBOutlet weak var mensaje: UITextView!
    
    @IBOutlet weak var botonEnviar: UIBarButtonItem!
    
    
    let asuntoMaxLength = 50
    let mensajeMaxLength = 800
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Utils.setTitleAndImage(self, "Feedback", Images.minero)
        self.tabBar.delegate = self
        asunto.delegate = self
        mensaje.delegate = self
        mensaje.layer.borderColor = UIColor.gray.cgColor
        mensaje.layer.borderWidth = 0.25
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let index = tabBar.items!.index(of: item)
        Utils.menuVC.showTabIndexAt(index!)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength = asunto.text!.count + string.count - range.length
        let shouldChange = newLength <= asuntoMaxLength
        if shouldChange {
            botonEnviar.isEnabled = newLength > 0 && mensaje.text.count > 0
        }
        return shouldChange
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLength = mensaje.text.count + text.count - range.length
        let shouldChange = newLength <= mensajeMaxLength
        if shouldChange {
            botonEnviar.isEnabled = newLength > 0 && asunto.text!.count > 0
        }
        return newLength <= mensajeMaxLength;
    }
    
    @IBAction func clickEnviar(_ sender: Any) {
        let params: [String:String] = [
            "Url" : asunto.text ?? "",
            "Descripcion" : mensaje.text
        ]
        Rest.postDataGeneral(Routes.forSendFeeback(), params, true, success: {(resultValue:Any?,data:Data?) in
            let str = resultValue as! String
            let num = Int(str) ?? 0
            if num <= 0 {
                self.presentAlert("Ocurrió un problema durante el envío", "Por favor, inténtelo de nuevo", .alert, 2, nil, [], [], actionHandlers: [])
                // Alerts.presentAlert("", "Ocurrió un problema durante el envío, inténtelo de nuevo.", imagen: nil, viewController: self)
                print("Ocurrió un problema durante el envío, inténtelo de nuevo.")
            } else {
                self.presentAlert("Su mensaje ha sido enviado", "Cod \(str)", .alert, 2, nil, [], [], actionHandlers: [])
                // Alerts.presentAlert("", "Su mensaje ha sido enviado. Cod \(str)", imagen: nil, viewController: self)
                // print("Su mensaje ha sido enviado. Cod \(str)")
            }
        }, error: nil)
        /*Rest.postData(Routes.forSendFeeback(), params, true, vcontroller: self, success: {(str: String) in
            
        })*/
    }
    
    
    @IBAction func clickMenu(_ sender: Any) {
        //(self.navigationController!.tabBarController!.parent as!MenuVC).showMenu()
        Utils.openMenu(/*self*/)
    }
    
}
