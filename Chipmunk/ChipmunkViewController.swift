//
//  ViewController.swift
//  Chipmunk
//
//  Created by Yogesh Padekar on 16/08/20.
//  Copyright © 2020 MusicMuni. All rights reserved.
//

import UIKit
import AVFoundation
import Lottie

class ChipmunkViewController: UIViewController {
    // MARK:- Variables
    @IBOutlet private var lblDuration: UILabel?
    @IBOutlet private var viwTimer: UIView?
    @IBOutlet private var viwPlayButtonContainer: UIView?
    @IBOutlet private var viwPlaybackAnimation: AnimationView?
    
    // MARK:- Variables
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var audioSession: AVAudioSession?
    private var recordTimer: Timer?
    private var timerCounter = 0
    private let iAllowedAudioLength = 10
    private let iNumberOfPitchLevelsToRaise = 6
    private lazy var speechSynthesizer = AVSpeechSynthesizer()
    
    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setting up recording session
        self.audioSession = AVAudioSession.sharedInstance()
        self.audioSession?.requestRecordPermission { (permitted) in
            if permitted {
                print("Permission granted")
            }
        }
    }
    
    // MARK:- IBActions
    /// IBAction which called on tap of 'Start' and starts recording
    /// - Parameter btn: Sender button
    @IBAction private func recordAudio(btn: UIButton) {
        //Check if we have an active recorder and if not then we can prepare to start one
        if self.audioRecorder == nil {
            //Settings to record WAV file
            let audioSettings = [AVFormatIDKey: Int(kAudioFormatLinearPCM),
                                 AVSampleRateKey: 12000,
                                 AVNumberOfChannelsKey: 1,
                                 AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            
            //Start audio recording
            do {
                self.viwTimer?.isHidden = false
                self.audioRecorder = try AVAudioRecorder(url: self.fileURLForRecordedAudio, settings: audioSettings)
                self.audioRecorder?.record()
                self.viwPlayButtonContainer?.isHidden = true
                self.recordTimer = Timer.scheduledTimer(timeInterval: 1,
                                                        target: self,
                                                        selector: #selector(showTimeAndStopRecording),
                                                        userInfo: nil,
                                                        repeats: true)
                self.recordTimer?.fire()
            } catch {
                print("Error in recording: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK:- User defined functions
    
    /// Computed property to get file URL of recorded audio file
    private var fileURLForRecordedAudio: URL {
        return URL(fileURLWithPath: NSTemporaryDirectory(),
                   isDirectory: true).appendingPathComponent(Constants.kRecordedAudioFileName)
    }
    
    /// Computed property to get file URL of processed audio file
    private var fileURLForProcessedAudio: URL {
        return URL(fileURLWithPath: NSTemporaryDirectory(),
                   isDirectory: true).appendingPathComponent(Constants.kProcessedAudioFileName)
    }
    
    /// Function to show recording time and stop the recorder after 10 seconds
    @objc private func showTimeAndStopRecording() {
        self.timerCounter += 1
        let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)]
        
        //Make attributed string to show duration
        self.lblDuration?.text = "\(self.timerCounter)"
        let durationAttributedString = NSMutableAttributedString(string: "\(self.timerCounter)\n",
                                                                 attributes: attributes as [NSAttributedString.Key: Any])
        let secondsAttributedString = NSAttributedString(string: Constants.kSeconds,
                                                         attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)])
        durationAttributedString.append(secondsAttributedString)
        self.lblDuration?.attributedText = durationAttributedString
        
        if self.timerCounter > self.iAllowedAudioLength {
            //Reset timer, counter and UI
            self.recordTimer?.invalidate()
            self.recordTimer = nil
            self.timerCounter = 0
            self.viwTimer?.isHidden = true
            self.viwPlayButtonContainer?.isHidden = false
            
            //Stop audio recording
            self.audioRecorder?.stop()
            self.audioRecorder = nil
            
            //Change pitch of the file and save
            self.setAudioFilePitchTo(self.iNumberOfPitchLevelsToRaise)
            
            //Play the processed file
            self.playbackProcessedRecording()
        }
    }
    
    /// Function which calls wrapper class function to change recorded audio file's pitch
    /// - Parameter pitch: Pitch value to set as Int
    private func setAudioFilePitchTo(_ pitch: Int) {
     SoundTouchWrapper().base(self.fileURLForRecordedAudio,
                              output: self.fileURLForProcessedAudio,
                              effects: ["-pitch=\(pitch)"])
    }
    
    /// Function to play/stop lottie animation
    private func playOrStopAnimation() {
        if (self.viwPlaybackAnimation?.isHidden ?? true) {
            self.viwPlaybackAnimation?.isHidden = false
            self.viwPlaybackAnimation?.contentMode = .scaleAspectFit
            self.viwPlaybackAnimation?.loopMode = .loop
            self.viwPlaybackAnimation?.animationSpeed = 1.0
            self.viwPlaybackAnimation?.play()
        } else {
            self.viwPlaybackAnimation?.isHidden = true
            self.viwPlaybackAnimation?.stop()
            self.viwPlayButtonContainer?.isHidden = false
        }
    }
    
    /// Function to play the resulted audio file after processing
    private func playbackProcessedRecording() {
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: self.fileURLForProcessedAudio)
            self.audioPlayer?.delegate = self
            self.audioPlayer?.prepareToPlay()
            self.audioPlayer?.play()
            self.playOrStopAnimation()
        } catch {
            print("Error while playing the file = \(error.localizedDescription)")
        }
    }
}

extension ChipmunkViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        //Release audio player instance
        self.audioPlayer = nil
        self.playOrStopAnimation()
    }
}

