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

@interface PostViewController : UIViewController {
	UIWebView *webView;
	
	id<PostViewControllerDataSource> dataSource;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet id<PostViewControllerDataSource> dataSource;

@end

@protocol PostViewControllerDataSource<NSObject>;

- (Post *) selectEventForPostViewController:(PostViewController *)controller;

@end
