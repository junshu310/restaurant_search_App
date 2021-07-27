//
//  ViewController.swift
//  restaurant_search_App
//
//  Created by 佐藤駿樹 on 2021/07/13.
//

import UIKit
import MapKit
import SVProgressHUD

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate, DoneCatchDataProtocol {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var rangeTextField: UITextField!
    
    
    let pickerView = UIPickerView()
    let rangeArray = ["300m", "500m", "1km", "2km", "3km"]
    var rangeTextIndex = Int()
    
    @IBOutlet weak var mapView: MKMapView!
    
    var APIKey = "c2553ee4fae8322f"
    var keyword = String()
    var range = 3
    
    let locationManager = CLLocationManager()
    var latitudeValue = Double()
    var longitudeValue = Double()
    
    var shopDataArray = [ShopData]()
    var resultsAvailable = Int()
    
    var annotation = MKPointAnnotation()
    var annotationShopData = [ShopData]()
    var nameArray = [String]()
    var indexNumber = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.delegate = self
        rangeTextField.delegate = self
        searchButton.layer.cornerRadius = searchButton.bounds.size.width / 2
        rangeTextField.layer.cornerRadius = 10.0
        rangeTextField.addTarget(self, action: #selector(self.tap), for: .touchDown)
        rangeTextField.addTarget(self, action: #selector(self.tapCancel), for: .touchCancel)
        
        rangeTextField.text = "検索範囲：" + rangeArray[2]
        
        startUpdatingLocation()
        configureSubViews()
        
        setPickerView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @objc func tap() {
        rangeTextField.textColor = UIColor(red: 0.207, green: 0.472, blue: 0.967, alpha: 0.8)
    }
    @objc func tapCancel() {
        rangeTextField.textColor = UIColor(red: 0.207, green: 0.472, blue: 0.967, alpha: 1.0)
    }
    
    func setPickerView() {
        
        pickerView.delegate = self
        pickerView.dataSource = self
        let toolBar = UIToolbar()
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(ViewController.tappedDone))
        let cancelButton = UIBarButtonItem(title: "キャンセル", style: .done, target: self, action: #selector(ViewController.tappedCancel))
        toolBar.items = [cancelButton, space, doneButton]
        toolBar.sizeToFit()
        rangeTextField.inputView = pickerView
        rangeTextField.inputAccessoryView = toolBar
    }
    
    @objc func tappedDone() {
        rangeTextField.text = "検索範囲：" + rangeArray[rangeTextIndex]
        range = rangeTextIndex + 1
        rangeTextField.resignFirstResponder()
    }
    
    @objc func tappedCancel() {
        rangeTextField.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if searchTextField.isHidden == false {
            searchTextField.resignFirstResponder()
        }
        
        if rangeTextField.isHidden == false {
            rangeTextField.resignFirstResponder()
        }
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
        
        searchTextField.resignFirstResponder()
        SVProgressHUD.show()
        
        let urlString = "http://webservice.recruit.co.jp/hotpepper/gourmet/v1/?key=\(APIKey)&lat=\(latitudeValue)&lng=\(longitudeValue)&range=\(range)&count=100&keyword=\(searchTextField.text!)&format=json"
        
        let analyticsModel = AnalyticsModel(url: urlString, latitude: latitudeValue, longitude: longitudeValue, range: range)
        
        analyticsModel.doneCatchDataProtocol = self
        analyticsModel.setData()

    }

    func doneCatchData(shopDataArray: Array<ShopData>, resultsCount: Int) {
        
        //データの取得完了
        SVProgressHUD.dismiss()
        
        if resultsCount == 0 {
            let alert = UIAlertController(title: "検索結果なし", message: "検索条件を変更して下さい。", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            
        } else {
            
            self.shopDataArray = shopDataArray
            self.resultsAvailable = resultsCount
            //検索結果からピンを表示する
            addAnnotaton(shopData: self.shopDataArray)
        }
    }
    
    func addAnnotaton(shopData:[ShopData]) {
        
        //初めに、重複を防ぐためにピンを削除する
        mapView.removeAnnotations(mapView.annotations)
        annotationShopData = []
        nameArray = []
        
        //ピンをfor文で一つずつ生成
        for i in 0 ... resultsAvailable - 1 {
            
            //anotationを初期化(インスタンス化)
            annotation = MKPointAnnotation()
            //緯度経度を指定
            annotation.coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(shopData[i].latitude!), CLLocationDegrees(shopData[i].longitude!))
            annotation.title = shopData[i].name
            
            //選択された情報(shopData[i])を渡したい。
            annotationShopData.append(shopData[i])
            nameArray.append(shopData[i].name!)
            
            mapView.addAnnotation(annotation)
        }
    }
    
    //annotationが選択された時
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        //空判定
        if nameArray.firstIndex(of: (view.annotation?.title)!!) != nil {
            //annotationのタイトルとnameArrayで一致するもの。それがnameArrayの中で何番目にあるかが分かる。
            indexNumber = nameArray.firstIndex(of: (view.annotation?.title)!!)!
            print(indexNumber)
        }
        
        performSegue(withIdentifier: "mapToDetail", sender: nil)
    }
    
    @IBAction func toList(_ sender: Any) {
        performSegue(withIdentifier: "toList", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "mapToDetail" {
            let detailVC = segue.destination as! ShopDetailViewController
            detailVC.detailShopData.append(annotationShopData[indexNumber])
        }
        
        if segue.identifier == "toList" {
            let shopListVC = segue.destination as! ShopListViewController
            shopListVC.passedShopData = annotationShopData
        }
    }
    
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    //PickerViewの設定
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return rangeArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return rangeArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        rangeTextIndex = row
    }
    
}
