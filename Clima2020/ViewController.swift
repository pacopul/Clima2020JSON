//
//  ViewController.swift
//  Clima2020
//
//  Created by IPaco on 22/01/2020.
//  Copyright © 2020 IPaco. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var ivIcoCurrent: UIImageView!
    @IBOutlet weak var lblPronoCurrent: UILabel!
    @IBOutlet weak var lblTempCuerrent: UILabel!
    @IBOutlet weak var lblPPCurrent: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var result:Result!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        jsonDecoding()
    }
    
    func jsonDecoding() {
        
        // Ejemplo del uso de Codable Protocol para parsear un JSON
        // Para ello hemos implementado las clases adecuadas en Result.swift
        let  urlTxt="http://api.worldweatheronline.com/premium/v1/weather.ashx?key=d31d55472f974dacb06200547202101&q=Toledo,Spain&num_of_days=10&fx24=yes&lang=es&mca=no&tp=24&format=json"

        guard let url = URL(string: urlTxt) else {return}
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            guard let data = data else {return}
            do {
                self.result =  try JSONDecoder().decode(Result.self, from: data)
            } catch let jsonErr {
                print("Error serializing json", jsonErr)
            }
            // Como estamos en un hilo, IOS no nos deja
            // pintar desde el. Solo desde el main thread
            // es por ello que encerramos el actualizar la UI
            // en un bloque DispatchQueue.main.async
            DispatchQueue.main.async {
                self.pintaCurrent()
                self.tableView.reloadData()
            }
        }.resume()
            
    }
    
    // Metodos del TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let n = result?.datos?.weather?.count{
            return n
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tableView.dequeueReusableCell(withIdentifier: "celdaID", for: indexPath) as! MiCelda
        let dia = result?.datos?.weather![indexPath.row]
        // ico
        let url = URL(string: (dia?.hourly![0].icon![0].value)!)
        let data = try? Data(contentsOf: url!)
        celda.ivIcoCalda.image = UIImage(data: data!)
        // resto
        let prono = dia?.hourly![0].prono![0].value
        celda.lblPronoCelda.text = prono!
        let max = dia?.max
        celda.lblMaxCelda.text = "\(max!)º"
        let min = dia?.min
        celda.lblMaxCelda.text = "\(min!)º"
        let pre = dia?.hourly![0].preci
        celda.lblPreCelda.text = "\(pre!)%"
        
        return celda
    }
    
    // Vistas
    
    func pintaCurrent(){
        let current = result?.datos?.current![0]
        let url = URL(string: (current?.icon![0].value)!)
        
        // Normalmente debemos encerrar la bajada de la image
        // entre un DispatchQueue.main.async
        // Aquí no lo hacemos porqur todo el método es llamado
        // en un bloque DispatchQueue.main.async
        
        let data = try? Data(contentsOf: url!)
        ivIcoCurrent.image = UIImage(data: data!)
        let prono = current!.prono![0].value
        lblPronoCurrent.text = prono!
        let temp = current!.temp
        lblTempCuerrent.text = "\(temp!)º"
        let pre = current!.pre
        lblPPCurrent.text = "\(pre!)%"
    }
}

