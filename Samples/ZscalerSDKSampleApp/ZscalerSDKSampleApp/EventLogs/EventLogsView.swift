//
//  EventsLogView.swift
//  ZscalerSDKSampleApp
//
//  Created by Saksham Dangwal on 22/10/24.
//

import UIKit
import Zscaler

class JSONViewController: UIViewController {
    
    var jsonContent: String?

    private var textView: UITextView!
    private var doneButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create and set up the UITextView
        textView = UITextView(frame: self.view.bounds)
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        textView.isEditable = false
        textView.text = jsonContent
        self.view.addSubview(textView)
        doneButton = UIBarButtonItem(title: "Done", style:.done, target: self, action: #selector(dismissViewController))
        navigationItem.rightBarButtonItem = doneButton

        loadJSONContent()
    }
    
    private func loadJSONContent() {
            let fileManager = FileManager.default
            guard let appSupportDir = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
                print("Error: Unable to get Application Support directory")
                textView.text = "Error: Unable to get Application Support directory"
                return
            }
        
            let logDirPath = appSupportDir
                .appendingPathComponent(Bundle.main.bundleIdentifier ?? "com.zscaler.sdk.zscalersdk-ios.TestApp")
                .appendingPathComponent(Bundle(for: ZscalerSDK.self).bundleIdentifier ?? "com.zscaler.sdk.zscalersdk-ios")
                .appendingPathComponent("logs")
                
            let jsonFilePath = logDirPath.appendingPathComponent("events.json")
                   if fileManager.fileExists(atPath: jsonFilePath.path) {
                       do {
                           jsonContent = try String(contentsOf: jsonFilePath, encoding: .utf8)
                           textView.text = jsonContent
                       } catch {
                              print("Error reading JSON file: \(error)")
                              textView.text = "Error reading JSON file: \(error)"
                          }
                   } else {
                       print("JSON File not found at path: \(jsonFilePath.path)")
                       textView.text = "JSON File not found at path: \(jsonFilePath.path)"
                   }
           
        }
    
    @objc private func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
}
