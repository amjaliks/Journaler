//
//  PostViewController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.13.
//  Copyright 2009 A25. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Post, LJAccount, LJFriendsPageController;

@interface PostViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate> {
	IBOutlet LJFriendsPageController *friendsPageController;
	IBOutlet UIWebView *webView;
	IBOutlet UISegmentedControl *navigationControl;
	IBOutlet UIBarButtonItem *navigationControlItem;
	
	IBOutlet UIBarButtonItem *commentItem;
	IBOutlet UIBarButtonItem *flexItem;
	IBOutlet UIBarButtonItem *actionItem;
	
	Post *post;
	
	NSString *postTemplate;
	NSString *userIconPath;
	NSString *communityIconPath;
	
	NSString *imageIconReplace;
	NSString *videoIconReplace;
	NSString *lockIconReplace;
	
}

- (IBAction)showAction;
- (IBAction)commentPost;
- (IBAction)navigationChanged:(id)sender;

- (void)loadPost;

@end

