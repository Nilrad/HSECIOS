import UIKit

class FacilitosTVC: UITableViewController {
    
    var data = [FacilitoElement]()
    
    var alSeleccionarCelda: ((_ facilito:FacilitoElement) -> Void)?
    var alScrollLimiteTop: (() -> Void)?
    var alScrollLimiteBot: (() -> Void)?
    var forzarActualizacion: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tableView.dequeueReusableCell(withIdentifier: "celda") as! FacilitosTVCell
        let unit = self.data[indexPath.row]
        celda.autor.text = unit.Persona
        celda.fecha.text = Utils.str2date2str(unit.Fecha ?? "")
        celda.tipo.text = Utils.searchMaestroStatic("TIPOFACILITO", unit.Tipo ?? "")
        celda.estado.text = Utils.searchMaestroStatic("ESTADOFACILITO", unit.Estado ?? "")
        celda.contenido.text = unit.Observacion
        celda.empresa.text = unit.Empresa
        celda.viewEditable.isHidden = unit.Editable == "0" || unit.Editable == "2"
        celda.botonEditable.tag = indexPath.row
        celda.tiempo.attributedText = Utils.handleSeconds("\(unit.TiempoDiffMin ?? 0)")
        celda.limiteView.isHidden = indexPath.row == self.data.count - 1
        celda.avatar.layer.cornerRadius = celda.avatar.frame.height/2
        celda.avatar.layer.masksToBounds = true
        if (unit.UrlObs ?? "") != "" {
            celda.avatar.image = Images.getImageFor("A-\(unit.UrlObs ?? "")")
        }
        celda.botonAvatar.tag = indexPath.row
        celda.imagen.isHidden = (unit.UrlPrew ?? "").isEmpty
        if (unit.UrlPrew ?? "") != "" {
            celda.imagen.image = Images.getImageFor("P-\(unit.UrlPrew ?? "")")
        }
        if unit.Estado ?? "" == "S" {
            celda.imagenEstado.image = Images.getIconFor("ESTADOFACILITO.\(unit.Estado ?? "")")?.withRenderingMode(.alwaysTemplate)
            celda.imagenEstado.tintColor = (unit.TiempoDiffMin ?? 0 > -1) ? UIColor.green : UIColor.red
        } else {
            celda.imagenEstado.image = Images.getIconFor("ESTADOFACILITO.\(unit.Estado ?? "")")
        }
        return celda
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let unit = self.data[indexPath.row]
        Globals.agregarHistorialFacilito = unit.Editable == "2" || unit.Editable == "3"
        alSeleccionarCelda?(unit)
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        if currentOffset <= -10 {
            self.alScrollLimiteTop?()
        } else {
            let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
            if maximumOffset - currentOffset <= -10 {
                self.alScrollLimiteBot?()
            }
        }
    }
    
    @IBAction func clickAvatar(_ sender: Any) {
        /*var superV = (sender as! UIButton).superview
        while !(superV is UITableViewCell) {
            superV = superV?.superview
        }
        var codigo = self.tableView.indexPath(for: superV as! UITableViewCell)
        */
        let unit = self.data[(sender as! UIButton).tag]
        Utils.showFichaFor(unit.UrlObs ?? "")
    }
    
    @IBAction func clickOpciones(_ sender: Any) {
        let unit = self.data[(sender as! UIButton).tag]
        self.presentAlert("OPCIONES", nil, .actionSheet, nil, nil, ["Editar", "Eliminar", "Cancelar"], [.default, .destructive, .cancel], actionHandlers: [{(alertEditar) in
            /*var superV = (sender as! UIButton).superview
            while !(superV is UITableViewCell) {
                superV = superV?.superview
            }
            var codigo = self.tableView.indexPath(for: superV as! UITableViewCell)!
            VCHelper.openUpsertFacilito(self, "PUT", self.data[codigo.row].CodObsFacilito ?? "")*/
            VCHelper.openUpsertFacilito(self, "PUT", unit.CodObsFacilito ?? "", {
                self.forzarActualizacion?()
            })
            }, { (alertEliminar) in
                self.presentAlert("¿Desea eliminar item?", "Reporte facilito \(unit.CodObsFacilito ?? "")", .alert, nil, nil, ["Aceptar", "Cancelar"], [.default, .cancel], actionHandlers: [{(alert) in
                    Rest.getDataGeneral("\(Config.urlBase)/ObsFacilito/Delete/\(unit.CodObsFacilito!)", true, success: {(resultValue:Any?,data:Data?) in
                        let respuesta = resultValue as! String
                        if respuesta == "1" {
                            self.presentAlert("Item eliminado", nil, .alert, 1, nil, [], [], actionHandlers: [])
                            self.forzarActualizacion?()
                        } else {
                            self.presentAlert("Error", "Ocurrió un error al intentar eliminar el item", .alert, 2, nil, [], [], actionHandlers: [])
                        }
                    }, error: nil)
                    }, nil])
                // self.presentAlert("Funcionalidad en desarrollo", nil, .alert, 2, nil, [], [], actionHandlers: [])
                // Alerts.presentAlert("Funcionalidad en desarrollo", ":D", duration: 1, imagen: Images.alertaRoja, viewController: self)
            }, nil])
        /*Utils.openSheetMenu(self, "OPCIONES", nil, ["Editar", "Eliminar", "Cancelar"], [.default, .destructive, .cancel], [{(alertEditar) in
            var superV = (sender as! UIButton).superview
            while !(superV is UITableViewCell) {
                superV = superV?.superview
            }
            var codigo = self.tableView.indexPath(for: superV as! UITableViewCell)!
            VCHelper.openUpsertFacilito(self, "PUT", self.facilitos.Data[codigo.row].CodObsFacilito ?? "")
            }, { (alertEliminar) in
                Alerts.presentAlert("Funcionalidad en desarrollo", ":D", duration: 1, imagen: Images.alertaRoja, viewController: self)
            }, { (alertCancelar) in
                Alerts.presentAlert("Funcionalidad en desarrollo", ":D", duration: 1, imagen: Images.alertaRoja, viewController: self)
            }])*/
        
    }
    
}

class FacilitosTVCell: UITableViewCell {
    @IBOutlet weak var autor: UILabel!
    @IBOutlet weak var fecha: UILabel!
    @IBOutlet weak var tipo: UILabel!
    @IBOutlet weak var estado: UILabel!
    @IBOutlet weak var tiempo: UILabel!
    @IBOutlet weak var empresa: UILabel!
    @IBOutlet weak var contenido: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var botonAvatar: UIButton!
    @IBOutlet weak var imagen: UIImageView!
    @IBOutlet weak var imagenEstado: UIImageView!
    @IBOutlet weak var viewEditable: UIView!
    @IBOutlet weak var botonEditable: UIButton!
    @IBOutlet weak var limiteView: UIView!
}
