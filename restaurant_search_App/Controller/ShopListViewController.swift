//
//  ShopListViewController.swift
//  restaurant_search_App
//
//  Created by 佐藤駿樹 on 2021/07/21.
//

import UIKit
import SDWebImage

class ShopListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var passedShopData = [ShopData]()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        if passedShopData.isEmpty == true {
            let emptyLabel = UILabel()
            emptyLabel.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height)
            emptyLabel.textAlignment = .center
            emptyLabel.text = "検索結果がありません。\n条件を変更して検索して下さい。"
            emptyLabel.textColor = UIColor.lightGray
            emptyLabel.numberOfLines = 2
//            emptyLabel.font =
            self.view.addSubview(emptyLabel)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return passedShopData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let shopImageView = cell.contentView.viewWithTag(1) as! UIImageView
        shopImageView.sd_setImage(with: URL(string: passedShopData[indexPath.row].shopImage!), completed: nil)
        
        let nameLabel = cell.contentView.viewWithTag(2) as! UILabel
        nameLabel.text = passedShopData[indexPath.row].name
        
        let accessLabel = cell.contentView.viewWithTag(3) as! UILabel
        accessLabel.text = passedShopData[indexPath.row].access
        
        let budgetLabel = cell.contentView.viewWithTag(4) as! UILabel
        budgetLabel.text = passedShopData[indexPath.row].budget
        
        let parkingLabel = cell.contentView.viewWithTag(5) as! UILabel
        parkingLabel.text = passedShopData[indexPath.row].parking
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
