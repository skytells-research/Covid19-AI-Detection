//
//  ViewController.swift
//  Object Detector
//
//  Created by Dr. Hazem Ali
//  Copyright © 2020 Skytells, Inc. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
	
	@IBOutlet private weak var cameraView: UIView?
	@IBOutlet private weak var textLayer: UILabel?
	
	// set up the handler for the captured images
	private let visionSequenceHandler = VNSequenceRequestHandler()
	
	// set up the camera preview layer
	private lazy var cameraLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
	
	// set up the capture session
	private lazy var captureSession: AVCaptureSession = {
		let session = AVCaptureSession()
		session.sessionPreset = AVCaptureSession.Preset.photo
		guard
			
			// set up the rear camera as the device to capture images from
			let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
			let input = try? AVCaptureDeviceInput(device: backCamera)
			else {
				print("no camera is available.");
				return session
				
		}
		// add the rear camera as the capture device
		session.addInput(input)
		return session
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		// add the camera preview
		self.cameraView?.layer.addSublayer(self.cameraLayer)
		
		// set up the delegate to handle the images to be fed to Core ML
		let videoOutput = AVCaptureVideoDataOutput()
		
		// we want to process the image buffer and ML not on the main thread
		videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "DispatchQueue"))
		
		self.captureSession.addOutput(videoOutput)
		
		// make the camera output fill the screen
		cameraLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
		
		// begin the session
		self.captureSession.startRunning()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		// make sure the layer is the correct size
		self.cameraLayer.frame = (self.cameraView?.frame)!
	}
	
	// MARK: - Capture Session
	
	func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
		
		// Get the pixel buffer from the capture session
		guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
		
		// load the Core ML model
		guard let visionModel:VNCoreMLModel = try? VNCoreMLModel(for: DeepBrain().model) else { return }
		
		//  set up the classification request
		let classificationRequest = VNCoreMLRequest(model: visionModel, completionHandler: handleClassification)
		
		// automatically resize the image from the pixel buffer to fit what the model needs
        
		
		// perform the machine learning classification
		do {
			try self.visionSequenceHandler.perform([classificationRequest], on: pixelBuffer)
		} catch {
			print("Throws: \(error)")
		}
	}
	
	// MARK - Core ML Classification
	
	func handleClassification(request: VNRequest, error: Error?) {
		guard let observations = request.results else {
			
			// Nothing has been returned so we want to clear the label.
			updateClassificationLabel(labelString: "")
				
			return
		}
		
		let classifications = observations[0...3]
            .compactMap({ $0 as? VNClassificationObservation}) // discard any erroneous results
			.filter({ $0.confidence > 0.1 }) // discard anything with less than 10% accuracy.
			.map(self.textForClassification) // get the text to display
		
			if (classifications.count > 0) {
				// update the label to display what we found
				updateClassificationLabel(labelString: "\(classifications.joined(separator: "\n"))")
			} else {
				// nothing matches our criteria, so clear the label
				updateClassificationLabel(labelString: "")
			}
		
	}
	
	func updateClassificationLabel(labelString: String) {
		// We processed the capture session and Core ML off the main thread, so the compleetion handler was called onthe the same thread
		// So we need to remember to get the main thread again tp update the UI
		
		DispatchQueue.main.async {
			self.textLayer?.text = labelString
		}
	}
	
	func textForClassification(classification: VNClassificationObservation) -> String {
		// Mapping the results from the VNClassificationObservation to a human readable string
		let pc = Int(classification.confidence * 100)
		return "\(classification.identifier)\nConfidence: \(pc)%"
	}
	

}
