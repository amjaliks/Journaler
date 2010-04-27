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
	NSSet *tags;
	NSString *mood;
	NSString *music;
	NSString *location;
}

@property (nonatomic, retain) NSString *journal;
@property (nonatomic, retain) NSString *subject;
@property (nonatomic, retain) NSString *event;
@property (nonatomic) PostSecurityLevel security;
@property (nonatomic, retain) NSArray *selectedFriendGroups;
@property (nonatomic, retain) NSString *picKeyword;
@property (nonatomic, retain) NSSet *tags;
@property (nonatomic, retain) NSString *mood;
@property (nonatomic, retain) NSString *music;
@property (nonatomic, retain) NSString *location;

@end
