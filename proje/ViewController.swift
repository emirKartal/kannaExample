//
//  ViewController.swift
//  proje
//
//  Created by Emir Kartal on 3.02.2017.
//  Copyright © 2017 Emir Kartal. All rights reserved.
//

import UIKit
import Alamofire
import Kanna
import AlamofireImage

class ViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    var detailLink = ""
    var articleContent = ""
    var articleTitle = ""
    var articleImg = ""
    
    @IBOutlet weak var btnTrans: UIButton!
    @IBOutlet weak var artContent: UITextView!
    @IBOutlet weak var artImg: UIImageView!
    @IBOutlet weak var artTitle: UILabel!
    @IBAction func btnTranslate(_ sender: Any) {
        performSegue(withIdentifier: "toTranslate", sender: sendingDic)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTranslate" {
            if let vc = segue.destination as? TranslateVC {
                vc.popoverPresentationController?.delegate = self
                vc.preferredContentSize = CGSize(width: self.view.frame.width / 2, height: 250)
                vc.popoverPresentationController?.sourceView = btnTrans
                vc.popoverPresentationController?.sourceRect = btnTrans.bounds
                vc.takenDic = sender as! Dictionary<String, String>
            }
        }
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailHTML(url: detailLink)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        artTitle.text = articleTitle
        artContent.text = articleContent
        
        Alamofire.request(articleImg).responseImage { response in
            if let pict = response.result.value {
                self.artImg.image = pict
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func detailHTML(url: String)  {
        Alamofire.request(url).responseString { response in
            
            if let html = response.result.value {
                
                if let doc = Kanna.HTML(html: html, encoding: String.Encoding.utf8) {
                    let title = doc.css("h1").first?.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    let img = doc.css("figure > img").first?["src"]
                    let content = doc.css("section[id='start-of-content']").first
                    if img != nil {
                        self.articleImg = img!
                    }
                    self.articleTitle = title!
                    // yazılar alınıyor
                    for ct in (content?.css("article > p"))! {
                        self.articleContent += ct.text!
                        //print(self.articleContent)
                        
                    }
                    self.parse(data: self.articleContent)
                    
                    
                }
            }
        }
        
    }
    
    var wordAr:[String] = []
    var countDic:Dictionary<String,Int> = [:]
    var sendingDic:Dictionary<String,String> = [:]
    
    func parse(data: String) {
        var word = ""
        let stArray = data.characters.split(separator: " ").map(String.init)
        for item in stArray {
            word = item.replace(target: ".", withString:"")
            word = word.replace(target: ",", withString:"")
            word = word.replace(target: "!", withString:"")
            word = word.replace(target: "’s", withString:"")
            word = word.replace(target: "(", withString:"")
            word = word.replace(target: ")", withString:"")
            word = word.replace(target: "?", withString:"")
            wordAr.append(word)
        }
        for item in wordAr {
            var num = 0
            for stItem in wordAr {
                if item.isEqual(stItem) == true {
                    num += 1
                }
            }
            
            if num > 1 {
                countDic[item] = num
            }
        }
        
        let sortStyle = {
            (elem1:(key: String, val: Int), elem2:(key: String, val: Int))->Bool in
            if elem1.val > elem2.val {
                return true
            } else {
                return false
            }
        }
        let sortedDic = countDic.sorted(by: sortStyle)
        var send = 0
        for (key,val) in sortedDic {
            //print("key : \(key) val : \(val)")
            
            Alamofire.request("https://translate.yandex.net/api/v1.5/tr/translate?key=trnsl.1.1.20170205T061033Z.4e5adbbc3e0e9acf.ae1efed83e0f80808afc6080493edcd69e3a66aa&lang=en-tr&text=\(key)", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseString(completionHandler: { response in
                
                if let html = response.result.value {
                    if let doc = Kanna.XML(xml: html, encoding: String.Encoding.utf8) {
                        let turkish = doc.at_css("text")?.text
                        self.sendingDic[key] = turkish!
                        //print("Eng: \(key) Say : \(val) - Türkçe Karşılık : \(turkish!)")
                    }
                }
            })
            
            send += 1
            if send == 5 {
                break
            }
        }
        
        
        
    }
    
    
}
extension String
{
    func replace(target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
}

