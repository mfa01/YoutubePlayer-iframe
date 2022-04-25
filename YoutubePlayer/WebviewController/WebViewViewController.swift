//
//  WebViewViewController.swift
//
//  Created by Mohammad Alabed on 11/08/2021.
//

import UIKit
import AVKit
import WebKit
protocol WebViewViewControllerDelegate {
    func viewClosed()
    func playerIsReady()
}
extension WebViewViewControllerDelegate {
    func viewClosed() {}
    func playerIsReady() {}
}

class WebViewViewController: UIViewController {

    var delegate:WebViewViewControllerDelegate?
    var videoURL = ""
    @IBOutlet var webview: WKWebView!
    @IBOutlet var dismissButton: UIButton!
    
    enum WebViewType {
        case embedded
        case searching
    }
    
    private lazy var loadingView: UIActivityIndicatorView = {
        let loginSpinner = UIActivityIndicatorView(style: .large)
        loginSpinner.translatesAutoresizingMaskIntoConstraints = false
        loginSpinner.hidesWhenStopped = true
        view.addSubview(loginSpinner)
        loginSpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginSpinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        return loginSpinner
    }()
    
    func showLoadingView() {
        loadingView.startAnimating()
    }
    
    func hideLoadingView() {
        loadingView.stopAnimating()
    }
    
    

    var webviewType = WebViewType.embedded

    func embedVideoHtml() -> String {
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
            playerVars: { 'autoplay': 1, 'controls': 1, 'playsinline': 1, 'rel': 0 },
            height: '\(self.view.frame.height)',
            width: '\(self.view.frame.width)',
            videoId: '\(videoURL)',
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
    func onPlayerReady() {
        print("onPlayerReady")
        delegate?.playerIsReady()
    }
    
    func seek(time: Float) {
        self.evaluatePlayerCommand("seekTo(\(time), \(true))")
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
    
    func getCurrentTime(handler: @escaping (Float?) -> Void) {
        self.evaluatePlayerCommand("getCurrentTime()") { time in
            handler(time as? Float)
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
    func openPageWithVideoId(vidID: String) {
        webview.navigationDelegate = self
        webview.uiDelegate = self
        videoURL = vidID
        webview.loadHTMLString(embedVideoHtml(), baseURL: nil)

    }
    @IBAction func dismissTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension WebViewViewController: WKNavigationDelegate,WKUIDelegate {

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
