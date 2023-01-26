//
//  MainViewModel.swift
//  BarcodeTextScanner
//
//  Created by Артем Соловьев on 26.01.2023.
//

import AVKit
import Foundation
import SwiftUI
import VisionKit

enum ScanType: String {
    case barcode, text
}

enum DataScannerAccessType {
    case notDetermited
    case camerAccessNotGranted
    case cameraNoAvaliable
    case saccnerAvaliable
    case scannerNotAvaliable
}

@MainActor
final class MainViewModel: ObservableObject {
    
    @Published var dataScannerAccessStatus: DataScannerAccessType = .notDetermited
    @Published var recognizedItems: [RecognizedItem] = []
    @Published var scanType: ScanType = .barcode
    @Published var textContentType: DataScannerViewController.TextContentType?
    @Published var recoognizedMultipleItems = true
    
    var dataScannerViewId: Int {
        var hasher = Hasher()
        hasher.combine(scanType)
        hasher.combine(recoognizedMultipleItems)
        if let textContentType {
            hasher.combine(textContentType)
        }
        return hasher.finalize()
    }
    
    private var isScannerAvaliable: Bool {
        DataScannerViewController.isAvailable && DataScannerViewController.isSupported
    }
    
    var recognizedDataType: DataScannerViewController.RecognizedDataType {
        scanType == .barcode ? .barcode() : .text(textContentType: textContentType)
    }
    
    var headerText: String {
        if recognizedItems.isEmpty {
            return "Scanning \(scanType.rawValue)"
        } else {
            return "Recognized \(recognizedItems.count)"
        }
    }
    
    func requestDataScannerAccessStatus() async {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            dataScannerAccessStatus = .cameraNoAvaliable
            return
        }
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            
        case .authorized:
            dataScannerAccessStatus = isScannerAvaliable ? .saccnerAvaliable : .scannerNotAvaliable
        case .restricted, .denied:
            dataScannerAccessStatus = .camerAccessNotGranted
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            if granted {
                dataScannerAccessStatus = isScannerAvaliable ? .saccnerAvaliable : .scannerNotAvaliable
            } else {
                dataScannerAccessStatus = .camerAccessNotGranted
            }
        default: break
        }
    }
    
}
