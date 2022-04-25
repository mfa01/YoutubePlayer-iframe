//
//  ViewController.swift
//  YoutubePlayer
//
//  Created by Mabed on 25/04/2022.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func openSampleVideo(_ sender: UIButton) {
        let vc = YPlayerWebViewViewController(nibName: "WebViewViewController", bundle: nil)
        vc.webviewType = .searching
        
        self.present(vc, animated: true) {
            vc.openPage(url: URL(string: "https://www.youtube.com/results?search_query=podcast")!)
        }
    }
    
    @IBAction func searchForSampleYoutubeVideo(_ sender: UIButton) {
        searchForPodcastInYoutube(text: "Podcasts")
    }
    
    func searchForPodcastInYoutube(text: String) {
        let vc = YPlayerWebViewViewController.initPlayer(delegate: nil)
        vc.webviewType = .searching
        self.present(vc, animated: true) {
            var c = URLComponents(string: "https://www.youtube.com/results")
            c?.queryItems = [
                URLQueryItem(name: "search_query", value: text)
            ]
            guard let url = c?.url else { return print("url fail") }
            vc.openPage(url: url)
        }
    }
    

    @IBAction func openVideoWithId(_ sender: UIButton) {
        let vc = YPlayerWebViewViewController.initPlayer(delegate: self)
        
        var videoPresenetation = VideoPlayerPresentaion(videoId: "668nUCeBHyY")
        videoPresenetation.autoplay = 0
        videoPresenetation.loop = 1
        videoPresenetation.modestbranding = 1
        videoPresenetation.playsinline = 1
        videoPresenetation.controls = 0
        videoPresenetation.start = 1
        videoPresenetation.rel = 0
        videoPresenetation.color = .white
        videoPresenetation.fs = 1
        
        self.present(vc, animated: true) {
            vc.openPageWithVideoId(presentation: videoPresenetation)
        }
        
        vc.mute()
        vc.isMuted { muted in
            print("ismuted: \(muted)")
        }
        vc.getPlayerState { state in
            print(state)
        }
    }
}

extension ViewController: YPlayerWebViewViewControllerDelegate {
    
    func viewClosed() {
        print("viewClosed")
    }
    
    func playerIsReady() {
        print("playerIsReady")
    }
}
