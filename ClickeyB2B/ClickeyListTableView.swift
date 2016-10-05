//
//  ClickeyListTableView.swift
//  ClickeyB2B
//
//  Created by Ben Smith on 05/10/16.
//  Copyright © 2016 Ben Smith. All rights reserved.
//

import Foundation
class ClickeyListViewController: UIViewController, ClickeyServiceConsumer, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var clickeyTable: UITableView?
    var clickeyList = [ClickeyServerModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        var nib = UINib(nibName: "ClickeyTableViewCell", bundle: nil)
        clickeyTable!.registerNib(nib, forCellReuseIdentifier: "ClickeyTableViewCell")
        
        if let savedToken = NSUserDefaults.standardUserDefaults().valueForKey("TOKEN") as? String{
            print("savedToken: \(savedToken.stringByRemovingPercentEncoding)")
            getDevices()
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "getDevices", name: "getDevices", object: nil)

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var topCell = (tableView.dequeueReusableCellWithIdentifier("ClickeyTableViewCell", forIndexPath: indexPath) as! ClickeyTableViewCell)
        topCell.descriptionClickey?.text = self.clickeyList[indexPath.row].desc
        return topCell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.clickeyList.count
    }
    
    func getDevices(){
        service.getClickeys { result in
            if let clickeys = result.object {
                self.clickeyList = clickeys
                self.clickeyTable?.reloadData()
            }
        }
    }
}