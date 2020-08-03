/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The root view controller that provides a button to start and stop recording, and which displays the speech recognition results.
*/

import UIKit
import Speech

import SceneKit
import ARKit

//import AVFoundation

public class ViewController: UIViewController, SFSpeechRecognizerDelegate, ARSCNViewDelegate {
    // MARK: Properties
    //Main AR scene view in the center
	@IBOutlet weak var sceneView: ARSCNView!
	
	private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private let audioEngine = AVAudioEngine()
	
    //Two TextView on the top, one for input, the other for respond
    @IBOutlet var textView: UITextView!
	@IBOutlet weak var textViewBottom: UITextView!

	//Three TextView on the middle, for Recognition Latency, Tracking Latency, Rendering Latency respectively
	@IBOutlet weak var RecLaText: UITextView!
	@IBOutlet weak var TraLaText: UITextView!
	@IBOutlet weak var RenLaText: UITextView!
	
	//For the record button
	@IBOutlet var recordButton: UIButton!
	public var Bottle_x:Float = 0.0
	public var Bottle_y:Float = 0.0

	public var Computer_x:Float = 0.0
	public var Computer_y:Float = 0.0

	public var Switch_x:Float = 0.0
	public var Switch_y:Float = 0.0

	var lastDetectionStartTime: Date?
	var lastDetectionDelayInSeconds: Double = 0

	public var object_now = "empty"

    // MARK: View Controller Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
		//Initilize the lastDetectionStartTime
		lastDetectionStartTime = Date()

        // Disable the record buttons until authorization has been granted.
        recordButton.isEnabled = false
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		//configurate recognition images and objects
		let configuration = ARWorldTrackingConfiguration()
		guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Images", bundle: nil) else {
			fatalError("Missing expected asset catalog resources.")
		}
		
//		guard let referenceObjects = ARReferenceObject.referenceObjects(inGroupNamed: "AR Objects", bundle: nil) else {
//			fatalError("Missing expected asset catalog resources.")
//		}
		configuration.detectionImages = referenceImages
		//configuration.detectionObjects = referenceObjects
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
	public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
	
	
	public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
		guard let imageAnchor = anchor as? ARImageAnchor else { return }
		let referenceImage = imageAnchor.referenceImage
		
		lastDetectionDelayInSeconds = Date().timeIntervalSince(self.lastDetectionStartTime!)
		//print the latency for debug
		print(lastDetectionDelayInSeconds)
		DispatchQueue.main.async
		{
			self.RecLaText.font = UIFont.systemFont(ofSize: 25.0)
			self.RecLaText.text = "\(self.lastDetectionDelayInSeconds)"
		}
		let plane = SCNPlane(width: CGFloat(imageAnchor.referenceImage.physicalSize.width), height: CGFloat(imageAnchor.referenceImage.physicalSize.height))
		let planeNode = SCNNode(geometry: plane)

		planeNode.opacity = 0.25
		/*
		 `SCNPlane` is vertically oriented in its local coordinate space, but
		 `ARImageAnchor` assumes the image is horizontal in its local space, so
		 rotate the plane to match.
		 */
		planeNode.eulerAngles.x = -.pi / 2
		//node.addChildNode(planeNode)


		let geometry = SCNText(string: referenceImage.name, extrusionDepth: 0)
        geometry.flatness = 0.1
		geometry.firstMaterial?.diffuse.contents = UIColor.darkText
        let text = SCNNode(geometry: geometry)
        text.scale = .init(0.00075, 0.00075, 0.00075)
        text.eulerAngles.x = -.pi / 2
        let box = text.boundingBox
        text.pivot.m41 = (box.max.x - box.min.x) / 2.0
        text.position.z = node.boundingBox.max.z + 0.012 // 1 cm below card
        node.addChildNode(text)
		
		lastDetectionDelayInSeconds = Date().timeIntervalSince(self.lastDetectionStartTime!)
		print(lastDetectionDelayInSeconds)
		//self.RenLaText.text = "\(lastDetectionDelayInSeconds)"
		
		// Immediately remove the anchor from the session again to force a re-detection.
		lastDetectionStartTime = Date()
		self.sceneView.session.remove(anchor: imageAnchor)
	}
	
	public func renderer(_ renderer: SCNSceneRenderer,
	willUpdate node: SCNNode,
	for anchor: ARAnchor){
			guard let imageAnchor = anchor as? ARImageAnchor else { return }
			let referenceImage = imageAnchor.referenceImage

			if (referenceImage.name == "Bottle")
			{
				Bottle_x = imageAnchor.transform.columns.3.z
				Bottle_y = imageAnchor.transform.columns.3.y
				print("Bottle_x \(Bottle_x)")
				print("Bottle_y \(Bottle_y)")
				object_now = "Bottle"
			}
			else if (referenceImage.name == "Computer")
			{

				Computer_x = imageAnchor.transform.columns.3.z
				Computer_y = imageAnchor.transform.columns.3.y
				print("Computer_x \(Computer_x)")
				print("Computer_y \(Computer_y)")
				object_now = "Computer"

			}
			else if (referenceImage.name == "Switch")
			{
				Switch_x = imageAnchor.transform.columns.3.z
				Switch_y = imageAnchor.transform.columns.3.y
				print("Switch_x \(Switch_x)")
				print("Switch_y \(Switch_y)")
				object_now = "Switch"
			}

	}
	
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Configure the SFSpeechRecognizer object already
        // stored in a local member variable.
        speechRecognizer.delegate = self
        // Asynchronously make the authorization request.
        SFSpeechRecognizer.requestAuthorization { authStatus in

            // Divert to the app's main thread so that the UI
            // can be updated.
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.recordButton.isEnabled = true

                case .denied:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("User denied access to speech recognition", for: .disabled)

                case .restricted:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("Speech recognition restricted on this device", for: .disabled)

                case .notDetermined:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("Speech recognition not yet authorized", for: .disabled)

                default:
                    self.recordButton.isEnabled = false
                }
            }
        }
    }
    
	public func ambiguousHandling(_ input : String) -> String{
		
		let distance_bottle = Bottle_x //* Bottle_x + Bottle_y * Bottle_y
		let distance_computer = Computer_x //* Computer_x + Computer_y * Computer_y
		let distance_switch = Switch_x //* Switch_x + Switch_y * Switch_y
		
		let min_of_three = min(distance_bottle,distance_switch,distance_computer)
		
		if (min_of_three == distance_bottle)
		{
			return "Respond: This is Bottle"
		}
		else if (min_of_three == distance_computer)
		{
			return "Respond: This is Computer"
		}
		else if (min_of_three == distance_switch)
		{
			return "Respond: This is Switch"
		}
		else{
			return "I dont know"
		}
	}
    private func startRecording() throws {
        
        // Cancel the previous task if it's running.
        recognitionTask?.cancel()
        self.recognitionTask = nil
        // Configure the audio session for the app.
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode

        // Create and configure the speech recognition request.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true
        
        // Keep speech recognition data on device
        if #available(iOS 13, *) {
            recognitionRequest.requiresOnDeviceRecognition = false
        }
        
        // Create a recognition task for the speech recognition session.
        // Keep a reference to the task so that it can be canceled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                // Update the text view with the results.
                self.textView.text = result.bestTranscription.formattedString
				self.textView.font = UIFont.systemFont(ofSize: 17.0)
				self.textViewBottom.font = UIFont.systemFont(ofSize: 17.0)

				let respond_result = self.ambiguousHandling(result.bestTranscription.formattedString)
				
				self.textViewBottom.text = respond_result

				isFinal = result.isFinal
                print("Text \(result.bestTranscription.formattedString)")
            }
            
            if error != nil || isFinal {
                // Stop recognizing speech if there is a problem.
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)

                self.recognitionRequest = nil
                self.recognitionTask = nil

                self.recordButton.isEnabled = true
                self.recordButton.setTitle("Start Recording", for: [])
            }
        }

        // Configure the microphone input.
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        // Let the user know to start talking.
		textView.font = UIFont.systemFont(ofSize: 17.0)
        textView.text = "(Go ahead, I'm listening)"
    }
    
    // MARK: SFSpeechRecognizerDelegate
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordButton.isEnabled = true
            recordButton.setTitle("Start Recording", for: [])
        } else {
            recordButton.isEnabled = false
            recordButton.setTitle("Recognition Not Available", for: .disabled)
        }
    }
    
    // MARK: Interface Builder actions
    
    @IBAction func recordButtonTapped() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recordButton.isEnabled = false
            recordButton.setTitle("Stopping", for: .disabled)
        } else {
            do {
                try startRecording()
                recordButton.setTitle("Stop Recording", for: [])
            } catch {
                recordButton.setTitle("Recording Not Available", for: [])
            }
        }
    }

}

