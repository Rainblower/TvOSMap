//
//  MapViewController.swift
//  TvOSMap
//
//  Created by WSR on 22/06/2019.
//  Copyright © 2019 WSR. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import SwiftyJSON

class MapViewController: UIViewController {

    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var degLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var weatherView: UIView!
    
    var savedCity: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        
        if savedCity != nil {
            searchCity(city: savedCity)
        }
        // Do any additional setup after loading the view.
    }


    func searchCity(city: String) {
        let apiKey = "481fe76799a037e2752c45759ed5b3ab"
        guard let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=metric") else { return }
        print(url)
        Alamofire.request(url, method: .get).validate().responseJSON { (response) in
            print(response)
            
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                let lat = Double(json["coord"]["lat"].stringValue)!
                let lon = Double(json["coord"]["lon"].stringValue)!
                
                self.cityNameLabel.text = city.capitalized
                self.degLabel.text = "\(Int(Float(json["main"]["temp"].stringValue)!)) Cº"
                self.speedLabel.text = json["wind"]["speed"].stringValue
                
                let icon = json["weather"][0]["icon"].stringValue
                let imgStr = "http://openweathermap.org/img/w/" + icon + ".png"
                print(imgStr)
                guard let imageUrl = URL(string: imgStr) else { return }
                
                if let data = try? Data(contentsOf: imageUrl) {
                    self.imageView.image = UIImage(data: data)
                }
                
                self.weatherView.isHidden = false
                UserDefaults.standard.set(city.capitalized, forKey: "City")
                
                self.showCityOnMap(lat: lat, lon: lon)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func showCityOnMap(lat: Double, lon: Double) {
        let coordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: lon), latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(coordinateRegion, animated: true)
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        mapView.addAnnotation(annotation)
    }
}

extension MapViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let cityName = textField.text else { return true }
        searchCity(city: cityName)
        return true
    }
}
