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
        let vc = WebViewViewController(nibName: "WebViewViewController", bundle: nil)
        vc.webviewType = .searching
        
        self.present(vc, animated: true) {
            vc.openPage(url: URL(string: "https://www.youtube.com/results?search_query=podcast")!)
        }
    }
    
    @IBAction func searchForSampleYoutubeVideo(_ sender: UIButton) {
        searchForPodcastInYoutube(text: "Podcasts")
    }
    
    func searchForPodcastInYoutube(text: String) {
        let vc = WebViewViewController(nibName: "WebViewViewController", bundle: nil)
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
        let vc = WebViewViewController(nibName: "WebViewViewController", bundle: nil)
        self.present(vc, animated: true) {
            vc.openPageWithVideoId(vidID: "NQts-Ma1IFg")
        }
    }
}

