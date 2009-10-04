//
//  AccountViewController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.04.
//  Copyright 2009 A25. All rights reserved.
//

#import <UIKit/UIKit.h>


@class LJAccount;

@protocol AccountViewControllerDataSource;


@interface AccountViewController : UIViewController {
	UIWebView *webView;
	
	id<AccountViewControllerDataSource> dataSource;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet id<AccountViewControllerDataSource> dataSource;

@end


@protocol AccountViewControllerDataSource<NSObject>

@optional
	- (LJAccount *)selectedAccountForAccountViewController:(AccountViewController *)accountViewController;

@end;