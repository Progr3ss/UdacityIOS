//
//  RecordingSoundsViewController.swift
//  PitchPerfect
//
//  Created by martin chibwe on 6/30/16.
//  Copyright © 2016 martin chibwe. All rights reserved.
//

import UIKit
import AVFoundation

class RecordingSoundsViewController: UIViewController, AVAudioRecorderDelegate {
	
	var audioRecorder:AVAudioRecorder!
	
	@IBOutlet weak var recordingButton: UIButton!
	@IBOutlet weak var stopRecordingButton: UIButton!
	@IBOutlet weak var recordingLabel: UILabel!
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		stopRecordingButton.enabled = false
		// Do any additional setup after loading the view, typically from a nib.
	}
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		stopRecordingButton.enabled = false

	}


	
	//MARK: AudioRecordingDelegates
	func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {

		if (flag){
			performSegueWithIdentifier("stopRecording", sender: audioRecorder.url)
		}else{
			print("Saving of recording failed")
		}
		
	}

	@IBAction func RecordAudio(sender: AnyObject) {
		

		
		setUIStateForRecording(true)
		
		//create path to audio file
		let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
		
		let recordingName = "recordedVoice.mov"
		let pathArray = [dirPath,recordingName]
		let filePath = NSURL.fileURLWithPathComponents(pathArray)
		let session = AVAudioSession.sharedInstance()
		try!session.setCategory(AVAudioSessionCategoryPlayAndRecord)

		try! audioRecorder = AVAudioRecorder(URL: filePath!,settings: [:])
		audioRecorder.delegate = self
		audioRecorder.meteringEnabled = true
		audioRecorder.prepareToRecord()
		audioRecorder.record()

		
		
	}
	
	
	func setUIStateForRecording(isRecording: Bool) {
		recordingLabel.text = isRecording ? "Recording in Progress" : "Tap to Record"
		recordingButton.enabled = !isRecording
		stopRecordingButton.enabled = isRecording
	}
	

	@IBAction func stopRecording(sender: AnyObject) {
		
		setUIStateForRecording(false)
		audioRecorder.stop()
		recordingLabel.text = "Tap to Record"
		let audioSession = AVAudioSession.sharedInstance()
		try! audioSession.setActive(false)
		

	}

	
	//MARK:PrepareForSegue
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "stopRecording" {
			let playSoundVC = segue.destinationViewController as! PlaySoundsViewController
		    let recordedAudioURL = sender as! NSURL
			
			playSoundVC.recordedAudioURL = recordedAudioURL
		
		}
	}
}


