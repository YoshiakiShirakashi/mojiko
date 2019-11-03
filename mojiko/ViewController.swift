//
//  ViewController.swift
//  mojiko
//
//  Created by 白樫芳昭 on 2019/08/13.
//  Copyright © 2019 yoshiaki.sjirakashi. All rights reserved.
//

import UIKit
import RealmSwift

class User: Object {
    // フォント
    @objc dynamic var font = ""
    
    // MJI図形名
    @objc dynamic var zukeimei = ""
    
    // UCSコード
    @objc dynamic var ucs = ""
    
    // UCS2コード
    @objc dynamic var ucs2 = ""
    
    //
    @objc dynamic var koseki = ""
    
    //
    @objc dynamic var jnet = ""
    
    @objc dynamic var sesaku = ""
    
    @objc dynamic var jibo = ""
    
    @objc dynamic var touki = ""
    
    @objc dynamic var busyu1 = ""
    
    @objc dynamic var naikakusuu1 = ""
    
    @objc dynamic var busyu2 = ""
    
    @objc dynamic var naikakusuu2 = ""
    
    @objc dynamic var busyu3 = ""
    
    @objc dynamic var naikakusuu3 = ""
    
    @objc dynamic var busyu4 = ""
    
    @objc dynamic var naikakusuu4 = ""
    
    @objc dynamic var sokakusuu = ""
    
    @objc dynamic var yomi = ""
    
func saveCsvValue(csvStr:String) {
    // CSVなのでカンマでセパレート
    let splitStr = csvStr.components(separatedBy: ",")
    self.font = splitStr[0]
    self.zukeimei = splitStr[1]
    self.ucs = splitStr[2]
    self.ucs2 = splitStr[3]
    self.koseki = splitStr[4]
    self.jnet = splitStr[5]
    self.sesaku = splitStr[6]
    self.jibo = splitStr[7]
    self.touki = splitStr[8]
    self.busyu1 = splitStr[9]
    self.naikakusuu1 = splitStr[10]
    self.busyu2 = splitStr[11]
    self.naikakusuu2 = splitStr[12]
    self.busyu3 = splitStr[13]
    self.naikakusuu3 = splitStr[14]
    self.busyu4 = splitStr[15]
    self.naikakusuu4 = splitStr[16]
    self.sokakusuu = splitStr[17]
    self.yomi = splitStr[18]
    
    // 保存
    let realm = try! Realm()
    do {
        try realm.write {
            realm.add(self)
            //print ("成功")
        }
    } catch {
    }
}
}
var kanji = ""
var kosekiCode = ""
var jnetCode = ""
var sesakuText = ""
var yomiText = ""
var flag = 0
var objects: Results<User>!

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate,UITextFieldDelegate {
    
    lazy var realm = try! Realm()
    
    @IBOutlet weak var searchText: UISearchBar!
    
    @IBOutlet weak var searchKana: UISearchBar!
    
    @IBOutlet weak var searchKoseki: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    private var toolbar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //cell.tableView.font = UIFont(name:"IPAexMincho",size:60.0)
        tableView.delegate = self
        tableView.dataSource = self
        searchText.delegate = self
        searchKana.delegate = self
        searchKoseki.delegate = self
        //searchHentai.delegate = self
        
        searchText.keyboardType = .default
        searchKana.keyboardType = .default
        searchText.becomeFirstResponder()
        //強制的にUSモードにする（iOS13対応）
        UserDefaults.standard.set(["us"], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        //searchText.font = UIFont(name:"IPAmjMincho")
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).font = UIFont.init(name: "IPAmjMincho", size: 17)
        searchText.placeholder = "文字を１文字だけ入力してね"
        searchKana.placeholder = "ここに読み方を入力してね"
        searchKoseki.placeholder = "総画数または戸籍統一文字番号"
        // searchHentai.placeholder = "ここに変体仮名の元ひらがなを入力してね"
        
        //CSVの取り込み
        //let objs = realm.objects(User.self)
        //if objs.count < 59128 {
        //    let csvArray = csvLoad(filename: "mji_00601_seiji_utf8")
        //    for csvStr in csvArray {
        //        User().saveCsvValue(csvStr: csvStr)
        //    }
        //}
        //print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        //realmファイルの読み込み
        let filePath = URL(fileURLWithPath: Bundle.main.path(forResource: "default", ofType: "realm")!)
        print(filePath)
        let config = Realm.Configuration(fileURL: filePath , readOnly: true)
        Realm.Configuration.defaultConfiguration = config
        
        objects = realm.objects(User.self)
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
        
        // ツールバー生成
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        // スタイルを設定
        toolBar.barStyle = UIBarStyle.default
        // 画面幅に合わせてサイズを変更
        toolBar.sizeToFit()
        // 閉じるボタンを右に配置するためのスペース?
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        // 閉じるボタン
        let commitButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(searchBarSearchButtonClicked(_:)))
        // スペース、閉じるボタンを右側に配置
        toolBar.items = [spacer, commitButton]
        // textViewのキーボードにツールバーを設定
        searchKoseki.inputAccessoryView = toolBar
        searchKoseki.keyboardType = .numberPad
        
    }
    
    @objc func commitButtonTapped() {
        func searchBarSearchButtonClicked(searchBar: UISearchBar) {
            self.view.endEditing(true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        view.endEditing(true)
        let searchWord = searchText.text
        if searchWord != "" {
        print(searchWord!)
            let code = searchWord!.unicodeScalars.first?.value
            let firstChr: Character = ((searchWord?.first!)!) //
            for code in firstChr.description.utf16 {
                    let kode = "U+" + String(code, radix: 16).uppercased()
                    //print(kode)
                    // 取得条件の作成.
                    let predicate = NSPredicate(format: "ucs2 == %@",kode)
                    // オブジェクトの取得.
                    objects = realm.objects(User.self).filter(predicate)
                    
                    if objects.count == 0 {
                        let predicate = NSPredicate(format: "font == %@",searchWord!)
                        objects = realm.objects(User.self).filter(predicate)
                    }
                    if objects.count > 0 {
                        tableView.reloadData()
                        let indexPath = IndexPath(row: 0, section: 0)
                        self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                    }else{
                        //objects = realm.objects(User.self)
                        tableView.reloadData()
                        //let indexPath = IndexPath(row: 0, section: 0)
                        //self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                    }
            }
        } else if searchKana.text != ""  {
            if let kana = searchKana.text {
                    let kosekiCode = searchKoseki.text
                    if kosekiCode!.count < 3 && kosekiCode!.count > 0 {
                        let predicate = NSPredicate("yomi", contains: kana)
                        let predicate2 = NSPredicate(format: "sokakusuu == %@",kosekiCode!)
                        objects = realm.objects(User.self).filter(predicate).filter(predicate2)
                    } else {
                        let predicate = NSPredicate("yomi", contains: kana)
                        objects = realm.objects(User.self).filter(predicate)
                    }
                    //let predicate = NSPredicate("yomi", contains: kana)
                    //objects = realm.objects(User.self).filter(predicate)
                    if objects.count > 0 {
                    tableView.reloadData()
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                    } else {
                        //objects = realm.objects(User.self)
                        tableView.reloadData()
                        //let indexPath = IndexPath(row: 0, section: 0)
                        //self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                    }
            }
        } else if searchKoseki.text != "" {
            if searchKoseki.text!.count > 0 {
                let kosekiCode = searchKoseki.text
                    if kosekiCode!.count < 3 {
                        let predicate = NSPredicate(format: "sokakusuu == %@",kosekiCode!)
                        objects = realm.objects(User.self).filter(predicate)
                    } else {
                        let predicate = NSPredicate(format: "koseki == %@",kosekiCode!)
                        objects = realm.objects(User.self).filter(predicate)
                    }
                    if objects.count > 0 {
                    tableView.reloadData()
                    let indexPath = IndexPath(row: 0, section: 0)
                    try self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                    } else {
                        tableView.reloadData()
                    }
            } else {
                objects = realm.objects(User.self)
                tableView.reloadData()
                let indexPath = IndexPath(row: 0, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        } else {
            objects = realm.objects(User.self)
            tableView.reloadData()
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    //@IBAction func pinchGesture(_ sender: UIPinchGestureRecognizer) {
    //    print("pinch scale: \(sender.scale)")
    //    print("pinch velocity: \(sender.velocity)")
    //    //pinchGesture.scale = 1.0
    //    //let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as! TableViewCell
    //    for mojiText in self.view.subviews {
    //        mojiText.transform = CGAffineTransform(scaleX: sender.scale, y: 1)
    //        mojiText.setNeedsDisplay()
    //    }
    //}
    
    func csvLoad(filename:String)->[String]{
        //csvファイルを格納するための配列を作成
        var csvArray:[String] = []
        //csvファイルの読み込み
        let csvBundle = Bundle.main.path(forResource: filename, ofType: "csv")
        
        do {
            //csvBundleのパスを読み込み、UTF8に文字コード変換して、NSStringに格納
            //let tsvData = try String(contentsOfFile: csvBundle!,
            //                         encoding: String.Encoding.utf8)
            let tsvData = try String(contentsOfFile: csvBundle!)
            //改行コードが\n一つになるようにします
            var lineChange = tsvData.replacingOccurrences(of: "\r", with: "\n")
            lineChange = lineChange.replacingOccurrences(of: "\n\n", with: "\n")
            //"\n"の改行コードで区切って、配列csvArrayに格納する
            csvArray = lineChange.components(separatedBy: "\n")
        }
        catch {
            print("エラー")
        }
        return csvArray
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルの内容を取得
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as! TableViewCell
        
        cell.mojiText.font = UIFont(name:"IPAmjMincho",size:80.0)
        cell.sesaku.font = UIFont(name:"IPAmjMincho",size:17.0)
         //let scode = objects[indexPath.row].ucs.suffix(4).lowercased()
         //let scode2 = Int(scode, radix: 16)!
         //let scode3 = UnicodeScalar(scode2)
         //print(scode)
         //print(scode2)
         //print(scode3)
         //print(String(scode3!))
         //print("-----")
         //cell.mojiText.text = "\(scode3) "
        cell.mojiText.isUserInteractionEnabled = true
        cell.mojiText.isEditable = false
        cell.mojiText.isScrollEnabled = false
        cell.mojiText.text = objects[indexPath.row].font
        cell.koseki.isUserInteractionEnabled = true
        cell.koseki.isEditable = false
        cell.koseki.isScrollEnabled = false
        cell.koseki.text = objects[indexPath.row].koseki
        cell.jnet.isUserInteractionEnabled = true
        cell.jnet.isEditable = false
        cell.jnet.isScrollEnabled = false
        cell.jnet.text = objects[indexPath.row].jnet
        cell.sesaku.isUserInteractionEnabled = true
        cell.sesaku.isEditable = false
        cell.sesaku.isScrollEnabled = false
        cell.sesaku.text = objects[indexPath.row].sesaku
        cell.yomi.isUserInteractionEnabled = true
        cell.yomi.isEditable = false
        cell.yomi.isScrollEnabled = false
        cell.yomi.text = objects[indexPath.row].yomi
        self.tableView.allowsSelection = false
        
        return cell
    }
    let cellHeigh:CGFloat = 250
    
    // 画面が表示される直前にtableViewを更新
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // セルの高さを設定
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeigh
    }
    
}
public extension NSPredicate {
    // 前後方一致検索(いわゆる、あいまい検索)
    convenience init(_ property: String, contains q: String) {
        self.init(format: "\(property) CONTAINS '\(q)'")
    }
    
    // 前方一致検索
    convenience init(_ property: String, beginsWith q: String) {
        self.init(format: "\(property) BEGINSWITH '\(q)'")
    }
    
    // 後方一致検索
    convenience init(_ property: String, endsWith q: String) {
        self.init(format: "\(property) ENDSWITH '\(q)'")
    }
}


