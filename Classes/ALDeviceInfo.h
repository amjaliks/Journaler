//
//  ALDeviceInfo.h
//  Appnlytics
//
//  Created by Aleksejs Mjaliks on 09.11.02.
//  Copyright 2009 A25. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ALDeviceInfo : NSObject {
	NSString *UDID;
	NSString *type;
	NSString *osVersion;
	NSString *uiLang;
	NSString *appVersion;
	BOOL cracked;
}

@property (readonly) NSString *UDID;
@property (readonly) NSString *type;
@property (readonly) NSString *osVersion;
@property (readonly) NSString *uiLang;
@property (readonly) NSString *appVersion;
@property (readonly) BOOL cracked;

- (NSString *)hardwareModel;

@end
