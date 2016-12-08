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
    
    var apkPath: String!
    var outputPath: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                    self.pathLabel.stringValue = url.lastPathComponent
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
            if self.apkPath == nil {
                showMessage(text: "请选择 Apk 文件")
                return false
            }
            if self.outputPath == nil {
                showMessage(text: "请选择输出目录")
                return false
            }
            if self.channelPrefixText.stringValue.isEmpty {
                showMessage(text: "请输入渠道名称前缀")
                return false
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
        }
    }
    
    func showMessage(text: String) {
        let alert = NSAlert()
        alert.messageText = text
        alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
    }
    
}

