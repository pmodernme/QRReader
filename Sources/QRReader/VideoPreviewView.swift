//
//  QRPreviewView.swift
//  
//
//  Created by Zoe Van Brunt on 5/6/22.
//

#if canImport(UIKit) && canImport(AVFoundation)

import UIKit
import AVKit

public class VideoPreviewView: UIView {

    public var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("Expected `AVCaptureVideoPreviewLayer` type for layer. Check PreviewView.layerClass implementation.")
        }
        return layer
    }

    private var _session: AVCaptureSession?
    private var _sessionLock = NSLock()

    public var session: AVCaptureSession? {
        get {
            _sessionLock.lock()
            defer { _sessionLock.unlock() }
            return _session
        }
        set {
            _sessionLock.lock()
            let oldValue = _session
            _session = newValue
            _sessionLock.unlock()

            if Thread.isMainThread {
                videoPreviewLayer.session = newValue
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.videoPreviewLayer.session = newValue
                }
            }
        }
    }

    func takeSession(updateLayer: Bool = true) -> AVCaptureSession? {
        _sessionLock.lock()
        let captured = _session
        _session = nil
        _sessionLock.unlock()

        guard updateLayer else { return captured }

        if Thread.isMainThread {
            videoPreviewLayer.session = nil
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.videoPreviewLayer.session = nil
            }
        }

        return captured
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        switch UIDevice.current.orientation {
            case .portrait: videoPreviewLayer.connection?.videoOrientation = .portrait
            case .landscapeLeft: videoPreviewLayer.connection?.videoOrientation = .landscapeRight
            case .landscapeRight: videoPreviewLayer.connection?.videoOrientation = .landscapeLeft
            case .portraitUpsideDown: videoPreviewLayer.connection?.videoOrientation = .portraitUpsideDown
            default: videoPreviewLayer.connection?.videoOrientation = .portrait
        }
    }
    
    public override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
}

#endif
