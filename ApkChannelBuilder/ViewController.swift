//
//  ViewController.swift
//  ApkCahnnelBuilder
//
//  Created by wukongbao on 2016/12/6.
//  Copyright © 2016年 baoyz. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var selectApk: NSButton!
    @IBOutlet weak var pathLabel: NSTextField!
    @IBOutlet weak var outputLabel: NSTextField!
    @IBOutlet var channelsText: NSTextView!
    @IBOutlet weak var channelPrefixText: NSTextField!
    @IBOutlet weak var encryptionText: NSPopUpButton!
    @IBOutlet weak var keyText: NSSecureTextField!
    @IBOutlet weak var ivText: NSSecureTextField!
    
    var apkPath: String!
    var outputPath: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.apkPath = UserDefaults.standard.string(forKey: "apkPath") ?? ""
        self.pathLabel.stringValue = self.apkPath
        self.outputPath = UserDefaults.standard.string(forKey: "outputPath") ?? ""
        self.outputLabel.stringValue = self.outputPath
        self.channelsText.string = UserDefaults.standard.string(forKey: "channels") ?? ""
        self.keyText.stringValue = UserDefaults.standard.string(forKey: "encryptionKey") ?? ""
        self.ivText.stringValue = UserDefaults.standard.string(forKey: "encryptionIv") ?? ""
        
        let encryption = UserDefaults.standard.string(forKey: "encryption") ?? "None"
        for item in self.encryptionText.itemArray {
            if item.title == encryption {
                self.encryptionText.select(item)
                break
            }
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


    // 选择 Apk 文件
    @IBAction func openApkFile(sender: AnyObject) {
        let openPanel = NSOpenPanel()
        openPanel.allowedFileTypes = ["apk"]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.beginSheetModal(for: self.view.window!, completionHandler: {(result: Int) -> Void in
            if NSFileHandlingPanelOKButton == result {
                if let url = openPanel.url {
                    self.pathLabel.stringValue = url.path
                    self.apkPath = url.path
                }
            }
        })
    }
    
    // 选择输出目录
    @IBAction func selectOutputDir(sender: AnyObject) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.canChooseFiles = false
        openPanel.beginSheetModal(for: self.view.window!, completionHandler: {(result: Int) -> Void in
            if NSFileHandlingPanelOKButton == result {
                if let url = openPanel.url {
                    self.outputLabel.stringValue = url.path
                    self.outputPath = url.path
                }
            }
        })
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if "StartBuild" == identifier {
            // 参数检查
            if self.apkPath.isEmpty {
                showMessage(text: "请选择 Apk 文件")
                return false
            }
            if self.outputPath.isEmpty {
                showMessage(text: "请选择输出目录")
                return false
            }
            if self.channelPrefixText.stringValue.isEmpty {
                showMessage(text: "请输入渠道名称前缀")
                return false
            }
            if (self.channelsText.string?.isEmpty)! {
                showMessage(text: "请输入渠道名称")
                return false
            }
            if "None" != self.encryptionText.selectedItem?.title {
                if self.keyText.stringValue.isEmpty {
                    showMessage(text: "请输入密钥")
                    return false
                }
                if (self.encryptionText.selectedItem?.title.contains("CBC"))!
                    && self.ivText.stringValue.isEmpty {
                    showMessage(text: "CBC 模式需要输入初始向量")
                    return false
                }
            }
        }
        return super.shouldPerformSegue(withIdentifier: identifier, sender: sender)
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let controller = segue.destinationController as? BuildViewController {
            controller.apkPath = self.apkPath
            controller.outputPath = self.outputPath
            controller.channels = self.channelsText.string?.components(separatedBy: "\n")
            controller.channelPrefix = self.channelPrefixText.stringValue
            controller.encryption = self.encryptionText.selectedItem?.title
            controller.encryptionKey = self.keyText.stringValue
            controller.encryptionIv = self.ivText.stringValue
            
            // save
            UserDefaults.standard.set(controller.apkPath, forKey: "apkPath")
            UserDefaults.standard.set(controller.outputPath, forKey: "outputPath")
            UserDefaults.standard.set(self.channelsText.string, forKey: "channels")
            UserDefaults.standard.set(controller.channelPrefix, forKey: "channelPrefix")
            UserDefaults.standard.set(controller.encryption, forKey: "encryption")
            UserDefaults.standard.set(controller.encryptionKey, forKey: "encryptionKey")
            UserDefaults.standard.set(controller.encryptionIv, forKey: "encryptionIv")
        }
    }
    
    func showMessage(text: String) {
        let alert = NSAlert()
        alert.messageText = text
        alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
    }
    
}

