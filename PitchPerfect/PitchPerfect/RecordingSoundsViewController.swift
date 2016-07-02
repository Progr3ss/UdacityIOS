//
//  ViewController.swift
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
		stopRecordingButton.enabled = false

	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	
	//MARK: AudioRecordingDelegates
	func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
		print("finished recording ")
		if (flag){
			self.performSegueWithIdentifier("stopRecording", sender: audioRecorder.url)
		}else{
			print("Saving of recording failed")
		}
		
	}

	@IBAction func RecordAudio(sender: AnyObject) {
		
		recordingLabel.text = "Recording ..."
		stopRecordingButton.enabled = true
		recordingButton.enabled = false
		
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
		print("audioRecording")
		
		
	}

	@IBAction func stopRecording(sender: AnyObject) {
		
		recordingButton.enabled = true
		recordingLabel.text = "Stop Recording"
		audioRecorder.stop()
		let audioSession = AVAudioSession.sharedInstance()
		try! audioSession.setActive(false)
		

	}

	
	//MARK:PrepareForSegue
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "stopRecording" {
			print("prepare for segue ")
			let playSoundVC = segue.destinationViewController as! PlaySoundsViewController
		    let recordedAudioURL = sender as! NSURL
			print("Recorded URl \(recordedAudioURL)")
			
			playSoundVC.recordedAudioURL = recordedAudioURL
		
		}
	}
}


