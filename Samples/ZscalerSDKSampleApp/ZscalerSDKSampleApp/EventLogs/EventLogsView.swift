//
//  EventsLogView.swift
//  ZscalerSDKSampleApp
//
//  Created by Saksham Dangwal on 22/10/24.
//

import UIKit
import Zscaler

class CSVViewController: UIViewController {
    
    var csvContent: String?

    private var textView: UITextView!
    private var doneButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create and set up the UITextView
        textView = UITextView(frame: self.view.bounds)
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        textView.isEditable = false
        textView.text = csvContent
        self.view.addSubview(textView)
        doneButton = UIBarButtonItem(title: "Done", style:.done, target: self, action: #selector(dismissViewController))
        navigationItem.rightBarButtonItem = doneButton

        loadCSVContent()
    }
    
    private func loadCSVContent() {
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
                
            let csvFilePath = logDirPath.appendingPathComponent("events.csv")
                   if fileManager.fileExists(atPath: csvFilePath.path) {
                       do {
                           csvContent = try String(contentsOf: csvFilePath, encoding: .utf8)
                           textView.text = csvContent
                       } catch {
                              print("Error reading CSV file: \(error)")
                              textView.text = "Error reading CSV file: \(error)"
                          }
                   } else {
                       print("CSV File not found at path: \(csvFilePath.path)")
                       textView.text = "CSV File not found at path: \(csvFilePath.path)"
                   }
           
        }
    
    @objc private func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
}
