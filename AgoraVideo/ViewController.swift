//
//  ViewController.swift
//  AgoraVideo
//
//  Created by osama on 5/27/20.
//  Copyright © 2020 osama. All rights reserved.
//

import UIKit
import AgoraRtcKit
import Pods_AgoraVideo

class ViewController: UIViewController {
    @IBOutlet weak var localVideo: UIView!
    @IBOutlet weak var remoteVideo: UIView!
    @IBOutlet weak var controlButtons: UIView!
    @IBOutlet weak var remoteVideoMutedIndicator: UIImageView!
    @IBOutlet weak var localVideoMutedBg: UIImageView!
    @IBOutlet weak var localVideoMutedIndicator: UIImageView!
    var channel:String? = "Test"
    
    var agoraKit: AgoraRtcEngineKit!                 // Tutorial Step 1
    let AppID: String = "d6bdc09b53134b5b8386fde1a13b2323"                  // Tutorial Step 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initializeAgoraEngine()
        setupVideo()
        joinChannel()
        setupLocalVideo()
        hideVideoMuted()
        setupButtons()
        self.remoteVideo.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initializeAgoraEngine() {
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: AppID, delegate: self as! AgoraRtcEngineDelegate)
    }
    
    func setupVideo() {
        agoraKit.enableVideo()  // Default mode is disableVideo
        agoraKit.setVideoProfile(.DEFAULT, swapWidthAndHeight: false) // Default video profile is 360P
    }
    
    func joinChannel() {
        agoraKit.joinChannel(byToken: nil, channelId: channel!, info:nil, uid:0) {[weak self] (sid, uid, elapsed) -> Void in
            if let weakSelf = self {
                weakSelf.agoraKit.setEnableSpeakerphone(true)
                UIApplication.shared.isIdleTimerDisabled = true
            }
        }
    }
    
    func setupLocalVideo() {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = 0
        videoCanvas.view = localVideo
        videoCanvas.renderMode = .fit
        agoraKit.setupLocalVideo(videoCanvas)
    }
    
    func leaveChannel() {
        agoraKit.leaveChannel(nil)
        hideControlButtons()
        UIApplication.shared.isIdleTimerDisabled = false
        remoteVideo.removeFromSuperview()
        localVideo.removeFromSuperview()
        agoraKit = nil
    }
    
    @objc func hideControlButtons() {
        controlButtons.isHidden = true
    }
    
    @IBAction func didClickHangUpButton(_ sender: UIButton) {
        leaveChannel()
    }
    
    func resetHideButtonsTimer() {
        ViewController.cancelPreviousPerformRequests(withTarget: self)
        perform(#selector(hideControlButtons), with:nil, afterDelay:3)
    }
    
    @IBAction func didClickMuteButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        agoraKit.muteLocalAudioStream(sender.isSelected)
        resetHideButtonsTimer()
    }
    
    @IBAction func didClickVideoMuteButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        agoraKit.muteLocalVideoStream(sender.isSelected)
        localVideo.isHidden = sender.isSelected
        localVideoMutedBg.isHidden = !sender.isSelected
        localVideoMutedIndicator.isHidden = !sender.isSelected
        resetHideButtonsTimer()
    }
    
    @IBAction func didClickSwitchCameraButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        agoraKit.switchCamera()
        resetHideButtonsTimer()
    }
    
    func hideVideoMuted() {
        remoteVideoMutedIndicator.isHidden = true
        localVideoMutedBg.isHidden = true
        localVideoMutedIndicator.isHidden = true
    }
    
    func setupButtons() {
        perform(#selector(hideControlButtons), with:nil, afterDelay:3)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.viewTapped))
        view.addGestureRecognizer(tapGestureRecognizer)
        view.isUserInteractionEnabled = true
    }
    
    @objc func viewTapped() {
        if (controlButtons.isHidden) {
            controlButtons.isHidden = false;
            perform(#selector(hideControlButtons), with:nil, afterDelay:3)
        }
    }
}

extension ViewController: AgoraRtcEngineDelegate {
    // Tutorial Step 5
    func rtcEngine(_ engine: AgoraRtcEngineKit!, firstRemoteVideoDecodedOfUid uid:UInt, size:CGSize, elapsed:Int) {
        if (remoteVideo.isHidden) {
            remoteVideo.isHidden = false
        }
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.view = remoteVideo
        videoCanvas.renderMode = .fit
        agoraKit.setupRemoteVideo(videoCanvas)
    }
    
    // Tutorial Step 5
//    func rtcEngine(_ engine: AgoraRtcEngineKit!, didOfflineOfUid uid:UInt, reason:AgoraRtcUserOfflineReason) {
//    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit!, didVideoMuted muted:Bool, byUid:UInt) {
        remoteVideo.isHidden = muted
        remoteVideoMutedIndicator.isHidden = !muted
    }
}


