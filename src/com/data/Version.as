package com.data
{
	public class Version
	{
		public static const VERSION:String = "4.2.20121212";
		
		/*
				2.1.20091105
					- added support for scene duration
					
				2.1.20091111
					- enabled the small play button as the data is ready
					- fixed video-ads integration (which was broken by previous changes)
					
				2.1.20091112
					- fixed many graphic issues
					- added tool tips
					- added keyboard shortcuts
					
				2.1.20091116
					- added more keyboard shortcuts (all the non-letters keys)
					- disabled keyboard shortcuts in writing-comment mode
					- rebuilt the comments stracture, and added the CommentManager class, which all classes dealing with comments refer to
					- added double-click to the video - open full screen
					
				2.2.20091119
					- changed the playhead graphics (while in comments mode)
					- added tooltip to the playhead
					- added embed code and link to the share pannel
					- added functionality and tooltips to the sharing buttons in the share pannel
					- added automatic adding of ads (for videos without ads)
					- controls disapear in full-screen mode when user not active for 3 secs
					- fixed positioning of elements on stage (when stage size changes)
					- fixed a bug in the tool-tips while in full-screen mode
					- updated the graphics of the share buttons in the share pannel
					
				2.2.20091122
					- fixed bug of switching to full screen when there's an open pannel
					- fixed bug of closing the comments pannel when opening another pannel
					- if there's a preroll - video doesn't start to play untill only after the preroll
					- fixed bug with ad loading error
					
				2.2.200901123
					- updated the tool tips
					- added still image before video starts playing
					- fixed seek-offset issues
					- enabled call to JS on lights on/off
					- added nana10 logo
					- fixed twitter/talker hebrew issues
					- added current time tool tip over the timeline
					- added ads' skip functionality
					- added support for 'ShowAds=true/false'
					
				2.2.20091124
					- added support in the video player for status 'NetStream.Play.FileStructureInvalid' - relevant for mp4 files (ran into it only while playing in IE)
					
				2.2.20091130
					- added support to CastUp XML
					- fixed bugs with opening/closing pannels and comments' bar
					- added fade-out at end of video (plus jumping to begining of video when clicking 'play')
					- added statistics
					- removed support for talker/twitter hebrew issuses - adding 'System.useCodePage = true;' caused many other problems.
					
				2.2.20091203
					- enhanced support to castUp xml
					- made graphic changes - mostly to buttons
					- added support to video's url 'fall-back' (in case the video can't be loaded - the next video on the list is loaded, and so on)
					- changed the comments' dislplay cycle
					- added encoding paramter to the castUp's url - so bookmarks' hebrew names can be displayed (though CastUp doesn't fully support it yet)
					- displaying loading animation when video is buffering	
					- fixed sandbox issue with pre-video still image
					
				2.2.20091206
				 	- fixed HQ problem when switching to full screen (removed the 'setSize(height)' line from the 'onDisplayStatChanged' function in the Nana10VideoPlayer class
				 	- finished support to statistics - getting video's id from static xml (trying to load it - if not found, creating one)
				 	
				2.2.20091207
					- added support to embeded player
					- flash vars paramters are accessable via a singleton class
					
				2.2.20091208
					- video doesn't start to play when there's a preroll
					- fixed end of video having postroll (added the 'hasPostroll' property)
					- full screen and lights button are disabled when player is embeded version	
					- adStrip now also display general error messages	
					- added end of movie display
					- changed the 'on_added_to_stage' to 'enter_frame' on the main class - to avoid the IE refersh problem
					
				2.2.20091209
					- moved the setting of the x & y from the constructor to the 'addedToStage' - same reason as above
					- video ads are now clickable, and when start to play they update nana10's server
					- added 'finger' cursor over the timeline
					- default's volume level is 50%, and current volume level is saved in a shared object
					- timeline's banner pops half a second after rolling over it
					- end of movie window displays movie's poster image
					
				2.2.20091210
					- fixed tooltip issue on the comment butotn
					- fixed bug of end of movie with postroll 
					- added a preloader
					
				2.2.20091213
					- added support for 'ORIGINAL_CLIP_TOTAL_DURATION' prorperty in the cast-up xml
					- loading animation is hidden when ads player is buffering after it hidden
					
				2.2.20091214
					- fixed full screen issues (that were caused after the end-of-video window was added)
					- comments in full screen are displayed in font size 14 (11 in normal)
					- the 'add comment' button in the floating comments container is disabled in full screen
					- while the 'new comment' window is open - the full-screen and comments buttons are disabeld
					- added error log (using ServerFunctions.setError)
					
				2.2.20091215
					- fixed comments bar issues: on ads' break, when seeking, on end of video
					- changed samsung banner's font color
					- end of video's cover's alpha changed to 20% (instead of 90%)
					- added MediAnd's credits
					- comments default's state is open
					- added tooltip to the floating comments container's buttons
					- added buffer progress display
					
				2.2.20091216
					- added 'smoothing' to the video player
					- added support to autoplay
					
				2.2.20091217
					- changed the 'setSize' function in the Nana10VideoPlayer class, so it will work on different screen resolutions and ratios
					- fixed the 'disapearing controls' bug, which happend when the fullscreen mode was exited while the controls were tweening
					
				2.2.20091220
					- the Preloader now supports the 'Version.txt' file.  also updated the ShareWindow class
					- updated the outgoing errors' reports (added video id/still image url/talkback id
					
				2.2.20091221
					- enhanced support for SetError function (added PartnerID parameter)
					
				2.2.20091224
					- changed & updated all the comments & comments' buttons functionality
					- updated the comments buttons graphics
					- changed the volume button's roll-over to appear above the slider
					- clicking on a link at the end of video plays the new one in the same player (without going to a different url)
					- comments' user name is save in a shared-object
					- video's smoothing on LQ videos is enabled based on a FlashVar (LQSmoothing)
					- when going to full-screen sending a JS function request to close banners		
				
				2.2.20091227
					- sending OS + flash player version to the error log
					- DataRequest sends a timeout message after 30 seconds
					- comments' user name is sent via flash vars (TODO: fix hebrew problem)	
					
				2.2.20091230
					- reordered layering of visual elements, so the controls are above the ads' video player
					- added 'replay' button and title to the end-of-video window
					
				2.2.20091231
					- comments buttons are available only after video starts playing
					
				2.2.20100113
					- changed the bg of end-of-vidoe window
					- end-of-video uses un-escape to decoe the title
					- new comment also uses un-escape to decode user's name
					- supports EnableEmbed paramter (in the flash vars);
				
				2.2.20100104
					- HAPPY BIRTHDAY!
					- in the share window - talker/twitter now open a pop-up
					
				2.2.20100106
					- Mediand's staic xml is loaded with DataRequest (not XMLLoader) - thus if not found, isn't being called repeatedly
					- DataRequest's error message also sends http status
					
				2.2.20100107
					- scenes derived from CastUp meta-data, use 'pos_duration' as the start point (not pos_sec)
					- in the MediandVideoPlayer, video resizing is done according to original size, not current
					- outside-of-israel users are displayed with a message (not actually tested)
					- fixed the getCastUpAlternateVideoURL function
					
				2.2.20100110
					- dealing with cases where's there's no video file path received in the XML
					
				2.2.20100111
					- if clicking the play/pause button before the movie starts playing (while loading) - when ready, it won't play
					- when ad's url is of 'pixel.gif' (instead of video file) - no error is reported
					- facebook button uses the same pop-up of twitter/talker
					- removed the encoding, codepage and getClip params from the CastUp xml's url (before loading it)
					
				2.2.20100113
					- adsVideoError display a more detailed error in the log
					- ad-strip doesn't display countdown when no ad is playing (didn't actually solved - just by-passed the issue)
					- DataRepository clear is more accurate
					- if end-of-video links won't return VideoLink - an error message is displayed
					- when switching to HQ - floating comments won't dissapear
					- displaying clip duration before it begins playing
					- playhead timer's tooltip is updated while the playhead is dragged
				
				2.2.20100114
					- ads without valid url aren't clickable
					
				2.2.20100120
					- controls' banner is invisible if player width is less than 448
					- floating comments also display user name
					
				2.2.20100124
					- fixed several bugs regarding postrolls and end-of-video
					
				2.2.20100208
					- when non-buffering video is loading, the loading animation displays its bytes loading progress
					- added timer to check after video begins playing, if it realy had began playing; if not - sending it 100ms forward
					- re-fixed positioning of elements on stage (when stage size changes) - the x and y setting of the player when it loads are necessary
					
				2.2.20100209
					- fitted the player to compile with the html property SAlign set to 'LT' (so it would fit embeding in facebook), meaning no need to
					  set the x & y of the player when it loads, and when changing to full-screen no need to set the x & y of all stage elements. besides,
					  re-designed the 'setSize' function on the video player (again), to be (hopefully) more accurate - should work now with different
					  stage proportions
					- fixed the timer which checks if the video is stuck after pre-roll
					
				2.2.20100210
					- well apparently the SAlign property was still causing problems (especially when it appears before the 'scale' property in the html)
					  so in order to solve this simply added 'stage.align = StageAlign.TOP_LEFT;' to the preloader
					- in embedded player - if the AutoPlay property is set to true in the flash-vars, ignoring it in the SharedData
					- disabled the full-screen button in embedded-player
					
				2.2.20100211
					- request for HQ url's is issued only the first time the user clicks the 'hq' button
					
				2.2.20100217
					- when switching to HQ loading animation isn't hidden
					- updated graphics for the mute button
					- floating comments attach/detach button was reversed (so attaching became detaching and vice-versa)
					
				2.2.20100221
					- added on-screen debugging window (via the Debugging class)
					
				2.2.20100222
					- video is muted before pre-roll, so sound won't pop for a split of a second
					- when un-muting - returning to the previous volume level
					
				2.3.20100223
					- fixed more mute/volume issues (made the 'canUnmute' and 'origVolumeY' properties redundant)
					- replaced the banner on the controls
					
				2.4.20100225
					made several changes to avoid overloading of rendering process:
					- when loadingAnimation is hidden, its animation is paused
					- in the Controls class, united progressTimer and bufferTimer into a single timer object
					- the Statistics timer starts working only when stats begin to accumulate
					- floating comments are added only when the floating animation container is visible
					
					- play icon and loading animation are centered when toggling full-screen
					
				2.4.20100228
					- cleared and documented the code
					- moved the volume control code from the Control class to the VolumeControl class 
					  (and moved them with the TimelineControl class to the 'control' package)
					- moved the EndOfVideoDisplay class to the pannels pagckage 
					
				2.5.20100316
					- redesinged the whole ads video loading and playing
					- ads are pre-loaded 30 secs before they begin playing
					- if there's a pre-roll, when the pre-roll begins playing the main video is discarded, 
					  and its download begins after the pre-roll was completely downloaded 
					  
				2.5.20100317
					- added opening form, which sends data via ExternalInterface, and uses Shared Object whether to display or not
					
				2.5.20100318
					- timeout for main data request was changed to 10sec (instead of 30)
					- loading animation is playing while main data is loading 
					
				2.5.20100328
					- opening form's default year is 1980
					- replaced the statistics reporting class, so now data is sent directly to nana10
					
				2.5.20100329
					- stats are sent using GUID
					
				2.5.20100406
					- stats are sent using POST
					- stats moviePosition is in ms (also - the main video time is sent - the one of the ads is ignored)
					
				2.5.20100408
					- adsURL in the AdsContainer was replaced, and now works only with CM8Target
					- at the end of video, if there's no poster image replay button is displayed (it wasn't so far)
					- fixed more end of video issues regarding other items
					
				2.5.20100411
					- fixed end-of-video issues: replaying current video (enabling the timeline controls), and selecting other video
					- jump-to-time statistics send jump-to timecode in ms.
					- embeded video, when clicked, is paused and a new browser's tab/window is opened with the original video on nana10 website
					
				2.5.20100414
					- updated the param's name in the ads' xml, so the 'LogoURL' and 'EventView' can be read properly
					
				2.5.20100415
					- added call to "MediAnd.OnPlay" when video starts playing
					- added stats types to deal with ads, erate and checkm8
					- updated the opening form to display the age in radio-buttons (and not drop-down)
					
				2.5.20100418
					- opening form is displayed also according to FlahsVar 'ShowDetailsForm'
					- post-roll aren't displayed anymore
					- when an ad is played and/or clicked - sending data to erate as well
					- updating checkm8 and erate stats when an ad is played/clicked
					
				2.5.20100422
					- control bar's banner is externaly loaded, using flash var 'AdURL'
					- statistics are sent one-by-one (so if few are sent at the same time, all of them will be processed) 
					
				2.5.20100427
					- fixed parameter name in the call for ad data
					- added callback so lights button can be toggled from the html
					
				2.5.20100503
					- added "Security.allowDomain("*")" in the preloader
					
				2.5.20100516
					- fixed all sort issues relating the stats (added MoreInNanaShow, CommentsClose isn't sent when the video ends,
					added Preroll-LoadComplete, replaced order of 'PreRoll-Play' and 'ReportCheckM8')
					
				2.5.20100517
					- fixed bug related to 'EnableEmbed', which had no affect in embedded players
					
				2.5.20100523
					- calling the 'MediAnd.OnPlay' externla JS function only on non-embedded players
					
				2.5.20100527
					- during ads break volume level is reduced by 15%, and resorted when ad ends (unless volume was changed during the break)
					- stats are sending counter and seesion timer
					- reading ads' data from 3rd parties
					- sessionID parameter in the Stats is passed from flashVars
					- post-rolls are re-instated (they should be removed on server-side)
					- PlayHQ parameter in the FlashVars was added; when true (and there's HQ video link) - the HQ video starts automaticaly
					
				2.5.20100530
					- fixed bug in the ads' container, regarding the cuTicket and 3rd party
					- post-rolls are actually re-instated (in the CastupXMLParser as well)
					- fixed a bug which caused the main video the reload and re-play when the post-roll or first mid-roll finished loading,
					  when the pre-roll isn't loaded succesfully.
					- end-of-video window is scaleable to fit the stage size.  it also plays after embedable clips. 
					
				2.5.20100531
					- fixed and updated the StatsManagers
					
				2.5.20100601
					- in full screen, new comment button has a tool-tip
					- end-of-video items are centered-stage in full-screen
					
				2.5.20100602
					- removed the loading animation from the end-of-video (when video starts buffering right when it reaches the end)
					
				2.5.20100603
					- fixed some more issues regarding the StatsManagers
					
				2.5.20100606
					- HBD Ayal!
					- added fail-safe to PlayHQ param - make sure the VideoLinkHQ is available when true
					- fixed end-of-video bug in full-screen (which resulted in not showing extra-clips' thumbs)
					
				2.5.20100607
					- more fixes to the StatsManagers reporting
					
				2.5.20100609
					- added 'VHQProtected' parameter: when true, autoPlay is ignored and turning lights off ==> canceled
					- when exiting full-screen, not calling 'MediAnd.toggleBanners' JS function, if lights are off
					
				2.5.20100610
					- in the ControlsBar, the 'onGotoFrame' updates the current item index according to the previous seek-point (to which 
					 the player will actually go to), not the requested time-code
				
				2.5.20100613
					- fixed the end-of-video look in small resolutions (mostly embeded-version)
					- in embeded version - sending SessionID as well to the stats, and sending 'PlayerStart' when player starts
					
				2.6.20100615
					- added new class 'Nana10PlayerData' to handle all the loading and handling of the data, instead of taking care of it in the Player itself
					
				2.6.20100616
					- moved some more code into the Nana10PlayerData
					- added class StillImage to handle loading the showing of the pre-play still image
					- AdsContainer is resized properly on switching to full-screen
					- added DownloadHQAppWindow class, which is used when users aren't allowed to watch HQ directly, without downloaing the app
					
				2.6.20100620
					- fixed 2 bugs relating to the closing of the DownloadHQAppWindow: when the 'download' button was clicked the window was hidden
					  but it remained modal; when clicking the 'close' button floating-comments were still paused
					- volume slider changes on mouse-wheel scroll (when opened)
					
				2.6.20100627
					- HBD Orly!
					- in the CommunicationLayer - sceneStartOffset setter makes sure the value isn't negative
					
				2.6.20100629
					- removed the 'debug=true' from the StatsManager
					- DownloadHQAppWindow is centered on full-screen as well
					
				2.7.20100811
					- ad's countdown counter doesn't appear in the ad strip any more - it appears in the controls
					- added 'extenal=1' when making data request on embeded players
					- ads' volume is reduced to 60%
					- in ads, 'NetStream.Play.Stop' status isn't always called - therefore using a timer to detect when the ad ends
		
				2.7.20100819
					- ads' volume is recued to 50%
				
				2.7.20100823
					- fixed an issue with the end-of-ad's timer (set the delta to 0.25sec instead of 0.1) 
				
				2.7.20100825
					- displaying the banner also in embed-mode, but removing the redundant buttons (lights and chapters)
					- when sending stats, also passing 'Embedded=true/false'
					- also added to the stats 'urlRequest.contentType = "application/x-www-form-urlencoded";', so it wouldn't fail in FF when embedded in FB
		
				2.7.20100828
					- changed layer order in the controls, so that the banner is below buttons
					- changed the font of the comments' control buttons to Arial (was helvetica)
					- removed the MediAnd logo and stats (ServerFunctions.setError)
			
				2.7.20100831
					- in the AdStrip - changed the font to Device Font - otherwise the text isn't displayed
					- in the 3 seconds before an ad begins - seeking isn't possible (added the 'enableSeek' to the CommunicationLayer class)
		
				2.7.20100901
					- removed MediAnd credit from the right-click menu
					- before loading the banner - checking if its not empty
		
				2.7.20100905
					- progress bar is expanded on mouse interation, and reduced when there's none (playhead hidden)
					- full-screen toggle button always enabled, even when 'allowFullscreen=fasle'; in such case - first time the button is clicked
					  the action is caught, and the button is disabled
		
				2.7.20100907
					- progress bar is more expanded on mouse interaction, and also improved the placement of the timer's tool-tip
					- in standart comments - time is displayed again (changed the font from helvetica to Arial)
		
				2.7.20100912
					- added support for Hiro's ads system
		
				2.7.20100913
					- added 'communicationLayer.enableSeek = true;' to the onVideoDataReady function, so that the seek would work in videos without preroll
		
				2.7.20100916
					- fixed text issues with the end-of-video (text was displyed in reverse)
		
				2.7.20100927
					- fixed a bug where a clip that displays from its beginning but not till its end - was fully displayed anyhow
					  (added an 'else' in the 'onDataReady function in the Nana10PlayerData class)
					- in the embeded version - buttons are now placed correctly when switching to full-screen and back
		
				2.7.20101012
					- extended support to the Hiro wrapper: ignoring 'dummy_ads' and reporting 'reportViewedAd' to the wrapper.
		
				2.7.20101013
					- 'CM8Target' is read from shared-data
					- in the 'onSharedVideoDataReady' in the Nana10Player, first condition was fixed
		
				2.7.20101017
					- removing from the data-repository breaks' candidates which weren't matched by actual break locations set by Hiro
					- sending Hiro wrapper statistic data about user (when available)
		
				2.7.20101018
					- opening form's SharedObject's data is flushed when form's button is clicked
					- added more traces to detect stucking errors
		
				2.7.20101019
					- fixed bug which caused player to get stuck after pre-roll 
		  		   	 (added 'videoPlayer.pausedAtStart = false;' at 'onAdEnded')
			
				2.7.20101110
					- the timeline, when not-active (ie - during ad-breaks and before it loads) is always minimized.  only when active it can be
					  maximized (and minimized again when there's no user interaction).  that way, there's no gap between the timeline and controls-bar
		   			  before the movie loads
		
				2.7.20101111
					- added support for FlashVar 'HiroTarget'
					- fixed embeding data in the share-pannel (added 'allowfullscreen and fixed the height)
					- when seding data to the Hiro wrapper - not sending the pre-roll
		
				2.7.20101114
					- added for each major function a 'printFunctionName' command, to detect video-stucking bug
		
				2.7.20101115
					- fixed a bug in calling the 'Debugging.disableFirebugOnline' function
					- apparently 'Error.getStackInfo' works only in debug player version, which means the 'printFunctionName' had to be disaled
		
				2.7.20101122
					- HiroDataLoader sends to the plugin the VideoID instead of the movie url
		
				2.7.20101124
					- when preloading Hiro ads - also updating the 'adUrl'
		
				2.7.20101202
					- setting the stage' frame-rate to be as the video's frame-rate
					- enhanced the 'checkVideoBegan' function, to double check video isn't stuck after pre-roll.  hopefully this will do it
		
				2.7.20101207
					- when flashVars include HiroWrapper, it is used only sometimes - depending on HiroRatio (50% if NaN)
		
				2.7.20101216
					- when reporting 'PlayerStart' also sending player's type
				
				3.0.20110103
					MAJOR CHANGES:
					- not working with DataRepository anymore, but with Nana10DataRepository, meaning there are no more keyframes.
					  every item has a timeCode property by which it is displayed.  using only new Nana10 items types.
					- all sorts of duration and offset properties that were scattered throughout the classes are now concentrated 
					  in the CommunicationLayer class.
					- the main video isn't loaded on start only to recieve its meta-data and play the preroll afterwards, but in case 
					  of a preroll, the main movie's loading begins only when the preroll is done loading
					- supporting 'black-holes' meaning if there's a gap between the segments the playhead skips that gap (and also if 
					  the user drags the playhead of uses the arrows to fwd/rwd, those black-holes are taken into account.
		
				3.0.20110104
					HBD!
					- fixed volume issue of the preroll, so its volume is initialized correctly
		
				3.0.20110105
					- the black-holes functionality is also implied in the 'ChapterTitle' class
					- also when jumping to a chapter, making sure that chapter is set as the current item in the controls bar
					- imporved statistics reporting, mainly regarding movie play/pause and play/pause click
		
				3.0.20110106
					- restored support for automatic mid-rolls (in case the meta-data doesn't include any)
		
				3.0.20110109
					- on small players (width<448), when not used the HQ and chapters buttons are removed
					- on the controls bar, the timer's widht (and the volume control's x respectively) changes according to the movie's length, 
					  thus having more space for the buttons on narrow display
					- in full screen mode, controls bar is correctly vertically aligned when hiding and revealing it
		
				3.0.20100110
					- if a video begins with an offset - when the video is ready (after the pre-roll) waiting for a period of the offest and only then starting to play
					- improved the opening form display functionality - either getting the data from flash vars or shared object.  
		              if not getting the data - displaying the form (unless user asked to skip if, for a week)
		
				3.0.20110111
					- before video's source is set its muted, so there won't be a short berst of sound before the offset or if the video was muted by the user earlier
					- when using Hiro plug-in, calling it twice: once before the preroll (to get the preroll's data), and a second time after the video's data is ready,
		              and the list of midrolls is ready and updated.
		
				3.0.20110113
					- players' (main + ads) volume is set in the Nana10Player class, and not in the volume controls class (thus it set from beginning)
					- after skipping a black-hole - if there's an offset (playhead isn't exactly at the desired location), hiding and muting the video till it reaches the desired location
		
				3.0.20110116
					- supports gmpl.asxp for VideoLinkHQ
		
				3.0.20110117
					- when using hiro and the ad is clicked - sending report to reportClickedAd function
		
				3.0.20110118
					- in the opening form, not using ExternalInterface.call in embeded player
					- still image in embeded player is resized correctly
		
				3.0.20110119
					- fixed bug in the hiro data loader - short clips (less than 7 mins) caused the 'hasPreroll' var to set to false too early
		
				3.0.20110125
					- updated UI of openning form
		
				3.0.20110227
					- opening form is displayed only if SWF is large enough
					- added QPay functionality
		
				3.0.20110220
					- fixed some issues with automatic hq playing (hopefully didn't cause any others, 
					  mostly at 'onLoadVideo' and 'onHQDataReady')
		
				3.0.20110221
					- fixed bugs regarding the display of the opening form
					- added support for permanent postrol
					- fixed issues with the display of the buttons on the controls bar, so there are no gaps between them
		
				3.0.20110222
					- when displaying survivor content (serviceid=249) the qpay banner and message are displayed without 'cellcom' support
		
				3.0.20110302
					- in the 'onVideoDataReady' function, checking if the offset is more than 1, not 0
					- also in the same function - when preloading the video during preroll, not checking if the ads' container
					- is playing (in case the user paused it) but if its visible
		
				3.0.20110303
					- fixed a bug concerning a single bookmark video longer than 7 minuts, thus its gmpl included 4 entries: 
					  preroll, main entry, midroll and last entry.  adding the 'video-end' marker according to the main entry
					- imporved the offset delay before a video start
		
				3.0.20110306
					- added default comment as the video begins
		
				3.0.20110308
					- qpay banner is removed after 7 seconds
					- floating comments are slower and without ease-out
		
				3.1.20110315
					- added support to live streaming rtmp
					- when there's no autoplay - qpay banner is displayed only at the bottom of the screen, not in the middle
					- fixed few bugs concerning black-holes - not done yet
					- began adding support to nana10 tagger's meta-done. not complete yet.
		
				3.1.20110317
					- resotred post-roll (needs more QA!!!)
					- eliminated reporting on non-clickable ads
				
				3.1.20110320
					- fixed a bug concerning the postroll (in case there's a 'startTime' the postroll was displyaed too early)
					- added output for download rate
					- fixed a bug concerning the postroll (in case preloading it 30 secs ahead)
		
				3.1.20110321
					- on slow connections, the 'onVideoStatus' function in the MediandVideoPlayer isn't called.  this function
					  includes a 'video.visible = true', thus in such cases the video is only heard.  so commencted out the 
					  'video.visible = false' in the 'source' setter function
		
				3.1.20110322
					- another bug fixed concerning the post-rolls: not sending to the hiro plug-in the timing of the postroll, otherwise
		 			  one will be displayed when using hiro
		
				3.1.20110328
					- fixed all sorts of bugs, mainly regarding black-holes and post-rolls
					- added more support to nana10 tagger's meta-data
		
				3.1.20110403
					- added support to HQ over nana10 tagger's meta-data (and improved dealing with HQ over cast-up meta-data)
		
				3.2.20110413
					- added bug reporting functionality
					- added support for hiro's ads, where click-url is set only after the user clicks the ad
					- added support for over-lay ad when video is paused
					- all other content without postroll don't display pre-ad message and error message after postrol failed loading
		
				3.2.20110428
					- WS functions' path was changed
					- added support for preview from the tagger
					- added support to block stats reporting of certain stats.
					- default comment is displayed only for videos longer than 5mins
		
				3.2.20110502
					- when there's error loading ad - updating stats and sendimg mail to support
		
				3.2.20110504
					- automatic midrolls are set every 6 minutes
					- floating comments are tweened faster (10-14 seconds, instead of 15-21 seconds)
		
				3.2.20110505
					- overlay ads are clickable, and removed from stage when non-visible
		
				3.2.20110509
					- added support for 'KeepAlive' stats event using the WatchedVideoData static class
					- overlay ads should be only AS3 clips, maksed, with a transparent MC name 'stage_mc', at (0;0) with dimensions matching to the banner's stage
		
				3.2.20110511
					- hiro's playlist isn't loaded from the 'onVideoDataReady' (for cases it isn't called) but from the 'checkVideoReady' function
					- fixed a bug concerning 'KeepAlive' with black-holes (timing wasn't correct)
		
				3.2.20110512
					- overlay ads are swapped with the controls (while visible) so they won't obscure the control bar
					- when overlay is visible - the screen cover is visible as well
		
					- reporting to hiro when overlay is displayed
					- added user interaction to the debugger
		
				3.2.20110519
					- static overlays (non-swf) are centered on stage and made clickable.
		
				3.2.20110522
					- cleared and upgraded all the 'firebug' reporting
					- since the 'onVideoDataReady' isn't always called after video begins playing, added calls to 'adsVideoPlayer.addPreAds()'
					  & 'dataRepository.sortOnTimeCode()' in the 'checkVideoBegan' funtion 
		
				3.2.20110525
					- updated the opening (targeting) form with new age groups
		
				3.2.20110530
					- updated the look & feel of the floating commnets
					- if main video's fps is less than 12 - don't change the player frame rate
					- sending to the hiro plug-in list of tags as well
					- changed shared object 'of' (opening form) to 'ud' (user demographics), after updaing the new age groups
		
				3.2.20110531
					- fixed wrong radio button value in the opening form
		
				3.2.20110601
					- sending to the stats the player's version as well (in the info)
					- // clips with start-offset are delayed not for the length of the offset, but for 1.3 seconds --> commented out
					- overlay banner is centered when switching to full screen
		
				3.2.20110602
					- in case the KeepAlive stat event sends duration of 0, sending instead the playhead time.
					  should find out why this happens.
		
				3.2.20110606
					- HBD Ayal!
					- WatchedVideoData: removed error reporting, sending mili-secs, and sending only if value is different from previous one
		
				3.2.20110615
					- added ability to detect containing html page's url. --> update: works via ExternalInterface, which fails due to Sandbox violation. currently disabled
		
				3.2.20110619
					- added support to Google's AdSense
		
				3.2.20110621
					- Google's AdSense is temporarilly dissabled, untill approved by Google
					- added support for removed-content slide (when cast-up is sending '90103a_en.wmv'/'90101a_en.wmv' for the video file)
		
				3.2.20110703
					- bug reporst are not sent automatically anymore - only when user chooses to
					- the 'KeepAlive' event in the stats manager also sends (when available) the cateroyID, sectionID, articleID & serviceID
		
				3.2.20110704
					- fixed bug in yesterday's StatsManager update
					- in embedded player - when data is loaded updating the StatsManager with the session id (otherwise the stats won't make it into the DB)
		
				3.2.20110705
					- when displaying removed content, updating the stats with an 'Expired' (#49) event
					- Google's Adsense approved an re-instated
					- added try..catch to every 'SharedObject.getlocal
		
				3.2.20110707
					- Adsense are displayed only on nana (not MSN), using new flashVar - PartnerID, and their height was reduced by 17px
		
				3.2.20110713
					- added support for not-prepared ads from Hiro (for VAST tag)	
		
				3.2.20110714
					- after video is done and re-playing it - it's proceeded by a preroll
		
				3.2.20110718
					- in the StatsManager MoviePosition is sent as int (instead of Number)
		
				3.2.20110720
					- added support for castup's live stream (which required different approach for pausing the live stream)
		
				3.2.20110725
					- fixed the 'keep-alive' report for live streaming
					- when available, reporting UniqueGUID to Stats
		
				3.2.20110727
					- for testing purposes - reporting ads' loading time to statistics
		
				3.2.20110803
					- fixed bug regarding display of Google's adSense in full-screen
					- on live stream - checking for link change every 20 seconds (not complete yet - decide what to do on player-type change)
		
				3.2.20110804
					- avoiding using almost endless AdError report by comparing the MoviePosition.  this doesn't actually solve the problem
		
				3.2.20110807
					- fixed CheckVideoLinkChange to check if the link itself was actually changed.  added support for 'hold/resume'
					- restored support for post-rolls
					- opening form is displayed for 20 seconds and then removed
		
				3.2.20110815
					- modifications to support nana-kids player
					- first keep-alive event also sends 'videotime' (clip's total duration)
					- live stream player doesn't display the HQ and chapters button
					- live stream player ignores the 'hasPreroll' and checks only 'showAds'
					- keep-alive and player-start event also send PartnerID
		
				3.2.20110817
					- fixed bug when pausing the preroll in live stream
		
				3.2.20110821
					- stats are also reporting IsLive
					- live stream plays loading animation when buffering
		
				3.2.20110822
					- stats also report SectionsIDs
		
				3.2.20110824
					- on 'checkVideoBegan' - going-to-frame only if buffer is full
					- supports gm.asp for videoLink in live stream
					- fixed bug which caused live stream without preroll to be muted by default
					- fixed bug which caused the 'UnPublishNotify' event in the live stream to be dispathced 
					  more than once on the same video file
		
				3.2.20110825
					- in live stream when working with gm.asp - setting communicationLayer.hasPreroll manually
					- using CheckVideoLinkChange only if flash-var's CheckForLinkChange = 1
					- added new stats events - DataLoadTime, DataLoadingTimeout, BugReport,VideoInitLoadTime - SERVER SIDE IS READY ONLY IN DEV!!
		
				3.2.20110828
					- CheckForLinkChange calls ExternalInterface when player's type is changed to WMV
		
				3.2.20110829
					- added more stats event for debugging mainly
		
				3.2.20110831
					- added support for hiro's overlay (at the bottom part of the player)
		
				3.3.20110905
					- when loading initial data and getting timeout evnet - trying (at least) 2 more times before giving up
		
				3.3.20110906
					- overlay is displayed 15 seconds after preroll (instead of 7.5)
		
				3.3.20110908
					- opening form - if closed - is displayed every 5 times (instead of once a week)
					- if midroll is skipped - its played afterwards
					- once midroll is played - its removed from the DataRepository (so if user returns to that point - no midroll will be displayed)
					- when the video ends - a new end-of-video display is presented for 3 seconds only.  it displays name and image of the next video and then plays it
		
				3.3.20110911
					- ads' volume reduced to 20%.  its control is done from within the AdsContainer.
					- making sure pre-rolls are only reported once
		
				3.3.20110913
					- when playing CMS's video (not from castup) also reporting FolderID to stats
					- added new event - Hiro-Load-time when loading preroll from Hiro's plug-in
					- in 'CheckVideoBegan' - making sure the playhead is at least 0.4sec after the 'postPrerollVideoTime'
		
				3.3.20110915
					- after midroll - main video goes back 5 seconds
					- midroll are played every 5 minutes (and added only if video is longer than 5:30)
					- when preparing the pre-ads' markers - making sure the ads' preloaders aren't placed inside 'black-holes'
					- changed AdStrip's visuals and made if flash when displayed. waiting for sound fx.
		
				3.2.20110918
					- before calling the 'getPreroll' in the HiroDataLoader - making sure the SharedObject is available
					- added Timeout (10 seconds) to the getPreoll/Midroll in the HiroDataLoader
		
				3.2.20110922
					- fixed a bug which stretched the video when toggled LQ/HQ in full screen
					- if bug reporting window is opened in full screen - player is set back to normal
					- fixed a bug which caused google's ad-sense to be missplaced if going to full screen before ad is displayed
		
				3.2.20110925
					- making sure there are no midroll les than 30 seconds before the video ends
					- showing google's graphical ad-sense in players wider than 468
		
				3.2.20110928
					- in preview mode - adding image snapping functionality
		
				3.2.20111003
					- when midroll is skipped - its played only if its less than 5 mins from the skipped-to timecode
					- new 'global' var in the communication layer - minutes-between-midrolls
					- every reference to 'הערה' in the comments' UI was changed to 'תגובה'
		
				3.2.20111024
					- code clean-up
					- removed the 'talker' button from the share window
					- in live stream - in the 'startPlayingVideo' checking that the stream is ready - otherwise loading the next stream on the list
		
				3.2.20111025
					- when receiving dummy-ad from hiro - removing the ad's from the data-repository
					- fixed a bug in case of a data error in embedded player
		
				3.2.20111026
					- in live stream - when getting a 'UnpublishNotify' message  - trying to load from the next URL
		
				3.3.20111027
					- when getting an 'upbulishNotiry' in live stream - reporting to the stats DB
					- simplified video-load-failures events: the MediAndVideoPlayer dispathces the event, the Nana10Player asks for the next video
					  URL from the PlayerData (which returns a relevant URL accoding to the current scenario), and then the Player updates the video's source
		
				3.3.20111115
					- added support for CM8 plugin
					- ad's loading is done using constants in the CommunicationLayer
					- when a video is buffering more than 5 times - its being loaded from a different server
		
				3.3.20111117
					- fixed bug regarding CM8 Plugin
		
				3.3.20111120
					- fixed more CM8 Plugin bugs: added support for ERROR event, controls are disabled using the DIBABLE_CONTROLS event
		
				3.3.20111122
					- fixed bugs regarding the comments display (and their buttons) caused by the CM8 pluging
		
				3.3.20111127
					- added timeout for the CM8 work plan's loading
					- ad strip's message is horizontaly aligned correctly
					- added support for CM8' overlay (while removing google's ad sense overlay)
			
				3.3.20111128
					- fixed bug regarding the timing of custom ads' breaks on a video with black holes when using CM8 plugin
					- added support for embed mode of CMS-videos (not castup)
					- in the embed code - also sending the HiroRatio param
		
				3.3.20111129
					- in category 500485 & 500487, when the video ends not moving to the next video
					- at the end of video - loading the playlist, and without reloading it each time playing them one after the other
		
				3.3.20111204
					- the 'onSwitchToAlternativeVideo' function in the Nana10Player now accepts a VideoPlayerEvent, thus enabling video switch in live stream
		
				3.3.20111205
					- added support for live stream via CMS (not cast up)
		
				3.3.20111207
					- in the Nana10Player.onDataError - no need to call the 'prepareData' on each attempt - calling the 'makeDataRequest' directly
					- after each data load failure - the timeout becomes longer
		
				3.3.20111211
					- when changing display state - notifying the VideoPosition so CM8's overlay is displayed properly in full-screen mode
		
				3.3.20111212
					- StatsManager is also sending the Browser Version
		
				3.3.20111213
					- the CM8PluginDelegate stops the time-out timer when being notified about an error
					- getting the browser's details in the bug reporting and stats-mananger using custom JS function
		
				3.3.20111221
					- in live stream, if the stream resumes after it stopped - remove the 'sendReport' window
					- added more specifications for the melingo's content (use CM8's echospere, avoid clicking on the player 
		
				3.3.20111222
					- added support for live stream (CMS-generated) backup id, which the player switch to in case of a failure --> removed it on 11/1/12, since its logic is going to change.
					  not supported yet from server side and not tested yet
					- in 'onSharedVideoDataReady' updatng the related-sections, category, section and article ID's
		
				3.3.20111125
					- fixed major bug in the bug reporting
		
				3.3.20111129
					- CM8Delegate doesn't report progress in live stream when paused
					- changed the support for live-stream backup, so when live stream fails, if the backup stream is WMV - the player calls the JS switch function
		
				3.3.20120101
					- HNY!
					- when playing melingo's embedded player, accepting CSV for VideoID, and choosing which to play according to the current time
		
				3.3.20120102
					- added support for CM8's ads invoking and revoking (used when video is paused)
					- fixed some bugs regarding the timer display, screwed by CM8 plugin un-expected behaviours
		
				3.3.20120104
					- HBD!!!
					- in live stream - when fails (and showing 'bug report' window) and restarts - removing the ads' strip and bug reporting
		
				3.3.20120105
					- when reseting the StatsManagers - also setting the 'firstKeepAlive' to true (otherwise the 'movieTime' isn't sent when going to the next video)
					- changed the workflow with the CM8 plugin so it loads the workplan only after user clicks 'play' (or there's an autoplay)
		
				3.4.20120115
					- added video initial load's timeout, set to 10sec.  when failing - switching to the next video on the list, unless there's none - 
					  in that case trying to reload the same video, but with a longer timeout 
					- changed the workflow with the CM8 plugin again, so the workplan is loaded right after the video's metadata is ready, 
					  but the 'videoStart' event is dispatched only after the user clicks 'play' (or there's an autoplay)
					- in the MediandVideoPlayer - when setting a new source disposing the net-stream and sound-transform objects -->> revoked it
		
				3.4.20120122
					- restored support for live stream backup, this time the backup id is generated not from the FlashVars, but from the 'getData' WS
		
				3.4.20120131
					- in case of a video laod error during CM8's preroll - the error message is displayed only afterwards
		
				3.4.20120202
					- added ability to set the clip's server from the queyr string, for testing purposes
		
				3.4.20120209
					- when switching to HQ after seek - sending the right time in the request
					- when sending a video-load event, passing also the video start point 
					- added HQDataLoader, which also supports time-out
		
				3.4.20120219
					- when openning form is displayed, filled or ignored - reporting stats.  in case of 'form filled' - also sending the data
					- in the 'onSeekComplete' function, before calling 'onSegmentSeekDelay' making also sure its not during ad's break
					- embeding is blocked in live-stream
		
				3.5.20120220
					- moved most of the 'checkVideoLink' and 'onDataError' into the Nana10PlayerData class
					- in the StatsManager, added a boolean-array of AuditEvent for each event, so the SP would know in which table to place the data
		
				3.5.20120226
					- when clip begins - calling JS function 'reportVideoPlay2Taboola'
		
				3.5.20120301
					- in live stream, when failing to load the gm.asp - trying again (up to 3 times)
		
				3.5.20120305
					- reporting stats for lights on/off as well
		
				3.5.20120306
					- in embeded player - displaying a large logo
		
				3.5.20120318
					- when resuming an ad - stats manager doesn't report it
		
				3.5.20120325
					- sending KeepAlive on 15sec, and every KeepAlive from that event onwards also sends 'MinimalView=true' (any KeepAlive prior to 15 sends 'false')
		
				3.5.20120327
					- added AsyncErrorEvent.ASYNC_ERROR event listener to the MediandVideoPlayer's NetStream object
					- when previewing (from the tagger) - 'showAds' isn't set to false, the CM8 delegate is disposed, and the video player isn't fully disposed
					- lights button is permanently dissabled
				
				3.5.20120403
					- all sort of improvments regarding the preview from the tagger
		
				3.5.20120418
					- in live stream (but only from it category) - checking for the existance of nana's toolbar by trying to connect another swf located there.
					  if not found - displaying a message with a link to the toolbar's installation page
					- if 'WNB=1' is in the URL's query string - not displaying ads, live-stream block and demographics form
				
				4.0.20120508
					- major UI changed - removed all but PlayPauseToggle, HDToggle, FullScreenToggle, embed widnow (from which the FB/TWTR buttons were removed), and progress-bar
					- ads are displayed only using CM8 - removed all code regarding display of Hiro ads (especially removed the AdsContainer from the main class)
					- comments aren't used any more - removed all code concerning them (together with the video-display minimizing functionality)
					- getDataShared' WS: seding params only if they're undefined; sending PartnerID as well
					- onSeekCompltere, checks for a delta between desired time code and actuall time code using the VideoPlayer's getRelativePrevSeekPoint 
					 (for cases where the playhead wasn't updated yet when the buffer-full event was fired)
		
				4.0.20120509
					- when switching to full screen in live stream - buffer bar is stretched
					- when switching to full screen during ad - the ratio is updated correctly
					- when rolling out the stage (after first play/auto-play) - the conrtols disappear
					- controls are hidden after no cursor movement only after 7sec
					- in live stream - share buttons are hidden
					- when EnableEmbed=0 - share button is dissabled
		
				4.0.20120513
					- when video begins playing - sending all its data (flashVars + player's info) via JS function 'reportVideoWatched'
					- during ads - the controls' progress bar + tooltip are tweened
					- when switching to/from FS - progress bar, buffer bar and tooltip are placed correctly (without tweenning)
					- progress bar and buffer bar are limited to frame's width
		
				4.0.20120514
					- during ads - controls aren't hidden
					- after seek to an unloaded time-code, if ad begins playing before content is ready - not playing the content when it's ready
		
				4.0.20120515
					- after seek to an unloaded time-code, if ad begins playing before content is ready - not reseting the progress bar when the content is ready
					- after seek to an unloaded time-code, if the content isn't loaded (timeout/error) - re-loading from the correct time-code
					- on stage roll-over - making sure the evnet's target isn't the stage (for otherwise, the controls are accidently displayed)
					- when setting the progress bar's width, and the buffer is full - setting its width according to its x location
					- when the content begins playing - calling JS function 'reportVideoWatched' with all the properties of the video object and flashVars
					- controls bar's playFirstClick is set to 'true' only when no in auto-play	
					- in the 'doSeek' commneted out the 'pause', because the only effect it had was that after 2 consecutive seeks, the video was paused
		
				4.0.2120516
					- in the CM8Delegate - the isRunning property is set on ad_start/complete event, using the data's isLinear property 
					  (and not in the enable/disable controls, and thus when the controls are disabled but there's no preroll - that property remains 'false')
		
				4.0.20120517
					- when the video ends and there's no data regarding related videos - the control bar is automatically displayed
					- checking the existanse of Nana Toolbar not using local connection, but by calling JS function, and that only if 'checkForToolbar' in the FlashVars is '1'
					- when live stream fails - updating the DB only after all tries failed
		
				4.0.201210520
					- when calling 'onCM8EnableControls', making sure the video player's info-object is ready, thus knowing if the video has began loading
					- furthermore, when calling 'onCM8AdEnded' making sure the controls weren't started yet, so the 'startPlayingVideo' won't be called twice
					- 'removeFromStage' is now available via ExternalInterface using addCallback
		
				4.0.20120521
					- changed the initialization sequense, so when the demogarphics form is displayed in live stream in auto-play mode, it won't be visible when the content start runnig
					- when enabling the controls (after ad) - making sure its not live stream and the ad is not running (otherwise - and toggling ad in live stream
					  the content will start running when the ad is resumed)
		
				4.0.20120522
					- some graphical updates to the 'download toolbar' window + changed the URL and the target to _self		
		
				4.0.20120524
					- in the data repository, when sorting items - making sure that ads that are place next to segment's edge - are inside the segment and not in a black hole
					- checking for Nana10 toolbar is not performed when running on MAC
					- the 'download' button in the DownloadToolbarMessage is linked directly to the download iFrame (depending on the browser) 
					- when reseting the controls bar (in 'resetTimer') reseting 'movieStarted' as well
		
				4.0.20120525
					- live stream is clickable
		
				4.0.20120528
					- detection of block-content for overseas viewers is done in the 'onMetaDataReady' using the video file's URL
					- in live steam, dispatching to the CM8 plugin current time of 1
		
				4.0.20120530
					- when switching to alternative video (untill its loaded) - displaying the loading animation (and hiding it on videoStart)
		
				4.0.20120531
					- controls are hidden during ads as well, but only after 5 secs of non-activity (unlike 7 during the content)
		
				4.0.20120604
					- disabled live stream clickability
		
				4.1.20120606
					- HBD Ayal!
					- made changes to 'CheckForLinkChange' so its now more reliable
					- made changes to the integration with the CM8Delegate, so the 'dispalyVideo' function is called reliablly - when there's no pre-roll, in live stream and autoplay
		
				4.1.20120610
					- checking for tool-bar (when 'checkForToolbar=1') only on windows
					- bottom banner container isn't clickable (stats are gathered from within the banner)
		
				4.1.20120612
					- made the conditon to check for the tool-bar more reliable
		
				4.1.20120618
					- all content is blocked for msn viewers (PID=54) if toolbar isn't installed
		
				4.1.20120619
					- changed the above so only live stream is blocked
		
				4.1.20120626
					- another automatic keepAlive event is reported after 45 sec (besides the one at 15 sec)
					- when loading tagger-data, making sure there's at least one items (relevant for cases of hidden items)
		
				4.1.20120627
					- HBD Orly!
					- sending to CM8's plugin the PlayerID (as recieved in the flash-vars)
					- added support to Gemius functionality
		
				4.1.20120701
					- made EndOfVideoDisplay more fail-proof reliable
					- changed path to default bottom banner
					- changed the name of the key in CM8's Video class which sends the PlayerID to Nana10PlayerID
					- update to the custom package parameters of the gemius delegate
		
				4.2.20120703
					- added 'http' to the HitCollector property of gemius delegate
					- automatic keepAlive reports are using class PauseTimer which enables pausing of a timer. not complete yet
					- added new stats events, began using monitor-events, and sending seperately the server name and loading time/speed
					- changed the gemius delegate so play is reported only when needed
					- the video player class itself now reports when the video has finished loading
		
				4.2.20120705
					- the timer in the video player class which checks if the video finished loading - is stopped upon a StreamNotFound event 
					- DataLoadTime and DataLoadingTimeout stats events are also reporting server name (either castup or nana10);
					- made the StatsManager more accurate for cases where evnets are waiting to be sent - the SessionTime and ServerName are 
					  set when the event was initially was supposed to be sent, and evnets are taken out of the array using 'shift' and not 'pop'
		
				4.2.20120708
					- fixed minor bug so when loading a new content, if the previous one was Nile generated and the current one tagger generated - changing the UseCastupXML to false
					- new stats event: VideoRequest
					- fixed the order of paramteres when calling 'sendData' from the StatsManager.onReady
		
				4.2.20120709
					- making sure the 'onVideoStart' is called only once for each video load 
		
				4.2.20120710
					- when holding the controls bar - not checking anymore if the adLength is less than 0, for its not being called on overlays
					- the cm8Placeholder now has hand-cursor when being rollover (either during linear ad or over an overlay)
		
				4.2.20120710
					- changed the BottomBarContainer & PlayerNavigationBar so it'll be displayed properly in embedded players
		
				4.2.20120712
					- BottomBarContainer sends CM8 data to the PlayerNavigationBar (which reads the data from CM8)
		
				4.2.20120715
					- added timeout to CM8 plugin loading
					- when downloading nana's toolbar, not checking user's browser, but redirecintg to the general download page itself
		
				4.2.20120716
					- HBD Mom!
					- added new class 'StatsDataObject' which holds all the data of a specific stats request
					- when reporting dataloaded/error/timeout - sending the correct server name (castup/nana)
					- in live stream and autoplay the controls are available only after the stream is available 
		
				4.2.20120719
					- enabled automatic bug reporting (sending the report without the user aware of it)
					- for cases where the video-link returned from the tagger contains 680 clips' refs (this happens sometimes for unkown reseaons), sending automatic bug report with extended data
					- removeFromStage functionality is added only afer all stage elements are set
					- CM8Delegate loading timeout set to 10sec (instead of 20)
		
				4.2.20120722
					- updated the URL of the eRate reporting
		
				4.2.20120724
					- added support for 2 consecutive prerolls by using a Dictionary object which connects each ad to its length by the ad's ID
					- moved the 'onCM8disableControls' functionality into onCM8AdBegan
					- added total-time tooltip (which fades out when the current time tooltip overlaps it)
					- extended the support for gemius: sending genere under gA and length under gACAT
		
				4.2.20120725
					- making sure the new total-time tooltip is placed correctly when switching to full screen
					- when the video stream has an error status - stopping the loading timer 
		
				4.2.20120731
					- making sure the total-time tooltip isn't displayed on live stream
					- making sure that the automatic keep-alive's at 15 and 45 sec aren't sent if the video isn't actually playing
					- added try-catch to all the interactions with the StreamManager in the GemiusDelegate (which overcomes errors thrown when player is embedded)
					- when adding a new Nana10EndSegmentData - making sure its status is set to 1
		
				4.2.20120807
					- added 2 new stats events: data failure and video failure.  both are sent when the 'send report' window is presented to the user
					- added 2 new stats events: content-init, when a new content (after the player loads or when the content is replaced when one ends) begins and video-init, when a video start for the first time
		
				4.2.20120812
					- ContentInit is sent when player initialize only on auto-play, otherwise when user clicks the play button (for the first time) or when there's a data error
					- added support for resume-content:  when user returns to a content which he left before its end (at least 2 minutes) - he's prompted to continue from last time-code or start from beginning
					- fixed bugs with the end-of-video display, so it's now more accurate and reliable
		
				4.2.20120815
					- resume-content pannel is displayed only for the first contnet; when it ends and the content switches, the pannel isn't displayed even if it applies
		
				4.2.20120821
					- bug reports without user's mail are sent from 'VideoPlayer@nana10.net.il'
					- resume content is aplicable for more-than 10 mins contents
					- live stream clicking is disabled on MAC, so its right-click isn't blocked
					- added support to zixi's live-streaming, for cases where castup's streaming fails
		
				4.2.20120827
					- if video is buffering for more than 20sec - switching to the next server
					- fixed bugs regarding loading of zixi's stream
					- added support for 'zixi' parameter in the query string
					- fixed bugs regarding removing from stage
					- _isPlaying in the MediandVideoPlayer is set also on live stream, so after the preroll the stream's volume is set correctly
		
				4.2.20120828
					- fixed bugs regarding check-for-link-change when switching to zixi's stream
					- when usings zixi's non-proxy link, adding 'user' param, comprised of the user's session-id (as found in a shared-object, after it was placed there in the first time) and a running index
		
				4.2.20120903
					- when trying to display hidden/removed content - displaying a proper message (instead of an error message + bug reporting)
					- making sure the still image isn't replaced after displaying an error message
					- if loading a still image while another one is still loading - unloading the first one
					- download toolbar button is linked directly to conduit's installer (and not nana10's installation wizard)
		
				4.2.20120904
					- blocking content outside of nana10's domain: either embded player of live stream or not-embedable content or (for iFrames) contnet outside of nana10's domain
		
				4.2.20120905
					- fixed blocking algorytem so preview from cms isn't blocked as well
		
				4.2.20120910
					- CM8's container isn't set to button-mode any more, since the plug-in takes care of it by itself
					- when checking for blocked content - looking at the top's href, not parent
		
				4.2.20120924
					- play/pause button is enabled only when the content (or preroll) actaully begins playing
		
				4.2.20121010
					- fixed bug which caused the play button not to be enabled when autoplay=0
		
				4.2.20121018
					- added support for live-stream ads breaks
		
				4.2.20121024
					- making sure the Gemius deletage report every video init only once
						
				4.2.20121107
					- for some reason, CM8 is sending 'enableControsl' after the video has ended.  so in those cases - don't letting it resuming the video
		
				4.2.20121113
					- when checking for blocked content - allowing viewing from remote.nana10.net.il (for previewing within the CMS outside of the office)
				
				4.2.20121114
					- added new genere (food) to gemius delegate
		
				4.2.20121118
					- when switching to Zixi's live stream, chaning also the DataRepository's video-link
					- disabled zixi's delegate functionality
		
				4.2.20121121
					- when live stream fails after going through all the available sources - reloading the gm.asp with sources from new servers
		
				4.2.20121205
					- in live stream, when an ads-break ends, listening to the 'AdBreakStop' cue-point, and terminating CM8's ads (except for the preroll)
		
				4.2.20121212
					- in live-stream, when reloading the gm.asp after all links failed - reseting the alternate-video-url-index in the Nana10PlayerData, and not reporting video-failure stats event
					- fixed a bug which in live-stream, where the stream failed and had to be replaced, cause the new stream to be muted.  the solution was to set the 'pauseAtStart' to true before the new stream was loaded
			*/
	}
}