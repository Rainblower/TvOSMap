//
//  ViewController.swift
//  TvOSMap
//
//  Created by WSR on 22/06/2019.
//  Copyright © 2019 WSR. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {

    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var degLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        fetchData()
    }
    
    func fetchData() {
        guard let city = UserDefaults.standard.string(forKey: "City") else { return }
        
        let apiKey = "481fe76799a037e2752c45759ed5b3ab"
        guard let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=metric") else { return }
        
        Alamofire.request(url, method: .get).validate().responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                self.cityNameLabel.text = city.capitalized
                self.degLabel.text = "\(Int(Float(json["main"]["temp"].stringValue)!)) Cº"
                self.windSpeedLabel.text = json["wind"]["speed"].stringValue
                self.descLabel.text = json["weather"][0]["main"].stringValue.capitalized
                
                let icon = json["weather"][0]["icon"].stringValue
                let imgStr = "http://openweathermap.org/img/w/" + icon + ".png"
                guard let imageUrl = URL(string: imgStr) else { return }
                
                if let data = try? Data(contentsOf: imageUrl) {
                    self.imgView.image = UIImage(data: data)
                }
                
            case .failure(let error):
                print(error)
            }
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchData()
    }
    
    
    
    @IBAction func openMap(_ sender: Any) {
        performSegue(withIdentifier: "Map", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let map = segue.destination as? MapViewController else { return }
        guard let city = UserDefaults.standard.string(forKey: "City") else { return }

        map.savedCity = city
        
    }
    
   
    
}

