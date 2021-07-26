//
//  ShopDetailViewController.swift
//  restaurant_search_App
//
//  Created by 佐藤駿樹 on 2021/07/21.
//

import UIKit
import SDWebImage

class ShopDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var detailShopData = [ShopData]()
    
    @IBOutlet weak var shopImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoTableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    let shopInfoArray = ["店舗名", "住所", "営業時間", "アクセス", "予算", "駐車場"]
    
    var infoArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shopImageView.sd_setImage(with: URL(string: detailShopData[0].shopImage!), completed: nil)
        nameLabel.text = detailShopData[0].name
        
        if detailShopData.isEmpty != true {
            infoArray.append(detailShopData[0].name!)
            infoArray.append(detailShopData[0].address!)
            infoArray.append(detailShopData[0].open!)
            infoArray.append(detailShopData[0].access!)
            infoArray.append(detailShopData[0].budget!)
            infoArray.append(detailShopData[0].parking!)
        }
        
        infoTableView.delegate = self
        infoTableView.dataSource = self
        
        infoTableView.estimatedRowHeight = 100
        infoTableView.rowHeight = UITableView.automaticDimension
        infoTableView.tableFooterView = UIView()
        infoTableView.allowsSelection = false
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        tableViewHeight.constant = CGFloat(infoTableView.contentSize.height)
        
        let scrollViewHeight = shopImageView.bounds.size.height + 8 + nameLabel.bounds.size.height + 8 + tableViewHeight.constant
        scrollView.contentSize.height = scrollViewHeight
        print("高さ\(scrollViewHeight)")
        
    }
    

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shopInfoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let titleLabel = cell.contentView.viewWithTag(1) as! UILabel
        titleLabel.text = shopInfoArray[indexPath.row]
        
        let infoLabel = cell.contentView.viewWithTag(2) as! UILabel
        infoLabel.text = infoArray[indexPath.row]
        
        return cell
    }
}
