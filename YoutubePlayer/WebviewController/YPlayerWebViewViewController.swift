//
//  WebViewViewController.swift
//
//  Created by Mohammad Alabed on 11/08/2021.
//

import UIKit
import AVKit
import WebKit

public protocol YPlayerWebViewViewControllerDelegate {
    func viewClosed()
    func playerIsReady()
}

public class YPlayerWebViewViewController: YPlayerBaseViewController {
    
    public enum WebViewType {
        case embedded
        case searching
    }
    
    @IBOutlet var webview: WKWebView!
    @IBOutlet var dismissButton: UIButton!

    var delegate:YPlayerWebViewViewControllerDelegate?
    public var webviewType = WebViewType.embedded
    private var presentation: YPlayerVideoPlayerPresentaion?
    
    public static func initPlayer(delegate: YPlayerWebViewViewControllerDelegate?) -> YPlayerWebViewViewController {
        let vc = YPlayerWebViewViewController(nibName: "YPlayerWebViewViewController", bundle: Bundle(for: self.classForCoder()))
        vc.delegate = delegate
        return vc
    }
    
    private func embedVideoHtml() -> String {
        
        guard let presentation = presentation else {
            return ""
        }

        webview.scrollView.isScrollEnabled = false
            return "<meta name=\"viewport\" content=\"initial-scale=1.0\" />" + """
            <!DOCTYPE html>
            <html>
            <body>
            
            <!-- 1. The <iframe> (and video player) will replace this <div> tag. -->
            <div id="player"></div>

            <script>
            var tag = document.createElement('script');

            tag.src = "https://www.youtube.com/iframe_api";
            var firstScriptTag = document.getElementsByTagName('script')[0];
            firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

            var player;
            function onYouTubeIframeAPIReady() {
            player = new YT.Player('player', {
            playerVars: { 'autoplay': \(presentation.autoplay), 'controls': \(presentation.controls), 'playsinline': \(presentation.playsinline), 'rel': \(presentation.rel), 'color': '\(presentation.color.rawValue)','start': \(presentation.start),'loop': \(presentation.loop),'fs': \(presentation.fs),'modestbranding': \(presentation.modestbranding) },
            height: '\(self.view.frame.height)',
            width: '\(self.view.frame.width)',
            videoId: '\(presentation.videoId)',
            events: {
            'onReady': onPlayerReady
            }
            });
            }

            function onPlayerReady(event) {
            event.target.playVideo();
                                     window.location.href = 'ytplayer://onReady?data=' + event.data;
            }
            </script>
            </body>
            </html>
            """
    }
    
    private func onPlayerReady() {
        print("onPlayerReady")
        delegate?.playerIsReady()
    }
    
    fileprivate func handleJSEvent(_ eventURL: URL) {

        if let host = eventURL.host, host == "onReady" {
            onPlayerReady()
        }
    }

    @objc func windowDidBecomeVisibleNotification(notif: Notification) {
        
    }
    
    fileprivate func evaluatePlayerCommand(_ command: String, completion: ((Any?) -> Void)? = nil) {
        
        let fullCommand = "player." + command + ";"
        webview.evaluateJavaScript(fullCommand) { (result, error) in
            if let error = error, (error as NSError).code != 5 { // NOTE: ignore :Void return
                print(error)
                print("Error executing javascript")
                completion?(nil)
            }
            completion?(result)
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.viewClosed()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidBecomeVisibleNotification(notif:)), name: NSNotification.Name("UIWindowDidBecomeVisibleNotification"), object: nil)

        if #available(iOS 13.0, *) {
            dismissButton.isHidden = true

        } else {
            dismissButton.layer.cornerRadius = 10
        }
        
        configureWebView()
    }
    
    private func configureWebView() {
        
        webview.configuration.allowsInlineMediaPlayback = true
        webview.configuration.preferences.javaScriptEnabled = true
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [.mixWithOthers, .allowAirPlay])
                    print("Playback OK")
                    try AVAudioSession.sharedInstance().setActive(true)
                    print("Session is Active")
                } catch {
                    print(error)
                }
        webview.configuration.mediaTypesRequiringUserActionForPlayback = []
    }
    
    public func openPage(url: URL) {
        webview.navigationDelegate = self
        webview.uiDelegate = self
        webview.load(URLRequest(url: url))
    }
    
    public func openPageWithVideoId(presentation: YPlayerVideoPlayerPresentaion) {
        webview.navigationDelegate = self
        webview.uiDelegate = self
        self.presentation = presentation
        let embeddedString = embedVideoHtml()
        print(embeddedString)
        webview.loadHTMLString(embeddedString, baseURL: nil)

    }
    
    @IBAction func dismissTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension YPlayerWebViewViewController: WKNavigationDelegate,WKUIDelegate {

    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("start nav")
        self.showLoadingView()
    }
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finish nav")
        self.hideLoadingView()
    }
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("didCommit")
    }
    public func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("didReceiveServerRedirectForProvisionalNavigation")
    }
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        print("navigationResponse")
        decisionHandler(.allow)
    }
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        var action: WKNavigationActionPolicy?
        defer {
            decisionHandler(action ?? .allow)
        }

        guard let url = navigationAction.request.url else { return }

        if url.scheme == "ytplayer" {
            handleJSEvent(url)
            action = .cancel
        }
    }
}

extension YPlayerWebViewViewController {
    
    /// Returns the elapsed time in seconds since the video started playing.
    public func getCurrentTime(handler: @escaping (Float?) -> Void) {
        self.evaluatePlayerCommand("getCurrentTime()") { time in
            handler(time as? Float)
        }
    }
    
    /// Seeks to a specified time in the video. If the player is paused when the function is called, it will remain paused. If the function is called from another state (playing, video cued, etc.), the player will play the video.
    public func seekTo(time: Float) {
        self.evaluatePlayerCommand("seekTo(\(time), \(true))")
    }
    
    /// Mutes the player.
    public func mute() {
        self.evaluatePlayerCommand("mute()")
    }
    
    /// Unmutes the player.
    public func unMute() {
        self.evaluatePlayerCommand("unMute()")
    }
    
    /// Returns true if the player is muted, false if not.
    public func isMuted(handler: @escaping (Bool?) -> Void) {
        self.evaluatePlayerCommand("isMuted()") { isMuted in
            handler(isMuted as? Bool)
        }
    }
    
    /// Sets the volume. Accepts an integer between 0 and 100.
    public func setVolume(volume: Int) {
        self.evaluatePlayerCommand("setVolume(\(volume))")
    }
    
    /// Returns the player's current volume, an integer between 0 and 100. Note that getVolume() will return the volume even if the player is muted.
    public func getVolume(handler: @escaping (Int?) -> Void) {
        self.evaluatePlayerCommand("getVolume()") { volume in
            handler(volume as? Int)
        }
    }

    /// This function sets the suggested playback rate for the current video. If the playback rate changes, it will only change for the video that is already cued or being played. If you set the playback rate for a cued video, that rate will still be in effect when the playVideo function is called or the user initiates playback directly through the player controls. In addition, calling functions to cue or load videos or playlists (cueVideoById, loadVideoById, etc.) will reset the playback rate to 1.
    public func setPlaybackRate(value: Float) {
        self.evaluatePlayerCommand("setPlaybackRate(\(value))")
    }
    
    /// This function retrieves the playback rate of the currently playing video. The default playback rate is 1, which indicates that the video is playing at normal speed. Playback rates may include values like 0.25, 0.5, 1, 1.5, and 2.
    public func getPlaybackRate(handler: @escaping (Float?) -> Void) {
        self.evaluatePlayerCommand("getPlaybackRate()") { value in
            handler(value as? Float)
        }
    }
    
    /// - This function returns the set of playback rates in which the current video is available. The default value is 1, which indicates that the video is playing in normal speed.
    /// - The function returns an array of numbers ordered from slowest to fastest playback speed. Even if the player does not support variable playback speeds, the array should always contain at least one value (1).
    public func getAvailablePlaybackRates(handler: @escaping ([Float]?) -> Void) {
        self.evaluatePlayerCommand("getAvailablePlaybackRates()") { value in
            handler(value as? [Float])
        }
    }
    
    /// - This function indicates whether the video player should continuously play a playlist or if it should stop playing after the last video in the playlist ends. The default behavior is that playlists do not loop.
    /// - This setting will persist even if you load or cue a different playlist, which means that if you load a playlist, call the setLoop function with a value of true, and then load a second playlist, the second playlist will also loop.
    /// - The required loopPlaylists parameter identifies the looping behavior.
    /// - If the parameter value is true, then the video player will continuously play playlists. After playing the last video in a playlist, the video player will go back to the beginning of the playlist and play it again.
    /// - If the parameter value is false, then playbacks will end after the video player plays the last video in a playlist
    public func setLoop(value: Float) {
        self.evaluatePlayerCommand("setLoop(\(value))")
    }
    
    /// This function indicates whether a playlist's videos should be shuffled so that they play back in an order different from the one that the playlist creator designated. If you shuffle a playlist after it has already started playing, the list will be reordered while the video that is playing continues to play. The next video that plays will then be selected based on the reordered list.
    public func setShuffle(value: Float) {
        self.evaluatePlayerCommand("setShuffle(\(value))")
    }
    
    /// Returns a number between 0 and 1 that specifies the percentage of the video that the player shows as buffered. This method returns a more reliable number than the now-deprecated getVideoBytesLoaded and getVideoBytesTotal methods.
    public func getVideoLoadedFraction(handler: @escaping (Float?) -> Void) {
        self.evaluatePlayerCommand("getVideoLoadedFraction()") { value in
            handler(value as? Float)
        }
    }
    
    public enum PlayerState: Int {
        case unstarted = -1
        case ended = 1
        case playing = 2
        case paused = 3
        case buffering = 4
        case video_cued = 5
    }
    
    /// Returns the state of the player. Possible values are:
    /// - -1 – unstarted
    /// - 0 – ended
    /// - 1 – playing
    /// - 2 – paused
    /// - 3 – buffering
    /// - 5 – video cued
    public func getPlayerState(handler: @escaping (PlayerState) -> Void) {
        self.evaluatePlayerCommand("getPlayerState()") { value in
            let value = value as? Int
            let state = PlayerState(rawValue: value ?? -1)
            handler(state ?? .unstarted)
        }
    }
    
    /// Returns the duration in seconds of the currently playing video. Note that getDuration() will return 0 until the video's metadata is loaded, which normally happens just after the video starts playing.
    public func getDuration(handler: @escaping (Float?) -> Void) {
        self.evaluatePlayerCommand("getDuration()") { value in
            handler(value as? Float)
        }
    }
    
    /// Returns the embed code for the currently loaded/playing video.
    public func getVideoEmbedCode(handler: @escaping (Float?) -> Void) {
        self.evaluatePlayerCommand("getVideoEmbedCode()") { value in
            handler(value as? Float)
        }
    }
    
    /// Plays the currently cued/loaded video. The final player state after this function executes will be playing (1).
    public func playVideo() {
        self.evaluatePlayerCommand("playVideo()")
    }
    
    /// Stops and cancels loading of the current video. This function should be reserved for rare situations when you know that the user will not be watching additional video in the player. If your intent is to pause the video, you should just call the pauseVideo function. If you want to change the video that the player is playing, you can call one of the queueing functions without calling stopVideo first.
    public func stopVideo() {
        self.evaluatePlayerCommand("stopVideo()")
    }
    
    /// Pauses the currently playing video. The final player state after this function executes will be paused (2) unless the player is in the ended (0) state when the function is called, in which case the player state will not change.
    public func pauseVideo() {
        self.evaluatePlayerCommand("pauseVideo()")
    }
        
    /// This method returns the DOM node for the embedded <iframe>.
    public func getIframe() {
        self.evaluatePlayerCommand("getIframe()")
    }
}
