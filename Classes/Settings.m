//
//  SettingsManager.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 10.01.18.
//  Copyright 2010 A25. All rights reserved.
//

#import "Settings.h"


void registerUserDefaults() {
	NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
								 [NSNumber numberWithBool:YES], kSettingsRefreshOnStart,
								 kStartUpScreenLastView, kSettingsStartUpScreen,
								 nil];
	[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];	
}
