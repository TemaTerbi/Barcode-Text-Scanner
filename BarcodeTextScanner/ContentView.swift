//
//  ContentView.swift
//  BarcodeTextScanner
//
//  Created by Артем Соловьев on 26.01.2023.
//

import SwiftUI
import VisionKit

struct ContentView: View {
    
    @EnvironmentObject var viewModel: MainViewModel
    
    private let textContentTypes: [(title: String, textContentType: DataScannerViewController.TextContentType?)] = [
        ("ALL", .none),
        ("URL", .URL),
        ("Phone", .telephoneNumber),
        ("Email", .emailAddress),
        ("Address", .fullStreetAddress),
    ]
    
    var body: some View {
        switch viewModel.dataScannerAccessStatus {
        case .saccnerAvaliable:
            mainView
            Text("Камера доступна!")
        case .cameraNoAvaliable:
            Text("Камера не доступна!")
        case .scannerNotAvaliable:
            Text("Ваше устройство не поддерживает сканирование 😣")
        case .camerAccessNotGranted:
            Text("Пожалуйста, дайте разрешение приложению на использование камеры")
        case .notDetermited:
            Text("Запросите разрешение")
        }
    }
    
    private var mainView: some View {
        DataScannerView(recognizedItems: $viewModel.recognizedItems, recognizedDataType: viewModel.recognizedDataType, recognizesMultipleItems: viewModel.recoognizedMultipleItems)
            .background { Color.gray.opacity(0.3) }
            .ignoresSafeArea()
            .id(viewModel.dataScannerViewId)
            .sheet(isPresented: .constant(true), content: {
                bottomContainerView
                    .background(.ultraThinMaterial)
                    .presentationDetents([.medium, .fraction(0.25)])
                    .presentationDragIndicator(.visible)
                    .interactiveDismissDisabled()
                    .onAppear() {
                        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let controller = windowScene.windows.first?.rootViewController?.presentedViewController else {
                            return
                        }
                        controller.view.backgroundColor = .clear
                    }
            })
            .onChange(of: viewModel.scanType) { _ in viewModel.recognizedItems = [] }
            .onChange(of: viewModel.textContentType) { _ in viewModel.recognizedItems = [] }
            .onChange(of: viewModel.recoognizedMultipleItems) { _ in viewModel.recognizedItems = [] }
    }
    
    private var headerView: some View {
        VStack {
            HStack {
                Picker("Scan Type", selection: $viewModel.scanType) {
                    Text("Barcode").tag(ScanType.barcode)
                    Text("Text").tag(ScanType.text)
                }.pickerStyle(.segmented)
                
                Toggle("Scan multiple", isOn: $viewModel.recoognizedMultipleItems)
            }.padding(.top)
            
            if viewModel.scanType == .text {
                Picker("Text content type", selection: $viewModel.textContentType) {
                    ForEach(textContentTypes, id: \.self.textContentType) { option in
                        Text(option.title).tag(option.textContentType)
                    }
                }.pickerStyle(.segmented)
            }
            
            Text(viewModel.headerText).padding(.top)
        }
        .padding(.horizontal)
    }
    
    private var bottomContainerView: some View {
        VStack {
            headerView
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(viewModel.recognizedItems) { item in
                        switch item {
                        case .barcode(let barcode):
                            Text(barcode.payloadStringValue ?? "Unknow barcode")
                            
                        case .text(let text):
                            Text(text.transcript)
                            
                        @unknown default:
                            Text("Unknown!")
                        }
                    }
                }
                .padding()
            }
        }
    }
}
