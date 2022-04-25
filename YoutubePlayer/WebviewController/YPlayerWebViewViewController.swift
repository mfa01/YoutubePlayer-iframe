//
//  WebViewViewController.swift
//
//  Created by Mohammad Alabed on 11/08/2021.
//

import UIKit
import AVKit
import WebKit

protocol YPlayerWebViewViewControllerDelegate {
    func viewClosed()
    func playerIsReady()
}

class YPlayerWebViewViewController: YPlayerBaseViewController {

    enum WebViewType {
        case embedded
        case searching
    }
    
    @IBOutlet var webview: WKWebView!
    @IBOutlet var dismissButton: UIButton!

    var delegate:YPlayerWebViewViewControllerDelegate?
    var webviewType = WebViewType.embedded
    private var presentation: VideoPlayerPresentaion?
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.viewClosed()
    }
    
    override func viewDidLoad() {
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
    
    func openPage(url: URL) {
        webview.navigationDelegate = self
        webview.uiDelegate = self
        webview.load(URLRequest(url: url))
    }
    
    func openPageWithVideoId(presentation: VideoPlayerPresentaion) {
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

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("start nav")
        self.showLoadingView()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finish nav")
        self.hideLoadingView()
    }
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("didCommit")
    }
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("didReceiveServerRedirectForProvisionalNavigation")
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        print("navigationResponse")
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
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
    
    func getCurrentTime(handler: @escaping (Float?) -> Void) {
        self.evaluatePlayerCommand("getCurrentTime()") { time in
            handler(time as? Float)
        }
    }
    
    func seek(time: Float) {
        self.evaluatePlayerCommand("seekTo(\(time), \(true))")
    }
    
    func mute() {
        self.evaluatePlayerCommand("mute()")
    }
    
    func unMute() {
        self.evaluatePlayerCommand("unMute()")
    }
    
    func isMuted(handler: @escaping (Bool?) -> Void) {
        self.evaluatePlayerCommand("isMuted()") { isMuted in
            handler(isMuted as? Bool)
        }
    }
    
    func setVolume(volume: Float) {
        self.evaluatePlayerCommand("setVolume(\(volume))")
    }
    
    func getVolume(handler: @escaping (Float?) -> Void) {
        self.evaluatePlayerCommand("getVolume()") { volume in
            handler(volume as? Float)
        }
    }

    func setPlaybackRate(value: Float) {
        self.evaluatePlayerCommand("setPlaybackRate(\(value))")
    }
    
    func getPlaybackRate(handler: @escaping (Float?) -> Void) {
        self.evaluatePlayerCommand("getPlaybackRate()") { value in
            handler(value as? Float)
        }
    }
    
    func getAvailablePlaybackRates(handler: @escaping ([Float]?) -> Void) {
        self.evaluatePlayerCommand("getAvailablePlaybackRates()") { value in
            handler(value as? [Float])
        }
    }
    
    func setLoop(value: Float) {
        self.evaluatePlayerCommand("setLoop(\(value))")
    }
    
    func setShuffle(value: Float) {
        self.evaluatePlayerCommand("setShuffle(\(value))")
    }
    
    /// Returns a number between 0 and 1 that specifies the percentage of the video that the player shows as buffered. This method returns a more reliable number than the now-deprecated getVideoBytesLoaded and getVideoBytesTotal methods.
    func getVideoLoadedFraction(handler: @escaping (Float?) -> Void) {
        self.evaluatePlayerCommand("getVideoLoadedFraction()") { value in
            handler(value as? Float)
        }
    }
    
    /*
     
     Returns a number between 0 and 1 that specifies the percentage of the video that the player shows as buffered. This method returns a more reliable number than the now-deprecated getVideoBytesLoaded and getVideoBytesTotal methods.
     player.getPlayerState():Number
     Returns the state of the player. Possible values are:
     -1 – unstarted
     0 – ended
     1 – playing
     2 – paused
     3 – buffering
     5 – video cued
     player.getCurrentTime():Number

     player.getDuration():Number
     player.getVideoEmbedCode():String

     */
    func stopVideo() {
        
    }
}
