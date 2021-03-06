import UIKit

class UpsertInsObsPVCTab3: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let padre = self.parent?.parent as? UpsertInsObsVC {
            padre.selectTab(2)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let celda = tableView.dequeueReusableCell(withIdentifier: "celda1")!
        return celda.contentView
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Globals.UIOTab3Planes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tableView.dequeueReusableCell(withIdentifier: "celda2") as! Celda3Texto1Boton
        let unit = Globals.UIOTab3Planes[indexPath.row]
        celda.texto1.text = unit.DesPlanAccion ?? ""
        celda.texto2.text = Utils.searchMaestroStatic("ESTADOPLAN", unit.CodEstadoAccion ?? "")
        celda.texto3.text = Utils.searchMaestroStatic("NIVELRIESGO", unit.CodNivelRiesgo ?? "")
        celda.boton.tag = indexPath.row
        return celda
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let unit = Globals.UIOTab3Planes[indexPath.row]
        /*let muroElement = MuroElement()
        muroElement.Codigo = Globals.UICodigo*/
        let copia = unit.copy()
        copia.NroDocReferencia = Globals.UICodigo
        copia.NroAccionOrigen = Globals.UIOTab1ObsDetalle.NroDetInspeccion
        copia.FechaSolicitud = Utils.date2str(Date(), "YYYY-MM-dd")
        copia.SolicitadoPor = Utils.userData.Nombres
        copia.CodSolicitadoPor = Utils.userData.CodPersona
        VCHelper.openUpsertPlanAccion(self, "PUT", copia, nil, {(newplan) in
            Globals.UIOTab3Planes[indexPath.row] = newplan
            self.tableView.reloadData()
        })
        /*let plan = PlanAccionDetalle()
        plan.NroDocReferencia = Globals.UICodigo
        plan.NroAccionOrigen = Globals.UIOTab1ObsDetalle.NroDetInspeccion
        
        VCHelper.openUpsertObsPlan(self, 2, unit, muroElement, {(nuevoplan) in
            var copia = nuevoplan.copy()
            copia.Responsables = nil
            copia.SolicitadoPor = nil
            copia.NroDocReferencia = Globals.UICodigo
            copia.NroAccionOrigen = Globals.UIOTab1ObsDetalle.NroDetInspeccion
            Rest.postDataGeneral(Routes.forPostPlanAccion(), Dict.unitToParams(copia), true, success: {(resultValue:Any?,data:Data?) in
                var strResult = resultValue as! String
                if strResult == "-1" {
                    self.presentAlert("Error", "Ocurrió un error al ingresar el plan de acción", .alert, 2, nil, [], [], actionHandlers: [])
                } else {
                    self.presentAlert("Edición exitosa", "Se realizaron los cambios correctamente", .alert, 2, nil, [], [], actionHandlers: [])
                    Globals.UIOTab3Planes[indexPath.row] = nuevoplan
                    self.tableView.reloadData()
                }
            }, error: {(error) in
                print(error)
            })
        })*/
    }
    
    @IBAction func clickAddInsObsPlanAccion(_ sender: Any) {
        var plan = PlanAccionDetalle()
        plan.CodTabla = "TINS"
        plan.CodReferencia = "02"
        plan.CodAccion = "-1"
        plan.FechaSolicitud = Utils.date2str(Date(), "YYYY-MM-dd")
        plan.SolicitadoPor = Utils.userData.Nombres
        plan.CodSolicitadoPor = Utils.userData.CodPersona
        
        switch Globals.UIModo {
        case "ADD":
            VCHelper.openUpsertPlanAccion(self, "ADD", plan, {(newplan) in
                Globals.UIOTab3Planes.append(newplan)
            }, {(newplan) in
                self.tableView.reloadData()
            })
        case "PUT":
            plan.CodEstadoAccion = "01"
            plan.NroDocReferencia = Globals.UICodigo
            plan.NroAccionOrigen = Globals.UIOTab1ObsDetalle.NroDetInspeccion
            VCHelper.openUpsertPlanAccion(self, "ADD", plan, nil, {(newplan) in
                Globals.UIOTab3Planes.append(newplan)
                self.tableView.reloadData()
            })
        default:
            break
        }
        
        
        /*VCHelper.openUpsertObsPlan(self, 1, planMuestra, MuroElement(), {(plan) in
            switch Globals.UIOModo {
            case "ADD":
                plan.CodAccion = "-1"
                Globals.UIOTab3Planes.append(plan)
                self.tableView.reloadData()
            case "PUT":
                plan.CodAccion = "-1"
                plan.CodEstadoAccion = "01"
                var copia = plan.copy()
                copia.Responsables = nil
                copia.SolicitadoPor = nil
                copia.NroDocReferencia = Globals.UICodigo
                copia.NroAccionOrigen = Globals.UIOTab1ObsDetalle.NroDetInspeccion
                Rest.postDataGeneral(Routes.forPostPlanAccion(), Dict.unitToParams(copia), true, success: {(resultValue:Any?,data:Data?) in
                    var strResult = resultValue as! String
                    if strResult == "-1" {
                        self.presentAlert("Error", "Ocurrió un error al ingresar el plan de acción", .alert, 2, nil, [], [], actionHandlers: [])
                    } else {
                        self.presentAlert("Operación exitosa", "Se creó el Plan de Acción correctamente", .alert, 2, nil, [], [], actionHandlers: [])
                        plan.CodAccion = strResult
                        Globals.UIOTab3Planes.append(plan)
                        self.tableView.reloadData()
                    }
                }, error: {(error) in
                    print(error)
                })
            default:
                break
            }
        })*/
    }
    
    @IBAction func clickEliminarPlanAccion(_ sender: Any) {
        let boton = sender as! UIButton
        if Globals.UIOModo == "PUT" {
            Globals.UIOTab3PlanesToDel.insert(Globals.UIOTab3Planes[boton.tag].CodAccion!)
        }
        Globals.UIOTab3Planes.remove(at: boton.tag)
        self.tableView.reloadData()
        
    }
    
}


