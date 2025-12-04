//
//  QRReader.swift
//  
//
//  Created by Zoe Van Brunt on 11/11/22.
//

import SwiftUI

public struct QRReader: UIViewRepresentable {
    public init(scanResults: Binding<Set<String>>) {
        _scanResults = scanResults
    }

    @Binding public var scanResults: Set<String>

    public func updateUIView(_ view: QRReaderView, context: Context) { }

    public func makeUIView(context: Context) -> QRReaderView {
        let view = QRReaderView()
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        view.start()
        view.onReaderDidReadString = {
            scanResults = $0
        }
        return view
    }

    public static func dismantleUIView(_ view: QRReaderView, coordinator: ()) {
        // Cleanup is handled automatically by the view's willMove(toWindow:) lifecycle method
        // when it's removed from the window hierarchy, and by deinit as a fallback.
        // Not calling stop() here to avoid conflicts with SwiftUI's teardown process.
    }
}
