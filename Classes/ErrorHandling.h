//
//  ErrorHandling.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.01.17.
//  Copyright 2010 A25. All rights reserved.
//

#import <Foundation/Foundation.h>

void showErrorMessage(NSString *title, NSString *text);
NSString * decodeError(NSInteger code);
