//
//  PostViewController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.13.
//  Copyright 2009 A25. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PostViewControllerDataSource;
@class Post;

@interface PostViewController : UIViewController <UIWebViewDelegate> {
	UIWebView *webView;
	
	NSString *postTemplate;
	NSString *userIconPath;
	NSString *communityIconPath;
	
	id<PostViewControllerDataSource> dataSource;
}

@property (nonatomic, retain) IBOutlet id<PostViewControllerDataSource> dataSource;

@property (nonatomic, retain) IBOutlet UIView *waitView;

@end

@protocol PostViewControllerDataSource<NSObject>;

- (Post *) selectEventForPostViewController:(PostViewController *)controller;

@end
