//
//  AnalyticsModel.swift
//  restaurant_search_App
//
//  Created by 佐藤駿樹 on 2021/07/17.
//

import Foundation
import SwiftyJSON
import Alamofire
import SVProgressHUD

protocol DoneCatchDataProtocol {
    
    func doneCatchData(shopDataArray: Array<ShopData>, resultsCount: Int)
}

class AnalyticsModel {
    
    
    var urlString = String()
    var latitude = Double()
    var longitude = Double()
    var range = Int()
    
    var shopData = [ShopData]()
    var doneCatchDataProtocol: DoneCatchDataProtocol?
    
    init(url: String, latitude: Double, longitude: Double, range: Int) {
        
        self.urlString = url
        self.latitude = latitude
        self.longitude = longitude
        self.range = range
    }
    
    //JSON解析を行う
    func setData() {
        
        let encodeURLString: String = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        //通信を行う。(HTTPリクエスト)
        AF.request(encodeURLString, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { response in
            
            print(response.debugDescription)
            
            switch response.result {
            
            case .success:
                //レスポンスが正常の時
                do {
                    let json: JSON = try JSON(data: response.data!)
                    var resultsAvailable = json["results"]["results_available"].int
                    
//                    //最大取得件数を100件にする
                    if resultsAvailable! > 100 {
                        resultsAvailable = 100
                    }
                    if resultsAvailable != 0 {
                        //取得件数分、for文を回す
                        for i in 0 ... resultsAvailable! - 1 {
                            
                            if json["results"]["shop"][i]["name"] != "" &&
                                json["results"]["shop"][i]["lat"] != "" &&
                                json["results"]["shop"][i]["lng"] != "" &&
                                json["results"]["shop"][i]["urls"]["pc"] != "" {
                                
                                let shopData = ShopData(
                                    name: json["results"]["shop"][i]["name"].string,
                                    latitude: json["results"]["shop"][i]["lat"].double,
                                    longitude: json["results"]["shop"][i]["lng"].double,
                                    url: json["results"]["shop"][i]["urls"]["pc"].string,
                                    shopImage: json["results"]["shop"][i]["photo"]["pc"]["l"].string,
                                    address: json["results"]["shop"][i]["address"].string,
                                    budget: json["results"]["shop"][i]["budget"]["name"].string,
                                    access: json["results"]["shop"][i]["access"].string,
                                    open: json["results"]["shop"][i]["open"].string,
                                    parking: json["results"]["shop"][i]["parking"].string)
                                
                                self.shopData.append(shopData)
                            } else {
                                print("空の項目があります。")
                            }
                        }
                    } else {
                        print("検索結果なし。")
                    }
                    
                    
                    //全ての値を取得完了。
                    //ここが呼ばれた時を検知する。(プロトコルに値を渡して処理を適当な位置に書く。)
                    self.doneCatchDataProtocol?.doneCatchData(shopDataArray: self.shopData, resultsCount: self.shopData.count)
                    
                } catch {
                    print("エラー")
                }
                
                break
            
            case .failure:
                SVProgressHUD.dismiss()
                print("情報を取得できませんでした。")
                break
            }
        }
    }
}
