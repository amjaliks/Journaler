//
//  PostViewController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.13.
//  Copyright 2009 A25. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PostViewControllerDataSource;
@class Post, LJAccount;

@interface PostViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate> {
	LJAccount *account;
	Post *post;
	
	NSString *postTemplate;
	NSString *userIconPath;
	NSString *communityIconPath;
	
	NSString *imageIconReplace;
	NSString *videoIconReplace;
	NSString *lockIconReplace;
	
	UIWebView *webView;
}

- (id)initWithPost:(Post *)post account:(LJAccount *)account;
- (void)openComments;
- (void)showAction;
- (void)commentPost;

@end

