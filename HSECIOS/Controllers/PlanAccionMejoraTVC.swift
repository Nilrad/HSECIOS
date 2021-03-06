import UIKit
import DKImagePickerController
import Photos
import AVKit
import MobileCoreServices

class PlanAccionMejoraVC: UITableViewController, UITextFieldDelegate {
    
    var codPlanAccion = ""
    var accion = AccionMejoraAtencion()
    var accionFecha = Date()
    var responsables: [Persona] = []
    var nombres = Set<String>()
    var multimedia: [FotoVideo] = []
    var documentos: [DocumentoGeneral] = []
    var correlativosABorrar = Set<Int>()
    var docIdRequests = [Int]()
    var docPorcentajes = [Int]()
    var modo = "GET"
    var idPost = -1
    
    var afterSuccess: ((_ : AccionMejoraAtencion) -> Void)?
    
    var dataNoEdit: [[String]] = [["Responsable", "-"], ["Fecha", "-"], ["Porcentaje de avance", "-"], ["Tarea realizada", "-"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.allowsSelection = false
    }
    
    func cleanData() {
        self.dataNoEdit = [["Responsable", "-"], ["Fecha", "-"], ["Porcentaje de avance", "-"], ["Tarea realizada", "-"]]
        self.multimedia = []
        self.documentos = []
        self.tableView.reloadData()
    }
    
    func loadData(_ modo: String, _ accion: AccionMejoraAtencion, _ codPlanAccion: String, _ responsables: [Persona]) {
        self.modo = modo
        self.accion = accion
        self.codPlanAccion = codPlanAccion
        self.responsables = responsables
        self.tableView.reloadData()
        /*self.mostrarSeccion1 = false
        self.mostrarSeccion2 = false*/
        switch modo {
        case "ADD":
            
            switch self.responsables.count {
            case 1:
                self.accion.Responsable = responsables[0].Nombres
                self.accion.CodResponsable = responsables[0].CodPersona
            case 0:
                self.accion.Responsable = "NO HAY RESPONSABLES DISPONIBLES"
                self.accion.CodResponsable = nil
            default:
                self.accion.Responsable = nil
                self.accion.CodResponsable = nil
            }
            self.accion.CodAccion = codPlanAccion
            self.accion.Correlativo = -1
            self.accion.PorcentajeAvance = "0"
            self.accionFecha = Date()
            self.tableView.reloadData()
        case "GET":
            Rest.getDataGeneral(Routes.forAccionMejoraDetalle("\(accion.Correlativo!)"), true, success: {(resultValue:Any?,data:Data?) in
                self.accion = Dict.dataToUnit(data!)!
                (self.multimedia, self.documentos) = Utils.separateMultimedia(self.accion.Files!.Data)
                for unit in self.multimedia {
                    Images.downloadImage("\(unit.Correlativo!)", {
                        unit.imagen = Images.imagenes["P-\(unit.Correlativo!)"]
                    })
                }
                self.tableView.reloadData()
                /*let detalle: AccionMejoraDetalle = Dict.dataToUnit(data!)!
                self.dataNoEdit[0][1] = detalle.Responsable
                self.dataNoEdit[1][1] = Utils.str2date2str(detalle.Fecha)
                self.dataNoEdit[2][1] = detalle.PorcentajeAvance
                self.dataNoEdit[3][1] = detalle.Descripcion
                self.multimedia = detalle.multimedia
                self.documentos = detalle.documentos
                self.tableView.reloadData()*/
            }, error: nil)
        case "PUT":
            Rest.getDataGeneral(Routes.forAccionMejoraDetalle("\(accion.Correlativo!)"), true, success: {(resultValue:Any?,data:Data?) in
                self.accion = Dict.dataToUnit(data!)!
                (self.multimedia, self.documentos) = Utils.separateMultimedia(self.accion.Files!.Data)
                for unit in self.multimedia {
                    Images.downloadImage("\(unit.Correlativo!)", {
                        unit.imagen = Images.imagenes["P-\(unit.Correlativo!)"]
                    })
                }
                self.tableView.reloadData()
            }, error: nil)
        default:
            break
        }
        
    }
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 0 {
            let inverseSet = NSCharacterSet(charactersIn:"0123456789").inverted
            let components = string.components(separatedBy: inverseSet)
            let filtered = components.joined(separator: "")
            
            if string == filtered {
                let nsString = textField.text as NSString?
                let num = nsString?.replacingCharacters(in: range, with: string)
                let numero = Int(num!) ?? 0
                if numero <= 100 && numero >= 0 {
                    self.accion.PorcentajeAvance = "\(numero)"
                    return true
                }
            }
            return false
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case 0:
            self.accion.PorcentajeAvance = textField.text
        case 1:
            self.accion.Descripcion = textField.text
        default:
            break
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 40
        case 1:
            return (self.modo == "GET" && self.multimedia.count == 0) ? CGFloat.leastNonzeroMagnitude : 40
        case 2:
            return (self.modo == "GET" && self.documentos.count == 0) ? CGFloat.leastNonzeroMagnitude : 40
            // return self.documentos.count > 0 ? 50 : CGFloat.leastNonzeroMagnitude
        default:
            return CGFloat.leastNonzeroMagnitude
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "celda1") as! Celda1Texto1View1Boton
        switch section {
        case 0:
            header.texto.text = "Registro de atención"
            header.view.isHidden = true
        case 1:
            if (self.modo == "GET" && self.multimedia.count == 0) {
                return nil
            }
            header.texto.text = "Galería de Fotos Videos"
            header.view.isHidden = self.modo == "GET"
            header.boton.tag = 0
        case 2:
            if (self.modo == "GET" && self.documentos.count == 0) {
                return nil
            }
            header.texto.text = "Otros Documentos"
            header.view.isHidden = self.modo == "GET"
            header.boton.tag = 1
        default:
            break
        }
        return header.contentView
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4
        case 1:
            return self.multimedia.count / 2 + self.multimedia.count % 2
        case 2:
            return self.documentos.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                if self.modo == "GET" {
                    let celda = tableView.dequeueReusableCell(withIdentifier: "celda2") as! Celda2Texto
                    celda.texto1.text = "Responsable"
                    celda.texto2.text = self.accion.Responsable
                    return celda
                } else {
                    let celda = tableView.dequeueReusableCell(withIdentifier: "celda3") as! Celda1Texto1Boton
                    celda.texto.attributedText = Utils.addInitialRedAsterisk("Responsable", "HelveticaNeue-Bold", 13)
                    celda.boton.tag = 0
                    let dato = self.accion.CodResponsable == nil ? "- SELECCIOME -" : self.accion.Responsable
                    celda.boton.setTitle(dato, for: .normal)
                    celda.boton.titleLabel?.numberOfLines = 2
                    return celda
                }
            case 1:
                if self.modo == "GET" {
                    let celda = tableView.dequeueReusableCell(withIdentifier: "celda2") as! Celda2Texto
                    celda.texto1.text = "Fecha"
                    celda.texto2.text = Utils.date2str(Date(), "dd 'de' MMMM").uppercased()
                    return celda
                } else {
                    let celda = tableView.dequeueReusableCell(withIdentifier: "celda3") as! Celda1Texto1Boton
                    celda.texto.text = "Fecha"
                    celda.boton.tag = 1
                    celda.boton.setTitle(Utils.date2str(Date(), "dd 'de' MMMM").uppercased(), for: .normal)
                    celda.boton.titleLabel?.numberOfLines = 2
                    return celda
                }
            case 2:
                if self.modo == "GET" {
                    let celda = tableView.dequeueReusableCell(withIdentifier: "celda2") as! Celda2Texto
                    celda.texto1.text = "Porcentaje de avance"
                    celda.texto2.text = self.accion.PorcentajeAvance
                    return celda
                } else {
                    let celda = tableView.dequeueReusableCell(withIdentifier: "celda4") as! Celda1Texto1InputText
                    celda.texto.attributedText = Utils.addInitialRedAsterisk("Porcentaje de avance", "HelveticaNeue-Bold", 13)
                    celda.inputTexto.text = self.accion.PorcentajeAvance
                    celda.inputTexto.tag = 0
                    celda.inputTexto.keyboardType = .numberPad
                    celda.inputTexto.delegate = self
                    return celda
                }
            case 3:
                if self.modo == "GET" {
                    let celda = tableView.dequeueReusableCell(withIdentifier: "celda2") as! Celda2Texto
                    celda.texto1.text = "Tarea realizada"
                    celda.texto2.text = self.accion.Descripcion
                    return celda
                } else {
                    let celda = tableView.dequeueReusableCell(withIdentifier: "celda5") as! Celda1Texto1InputText
                    celda.texto.attributedText = Utils.addInitialRedAsterisk("Tarea realizada", "HelveticaNeue-Bold", 13)
                    celda.inputTexto.text = self.accion.Descripcion
                    celda.inputTexto.tag = 1
                    celda.inputTexto.delegate = self
                    return celda
                }
            default:
                return UITableViewCell()
            }
            /*if self.modo == "GET" {
                let celda = tableView.dequeueReusableCell(withIdentifier: "celda2") as! Celda2Texto
                celda.texto1.text = self.dataNoEdit[indexPath.row][0]
                celda.texto2.text = self.dataNoEdit[indexPath.row][1]
                return celda
            }
            switch indexPath.row {
            case 0:
                let celda = tableView.dequeueReusableCell(withIdentifier: "celda3") as! Celda1Texto1Boton
                celda.texto.attributedText = Utils.addInitialRedAsterisk("Responsable", "HelveticaNeue-Bold", 13)
                celda.boton.tag = 0
                var dato = self.accion.CodResponsable == nil ? "- SELECCIOME -" : self.accion.Responsable
                celda.boton.setTitle(dato, for: .normal)
                celda.boton.titleLabel?.numberOfLines = 2
                if self.modo == "PUT" {
                    // celda.boton.setTitle(self.mejora.Persona, for: .normal)
                }
                return celda
            case 1:
                let celda = tableView.dequeueReusableCell(withIdentifier: "celda3") as! Celda1Texto1Boton
                celda.texto.text = "Fecha"
                celda.boton.tag = 1
                celda.boton.setTitle(Utils.date2str(Date(), "dd 'de' MMMM").uppercased(), for: .normal)
                celda.boton.titleLabel?.numberOfLines = 2
                if self.modo == "PUT" {
                    
                }
                return celda
            case 2:
                let celda = tableView.dequeueReusableCell(withIdentifier: "celda4") as! Celda1Texto1InputText
                celda.texto.attributedText = Utils.addInitialRedAsterisk("Porcentaje de avance", "HelveticaNeue-Bold", 13)
                celda.inputTexto.text = "\(self.porcentaje)"
                celda.inputTexto.tag = 0
                celda.inputTexto.keyboardType = .numberPad
                celda.inputTexto.delegate = self
                if self.modo == "PUT" {
                    
                }
                return celda
            case 3:
                let celda = tableView.dequeueReusableCell(withIdentifier: "celda5") as! Celda1Texto1InputText
                celda.texto.attributedText = Utils.addInitialRedAsterisk("Tarea realizada", "HelveticaNeue-Bold", 13)
                celda.inputTexto.text = "\(self.porcentaje)"
                celda.inputTexto.tag = 1
                celda.inputTexto.delegate = self
                if self.modo == "PUT" {
                    
                }
                return celda
            default:
                return UITableViewCell()
            }*/
        case 1: // Celda Galeria
            /*var celda = tableView.dequeueReusableCell(withIdentifier: "celda6") as! CeldaGaleria
            let dataIzq = self.multimedia[indexPath.row * 2]
            let dataDer: FotoVideo? = indexPath.row * 2 + 1 >= self.multimedia.count ? nil : self.multimedia[indexPath.row * 2 + 1]*/
            // Utils.initCeldaGaleria(&celda, dataIzq, dataDer, self.modo != "GET", tableView, indexPath)
            let celda = tableView.dequeueReusableCell(withIdentifier: "celda6") as! CeldaGaleria
            let unit1 = self.multimedia[indexPath.row * 2]
            let unit2: FotoVideo? = (indexPath.row * 2 + 1 == self.multimedia.count) ? nil : self.multimedia[indexPath.row * 2 + 1]
            celda.imagen1.image = unit1.imagen
            celda.imagen2.image = unit2 == nil ? nil : unit2!.imagen
            celda.play1.isHidden = unit1.TipoArchivo != "TP02"
            celda.play2.isHidden = unit2 == nil || unit2!.TipoArchivo != "TP02"
            celda.botonX1.tag = indexPath.row * 2
            celda.botonX2.tag = (indexPath.row * 2) + 1
            celda.boton1.tag = indexPath.row * 2
            celda.boton2.tag = (indexPath.row * 2) + 1
            celda.viewX1.isHidden = self.modo == "GET"
            celda.viewX2.isHidden = unit2 == nil || self.modo == "GET"
            celda.imagen2.isHidden = unit2 == nil
            celda.boton2.isEnabled = unit2 != nil
            return celda
        case 2: // Celda Documentos
            let celda = tableView.dequeueReusableCell(withIdentifier: "celda7") as! CeldaDocumento
            let unit = self.documentos[indexPath.row]
            celda.icono.image = unit.getIcon()
            if Globals.GaleriaDocIdRequests[indexPath.row] == -1 {
                celda.icono.isHidden = false
                celda.procentajeDescarga.isHidden = true
                celda.iconoCancelarDescarga.isHidden = true
            } else {
                celda.icono.isHidden = true
                celda.procentajeDescarga.isHidden = false
                celda.procentajeDescarga.text = "\(Globals.GaleriaDocPorcentajes[indexPath.row])%"
                celda.iconoCancelarDescarga.isHidden = false
            }
            celda.botonDescarga.tag = indexPath.row
            celda.nombre.text = unit.Descripcion
            celda.tamanho.text = unit.tamanho
            celda.viewX.isHidden = self.modo == "GET"
            return celda
        default:
            return UITableViewCell()
        }
    }
    
    @IBAction func clickResponsableFecha(_ sender: Any) {
        let boton = sender as! UIButton
        switch boton.tag {
        case 0:
            var nombres: [String] = []
            for i in 0..<self.responsables.count {
                nombres.append(self.responsables[i].Nombres ?? "")
            }
            Utils.showDropdown(boton, nombres, {(index,item) in
                // self.mejora.
                //self.data["CodPersona"] = self.responsables[index].CodPersona
                // print(self.data)
            })
        case 1:
            Utils.openDatePicker("Fecha", Date(), nil, nil, chandler: {(date) in
                boton.setTitle(Utils.date2str(date, "dd 'de' MMMM").uppercased(), for: .normal)
                // self.data["Fecha"] = Utils.date2str(date, "YYYY-MM-dd")
                // print(self.data)
            })
        default:
            break
        }
    }
    
    @IBAction func clickFlechaIzq(_ sender: Any) {
        var porcentaje = Int(self.accion.PorcentajeAvance ?? "") ?? 0
        porcentaje = porcentaje > 0 ? porcentaje - 1 : 0
        self.accion.PorcentajeAvance = "\(porcentaje)"
        self.tableView.reloadRows(at: [IndexPath.init(row: 2, section: 0)], with: .none)
    }
    
    @IBAction func clickFlechaDer(_ sender: Any) {
        var porcentaje = Int(self.accion.PorcentajeAvance ?? "") ?? 0
        porcentaje = porcentaje < 100 ? porcentaje + 1 : 100
        self.accion.PorcentajeAvance = "\(porcentaje)"
        // self.porcentaje = self.porcentaje < 100 ? self.porcentaje + 1 : 100
        self.tableView.reloadRows(at: [IndexPath.init(row: 2, section: 0)], with: .none)
    }
    
    @IBAction func clickImagen(_ sender: Any) {
    }
    
    @IBAction func clickImagenX(_ sender: Any) {
    }
    
    @IBAction func clickDocumento(_ sender: Any) {
    }
    
    @IBAction func clickDocumentoX(_ sender: Any) {
    }
    
    @IBAction func clickTituloBotonDer(_ sender: Any) {
        let boton = sender as! UIButton
        switch boton.tag {
        case 0:
            let pickerController = DKImagePickerController()
            pickerController.assetFilter = { (asset) in
                if let resource = PHAssetResource.assetResources(for: asset).first {
                    let fileSize = resource.value(forKey: "fileSize") as? Int ?? 1024 * 1024 * 8
                    return fileSize < 1024 * 1024 * 8
                }
                return false
            }
            pickerController.didSelectAssets = { (assets: [DKAsset]) in
                if assets.count > 0 {
                    for i in 0..<assets.count {
                        if assets[i].isVideo {
                            self.loadAssetVideo(asset: assets[i])
                        } else {
                            self.loadAssetImagen(asset: assets[i])
                        }
                    }
                }
            }
            self.present(pickerController, animated: true) {}
        case 1:
            break
        default:
            break
        }
    }
    
    
    
    
    @IBAction func clickTopDer(_ sender: Any) {
        var titulo = ""
        
        if (self.accion.CodResponsable ?? "").trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            titulo = "Responsable"
        }
        if (self.accion.PorcentajeAvance ?? "").trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            titulo = "Porcentaje de avance"
        }
        if (self.accion.Descripcion ?? "").trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            titulo = "Tarea realizada"
        }
        
        if titulo != "" {
            self.presentError("El campo \(titulo) no puede estar vacío")
            return
        }
        self.accion.Fecha = self.accionFecha.toString("YYYY-MM-dd")
        
        let copia = self.accion.copy()
        copia.Responsable = nil
        copia.Files = nil
        
        
        let cabecera = String.init(data: Dict.unitToData(Dict.unitToParams(copia))!, encoding: .utf8)!
        
        var arrayData = [Data]()
        var arrayNames = [String]()
        var arrayFileNames = [String]()
        var arrayMimeTypes = [String]()
        
        for i in 0..<self.multimedia.count {
            let unit = self.multimedia[i]
            if unit.Correlativo == nil && unit.multimediaData != nil && unit.Descripcion != nil {
                arrayData.append(unit.multimediaData!)
                arrayNames.append("multimedia\(i)")
                arrayFileNames.append(unit.Descripcion!)
                arrayMimeTypes.append(unit.mimeType!)
            }
        }
        for i in 0..<self.documentos.count {
            let unit = self.documentos[i]
            if unit.Correlativo == nil && unit.multimediaData != nil && unit.Descripcion != nil {
                arrayData.append(unit.multimediaData!)
                arrayNames.append("documento\(i)")
                arrayFileNames.append(unit.Descripcion!)
                arrayMimeTypes.append(unit.mimeType!)
            }
        }
        
        var toDel = (self.correlativosABorrar.map{String($0)}).joined(separator: ";")
        toDel = toDel == "" ? "-" : toDel
        self.idPost = Rest.generateId()
        var correlativo = self.accion.Correlativo == nil ? "-1" : "\(self.accion.Correlativo!)"
        
        Rest.postMultipartFormData(Routes.forAccionMejoraPutPost(), params: [["1", cabecera], ["2", toDel], ["3", self.codPlanAccion], ["4", correlativo]], arrayData, arrayNames, arrayFileNames, arrayMimeTypes, true, idPost, success: {(resultValue:Any?,data:Data?) in
            print(resultValue)
        }, progress: {(progreso) in
            
        }, error: {(error) in
            print(error)
        })
    }
    
    func loadAssetVideo(asset: DKAsset) {
        var flagImage = false
        var flagVideoData = false
        var fotovideo = FotoVideo()
        fotovideo.TipoArchivo = asset.isVideo ? "TP02" : "TP01"
        fotovideo.asset = asset
        fotovideo.Descripcion = PHAssetResource.assetResources(for: asset.originalAsset!).first?.originalFilename
        Utils.bloquearPantalla()
        asset.fetchImageWithSize(CGSize.init(width: 200, height: 200), completeBlock: {(image,info) in
            flagImage = true
            if let newImage = image {
                fotovideo.imagen = newImage
            }
            if flagImage && flagVideoData {
                Utils.desbloquearPantalla()
                Dict.unitToData(fotovideo)
                if fotovideo.imagen != nil && fotovideo.multimediaData != nil && !self.nombres.contains(fotovideo.Descripcion ?? "") {
                    self.multimedia.append(fotovideo)
                    self.nombres.insert(fotovideo.Descripcion ?? "")
                    self.tableView.reloadData()
                }
            }
        })
        PHImageManager.default().requestAVAsset(forVideo: asset.originalAsset!, options: nil, resultHandler: {(avasset,mix,info) in
            flagVideoData = true
            // asset.originalAsset?.value(forKey: "fileName")
            do {
                let myAsset = avasset as? AVURLAsset
                fotovideo.multimediaData = try Data(contentsOf: (myAsset?.url)!)
                // = videoData  //Set video data to nil in case of video
                // print("video data : \(videoData)")
            } catch {
                fotovideo.multimediaData = nil
            }
            if flagImage && flagVideoData {
                Utils.desbloquearPantalla()
                Dict.unitToData(fotovideo)
                if fotovideo.imagen != nil && fotovideo.multimediaData != nil && !self.nombres.contains(fotovideo.Descripcion ?? "") {
                    self.multimedia.append(fotovideo)
                    self.nombres.insert(fotovideo.Descripcion ?? "")
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    func loadAssetImagen(asset: DKAsset) {
        var flagImage = false
        var flagImagefull = false
        var flagImageData = false
        var fotovideo = FotoVideo()
        fotovideo.TipoArchivo = asset.isVideo ? "TP02" : "TP01"
        // fotovideo.esVideo = asset.isVideo
        fotovideo.asset = asset
        fotovideo.Descripcion = PHAssetResource.assetResources(for: asset.originalAsset!).first?.originalFilename
        fotovideo.setMimeType()
        Utils.bloquearPantalla()
        asset.fetchImageWithSize(CGSize.init(width: 200, height: 200), completeBlock: {(image,info) in
            flagImage = true
            if let newImage = image {
                fotovideo.imagen = newImage
            }
            if flagImage && flagImagefull && flagImageData {
                Utils.desbloquearPantalla()
                Dict.unitToData(fotovideo)
                if !(fotovideo.imagen == nil) && !(fotovideo.multimediaData == nil) && !self.nombres.contains(fotovideo.Descripcion ?? "") {
                    self.multimedia.append(fotovideo)
                    self.nombres.insert(fotovideo.Descripcion ?? "")
                    self.tableView.reloadData()
                }
            }
        })
        asset.fetchOriginalImage(false, completeBlock: {(image,info) in
            flagImagefull = true
            if let newImageFull = image {
                fotovideo.imagenFull = newImageFull
            }
            if flagImage && flagImagefull && flagImageData {
                Utils.desbloquearPantalla()
                Dict.unitToData(fotovideo)
                if !(fotovideo.imagen == nil) && !(fotovideo.multimediaData == nil) && !self.nombres.contains(fotovideo.Descripcion ?? "") {
                    self.multimedia.append(fotovideo)
                    self.nombres.insert(fotovideo.Descripcion ?? "")
                    self.tableView.reloadData()
                }
            }
        })
        asset.fetchImageDataForAsset(false, completeBlock: {(imageData,info) in
            flagImageData = true
            if let newData = imageData {
                fotovideo.multimediaData = newData
            }
            if flagImage && flagImagefull && flagImageData {
                Utils.desbloquearPantalla()
                Dict.unitToData(fotovideo)
                if !(fotovideo.imagen == nil) && !(fotovideo.multimediaData == nil) && !self.nombres.contains(fotovideo.Descripcion ?? "") {
                    self.multimedia.append(fotovideo)
                    self.nombres.insert(fotovideo.Descripcion ?? "")
                    self.tableView.reloadData()
                }
            }
        })
    }
}

