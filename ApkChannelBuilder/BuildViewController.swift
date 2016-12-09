//
//  BuildViewController.swift
//  ApkCahnnelBuilder
//
//  Created by wukongbao on 2016/12/7.
//  Copyright © 2016年 baoyz. All rights reserved.
//

import Cocoa
import ZipArchive
import CryptoSwift

class BuildViewController: NSViewController {
    
    @IBOutlet var logText: NSTextView!
    @IBOutlet weak var doneButton: NSButton!
    
    public var apkPath: String!
    public var outputPath: String!
    public var channels: Array<String>!
    public var channelPrefix: String!
    public var encryption: String?
    public var encryptionKey: String?
    public var encryptionIv: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.isEnabled = false
        
        DispatchQueue.global(qos: .background).async {
            self.process()
        }
        
    }
    
    func process() {
        // 创建临时目录
        let tempDir: String = outputPath + "/temp"
        print(outputPath)
        
        printLog(text: "Apk 开始解压")
        
        // 解压 apk 文件
        SSZipArchive.unzipFile(atPath: apkPath, toDestination: tempDir)
        
        printLog(text: "Apk 解压完成")
        
        // 遍历渠道，在 META-INF 写入空文件
        let metaDir: String = tempDir + "/META-INF"
        for channel in channels {
            printLog(text: "开始打包渠道：" + channel)
            let channelFileName = channelPrefix + encrypt(text: channel)!
            // 创建渠道文件
            createEmptyFile(dir: metaDir, filename: channelFileName)
            // 压缩新的 apk 包
            printLog(text: "开始压缩 Apk：" + channel + ".apk")
            SSZipArchive.createZipFile(atPath: outputPath + "/" + channel + ".apk", withContentsOfDirectory: tempDir)
            // 删除渠道文件
            deleteFile(dir: metaDir, filename: channelFileName)
            printLog(text: "打包完成：" + channel)
        }
        // 删除临时目录
        deleteDir(dir: tempDir)
        
        printLog(text: "done.")
        
        DispatchQueue.main.async {
            self.doneButton.isEnabled = true
        }
    }
    
    func encrypt(text: String) -> String? {
        if encryption == nil || "None" == encryption {
            return text
        }
        var mode = CryptoSwift.BlockMode.CBC
        if (encryption?.contains("CBC"))! {
            mode = .CBC
        } else if (encryption?.contains("ECB"))! {
            mode = .ECB
        }
        do {
            let aes = try AES(key: encryptionKey!, iv: encryptionIv!, blockMode: mode, padding: PKCS7())
            return try aes.encrypt(text.utf8.map({$0})).toBase64()!
        } catch {
            return nil
        }
    }
    
    func printLog(text: String) {
        print(text)
        DispatchQueue.main.async {
            self.logText.textStorage?.append(NSAttributedString(string: text + "\n"))
        }
    }
    
    func createEmptyFile(dir: String, filename: String) {
        FileManager.default.createFile(atPath: dir + "/" + filename, contents: nil, attributes: nil)
    }
    
    func deleteFile(dir: String, filename: String) {
        do {
            try FileManager.default.removeItem(atPath: dir + "/" + filename)
        } catch {
            print(error)
        }
        
    }
    
    func deleteDir(dir: String) {
        do {
            try FileManager.default.removeItem(atPath: dir)
        } catch {
            print(error)
        }
    }
    
    @IBAction func done(_ sender: Any) {
        self.presenting?.dismissViewController(self)
    }
} 
