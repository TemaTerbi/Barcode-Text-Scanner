//
//  BarcodeTextScannerApp.swift
//  BarcodeTextScanner
//
//  Created by Артем Соловьев on 26.01.2023.
//

import SwiftUI

@main
struct BarcodeTextScannerApp: App {
    
    @StateObject private var viewModel = MainViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .task {
                    await viewModel.requestDataScannerAccessStatus()
                }
        }
    }
}
