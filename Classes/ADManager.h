//
//  ADManager.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.07.13.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <iAd/iAd.h>

@interface ADManager : NSObject <ADBannerViewDelegate, UINavigationControllerDelegate> {
	UINavigationController *navigationController;
	
	id bannerView;
}

- (id)initWithNavigationController:(UINavigationController *)navigationController;
- (void)createAdView;

@end
