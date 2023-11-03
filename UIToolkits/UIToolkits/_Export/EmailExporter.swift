//
//  EmailExporter.swift
//  UIToolkits
//
//  Created by Qiang Huang on 12/23/21.
//  Copyright © 2021 dYdX Trading Inc. All rights reserved.
//

import Foundation
import MessageUI
import Utilities

public class EmailExporter: NSObject, ExporterProtocol, MFMailComposeViewControllerDelegate {
    public func export(exporters: [DataExportProtocol]?) {
        if MFMailComposeViewController.canSendMail(), let exporters = exporters {
            let mail = MFMailComposeViewController()
            mail.setSubject("dYdX data export")
            mail.setMessageBody("Data attached", isHTML: true)
            mail.mailComposeDelegate = self
            // add attachment
            for exporter in exporters {
                if let fileName = exporter.fileName, let mimeType = exporter.memeType, let data = exporter.export() {
                    mail.addAttachmentData(data as Data, mimeType: mimeType, fileName: fileName)
                }
            }

            UIViewController.topmost()?.present(mail, animated: true)
        } else {
            ErrorInfo.shared?.info(title: "Error", message: "Please set up your email to export data", error: nil)
        }
    }

    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) {
            if let error = error {
                ErrorInfo.shared?.info(title: "Error", message: nil, error: error)
            }
        }
    }
}
