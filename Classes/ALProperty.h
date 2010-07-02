//
//  ALProperty.h
//  Appnlytics
//
//  Created by Aleksejs Mjaliks on 09.11.16.
//  Copyright 2009 A25. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ALProperty : NSObject <NSCoding> {
	NSString *name;
	id value;
	
	BOOL isSet;
	NSString *stringValue;
	NSSet *stringSet;
}

@property (readonly) NSString *name;
@property (readonly) id value;
@property (readonly) BOOL isSet;
@property (readonly) NSString *stringValue;
@property (readonly) NSSet *stringSet;

- (id)initWithName:(NSString *)name value:(id)value;
- (BOOL)isValueChanged:(ALProperty *)sentProperty;

@end
