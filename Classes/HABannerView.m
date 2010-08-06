//
//  HABannerView.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.08.06.
//  Copyright 2010 A25. All rights reserved.
//

#import "HABannerView.h"


@implementation HABannerView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    [super dealloc];
}

- (BOOL)isBannerLoaded {
	return NO;
}


@end
