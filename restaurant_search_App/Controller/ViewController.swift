//
//  ViewController.swift
//  restaurant_search_App
//
//  Created by 佐藤駿樹 on 2021/07/13.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate {

    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var keyword = String()
    
    let locationManager = CLLocationManager()
    var latitudeValue = Double()
    var longitudeValue = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.delegate = self
        searchButton.layer.cornerRadius = searchButton.bounds.size.width / 2
        
        startUpdatingLocation()
        configureSubViews()
    }

    //許可画面
    func startUpdatingLocation() {
        
        locationManager.requestAlwaysAuthorization()
        
        let status = CLAccuracyAuthorization.fullAccuracy
        if status == .fullAccuracy {
            locationManager.startUpdatingLocation()
        }
    }
    
    //許可のステータス
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        switch manager.authorizationStatus {
        
        case .authorizedAlways, .authorizedWhenInUse:
            //位置情報の取得を許可している
            break
        case .notDetermined, .denied, .restricted:
            //許可していない
            break
        default:
            print("Unhandled case")
        }
        
        switch manager.accuracyAuthorization {
        case .fullAccuracy:
            //正確な位置情報の取得を許可している
            break
        case .reducedAccuracy:
            //正確な位置情報の取得を許可していない
            break
        default:
            print("This should not happen!")
        }
    }
    
    func configureSubViews() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 10
        //位置情報の取得開始
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.userTrackingMode = .follow
    }
    
    //位置情報を取得後呼ばれる
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //取得した緯度経度の値を取ってくる
        let location = locations.first
        let latitude = location?.coordinate.latitude
        let longitude = location?.coordinate.longitude
        
        latitudeValue = latitude!
        longitudeValue = longitude!
        
        print(latitudeValue)
        print(longitudeValue)
    }
    
    @IBAction func search(_ sender: Any) {
        //検索結果からピンを表示する
    }
    
}

