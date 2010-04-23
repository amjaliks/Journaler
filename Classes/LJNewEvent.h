//
//  LJNewEvent.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.02.24.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PostOptionsController.h"

@interface LJNewEvent : NSObject {
	NSString *journal;
	NSString *subject;
	NSString *event;
	PostSecurityLevel security;
	NSArray *selectedFriendGroups;
	NSString *picKeyword;
	NSArray *tags;
}

@property (nonatomic, retain) NSString *journal;
@property (nonatomic, retain) NSString *subject;
@property (nonatomic, retain) NSString *event;
@property (nonatomic) PostSecurityLevel security;
@property (nonatomic, retain) NSArray *selectedFriendGroups;
@property (nonatomic, retain) NSString *picKeyword;
@property (nonatomic, retain) NSArray *tags;

@end
