//
//  Scanner.swift
//  Stock Eat
//
//  Created by Emmanuel LOUCHEZ on 11/10/2020.
//  Copyright © 2020 Emmanuel LOUCHEZ. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

protocol ScannerDelegate: class
{
    func cameraView() -> UIView
    func delegateViewController() -> UIViewController
    func scanCompleted(withCode code: String, toRemove: Bool)
}

class Scanner: NSObject
{
    public weak var delegate : ScannerDelegate?
    private var captureSession : AVCaptureSession?
    private var toRemove : Bool
    
    init(withDelegate delegate: ScannerDelegate, toRemove: Bool)
    {
        self.toRemove = toRemove
        self.delegate = delegate
        super.init()
        self.scannerSetup()
    }
    
    private func scannerSetup()
    {
        guard let captureSession = self.createCaptureSession() else {
            return
        }
        
        self.captureSession = captureSession
        
        guard let delegate = self.delegate else {
            return
        }
        
        let cameraView = delegate.cameraView()
        let previewLayer = self.createPreviewLayer(withCaptureSession: captureSession, view: cameraView)
        cameraView.layer.addSublayer(previewLayer)
    }
    
    private func createCaptureSession() -> AVCaptureSession?
    {
        do
        {
            let captureSession = AVCaptureSession()
            captureSession.sessionPreset = AVCaptureSession.Preset.photo
            
            guard let captureDevice = AVCaptureDevice.default(for: .video) else {
                return nil
            }
            
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            let metaDataOutput = AVCaptureMetadataOutput()
            
            if captureSession.canAddInput(deviceInput) && captureSession.canAddOutput(metaDataOutput)
            {
                captureSession.addInput(deviceInput)
                captureSession.addOutput(metaDataOutput)
                
                guard let delegate = self.delegate,
                    let viewController = delegate.delegateViewController() as? AVCaptureMetadataOutputObjectsDelegate else {
                        return nil
                }
                
                metaDataOutput.setMetadataObjectsDelegate(viewController, queue: DispatchQueue.main)
                metaDataOutput.metadataObjectTypes = self.metaObjectTypes()
                
                return captureSession
            }
        }
        catch
        {
            return nil
        }
        
        return nil
    }
    
    private func metaObjectTypes() -> [AVMetadataObject.ObjectType]
    {
        return [
            .code128,
            .code39,
            .code39Mod43,
            .code93,
            .ean13,
            .ean8,
            .interleaved2of5,
            .itf14,
            .pdf417,
            .upce,
            .qr
        ]
    }
    
    private func createPreviewLayer(withCaptureSession captureSession: AVCaptureSession,
                                    view: UIView) -> AVCaptureVideoPreviewLayer
    {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        
        return previewLayer
    }
    
    func requestCaptureSessionStartRunning()
    {
        guard let captureSession = self.captureSession else {
            return
        }
        
        if !captureSession.isRunning
        {
            captureSession.startRunning()
        }
    }
    
    func requestCaptureSessionStopRunning()
    {
        guard let captureSession = self.captureSession else {
            return
        }
        
        if captureSession.isRunning
        {
            captureSession.stopRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                         didOutput metadataObjects: [AVMetadataObject],
                         from connection: AVCaptureConnection)
    {
        self.requestCaptureSessionStopRunning()
        guard let metadataObject = metadataObjects.first,
            let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
            let scannedValue = readableObject.stringValue,
            let delegate = self.delegate else {
                return
        }
        
        delegate.scanCompleted(withCode : scannedValue, toRemove: toRemove)
    }
}
