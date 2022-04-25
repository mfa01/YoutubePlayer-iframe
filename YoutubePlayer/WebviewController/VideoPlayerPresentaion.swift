//
//  VideoPlayerPresentaion.swift
//  YoutubePlayer
//
//  Created by Mabed on 25/04/2022.
//

import Foundation

struct VideoPlayerPresentaion {
    
    let videoId: String
    
    /// This parameter specifies whether the initial video will automatically start to play when the player loads. Supported values are 0 or 1. The default value is 0.
    /// If you enable Autoplay, playback will occur without any user interaction with the player; playback data collection and sharing will therefore occur upon page load.
    var autoplay = 1
    
    /// This parameter indicates whether the video player controls are displayed:
    /// controls=0 – Player controls do not display in the player.
    /// controls=1 (default) – Player controls display in the player.
    var controls = 1
    
    enum PlayerColor: String {
        case red = "red"
        case white = "white"
    }
    /// This parameter specifies the color that will be used in the player's video progress bar to highlight the amount of the video that the viewer has already seen. Valid parameter values are red and white, and, by default, the player uses the color red in the video progress bar. See the YouTube API blog for more information about color options.
    /// Note: Setting the color parameter to white will disable the modestbranding option.
    var color: PlayerColor = .red
    
    /// This parameter controls whether videos play inline or fullscreen on iOS. Valid values are:
    /// 0: Results in fullscreen playback. This is currently the default value, though the default is subject to change.
    /// 1: Results in inline playback for mobile browsers and for WebViews created with the allowsInlineMediaPlayback property set to YES.
    var playsinline = 1
    
    /// This parameter causes the player to begin playing the video at the given number of seconds from the start of the video. The parameter value is a positive integer. Note that similar to the seekTo function, the player will look for the closest keyframe to the time you specify. This means that sometimes the play head may seek to just before the requested time, usually no more than around two seconds.
    var start: Float = 0.0
    
    /// In the case of a single video player, a setting of 1 causes the player to play the initial video again and again. In the case of a playlist player (or custom player), the player plays the entire playlist and then starts again at the first video.
    /// Supported values are 0 and 1, and the default value is 0.
    var loop = 0
        
    /// Prior to the change, this parameter indicates whether the player should show related videos when playback of the initial video ends.
    /// If the parameter's value is set to 1, which is the default value, then the player does show related videos.
    /// If the parameter's value is set to 0, then the player does not show related videos.
    /// After the change, you will not be able to disable related videos. Instead, if the rel parameter is set to 0, related videos will come from the same channel as the video that was just played.
    var rel = 0
    
    /// Setting this parameter to 0 prevents the fullscreen button from displaying in the player. The default value is 1, which causes the fullscreen button to display.
    var fs = 1
    
    /// This parameter lets you use a YouTube player that does not show a YouTube logo. Set the parameter value to 1 to prevent the YouTube logo from displaying in the control bar. Note that a small YouTube text label will still display in the upper-right corner of a paused video when the user's mouse pointer hovers over the player.
    var modestbranding = 0
}
