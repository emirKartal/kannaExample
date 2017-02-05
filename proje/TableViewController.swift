//
//  TableViewController.swift
//  proje
//
//  Created by Emir Kartal on 4.02.2017.
//  Copyright © 2017 Emir Kartal. All rights reserved.
//

import UIKit
import Alamofire
import Kanna
import AlamofireImage


class TableViewController: UITableViewController {
    
    var titleArr:[String] = []
    var imageArr:[String] = []
    var hrefArr:[String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        connect()
    }
   
    func connect(){
        Alamofire.request("https://www.wired.com/").responseString { response in
            print("\(response.result.isSuccess)")
            if let html = response.result.value {
                self.parseHTML(html: html)
            }
        }
    }
    
    
    func parseHTML(html: String){
    
        if let doc = Kanna.HTML(html: html, encoding: String.Encoding.utf8) {
         
            var a = 0
            for show in doc.css("ul[id='latest-news-list'] > li") {
                
                let href = show.css("a").first?["href"]
                let img = show.css("a > picture > img[class='wired-lazy-load']").first?["data-src"]
                let title = show.css("a > span").first?.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                
                titleArr.append(title!)
                imageArr.append(img!)
                hrefArr.append(href!)
                a += 1
                if a == 5 { break }
            }

           self.tableView.reloadData()
        }
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return titleArr.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = titleArr[indexPath.row]
        
        let thumbURL = imageArr[indexPath.row]
        Alamofire.request(thumbURL).responseImage { response in
            if let _img = response.result.value {
                cell.imageView?.image = _img
                cell.imageView?.frame.size = CGSize(width: 60, height: 90)
                cell.imageView?.contentMode = .scaleAspectFit
            }
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toDetail", sender: hrefArr[indexPath.row])
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            if let vc = segue.destination as? ViewController {
                vc.detailLink = sender as! String
            }
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
