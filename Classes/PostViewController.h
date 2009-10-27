//
//  PostViewController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.13.
//  Copyright 2009 A25. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PostViewControllerDataSource;
@class Post, WebViewController, LJAccount;

@interface PostViewController : UIViewController <UIWebViewDelegate> {
	NSString *postTemplate;
	NSString *userIconPath;
	NSString *communityIconPath;
	
	NSString *imageIconReplace;
	NSString *videoIconReplace;
	
	UIView *waitView;
	UIWebView *lastWebView;
	
	WebViewController *webViewController;
	
	id<PostViewControllerDataSource> dataSource;
}

@property (nonatomic, retain) IBOutlet WebViewController *webViewController;

@property (nonatomic, retain) IBOutlet id<PostViewControllerDataSource> dataSource;

@property (nonatomic, retain) IBOutlet UIView *waitView;

- (IBAction) openWebView:(id)sender;
- (void) openInWebView:(NSString *)url;

@end


@protocol PostViewControllerDataSource<NSObject>;

- (Post *) selectEventForPostViewController:(PostViewController *)controller;
- (LJAccount *) selectedAccountForPostViewController:(PostViewController *)controller;

@end
