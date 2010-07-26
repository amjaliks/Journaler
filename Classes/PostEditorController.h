//
//  PostEditorController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.08.
//  Copyright 2009 A25. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PostOptionsController.h"
#import "AccountProvider.h"

@class LJAccount;
@protocol PostEditorControllerDataSource, PostEditorControllerDelegate;

@interface PostEditorController : UITableViewController<UITextViewDelegate, UITextFieldDelegate, PostOptionsControllerDataSource, AccountProvider> {
	id<AccountProvider> accountProvider;
	
	IBOutlet UITableViewCell *subjectCell;
	IBOutlet UITableViewCell *textCell;
	
	IBOutlet UITextField *subjectField;
	IBOutlet UITextView *textField;
	
	IBOutlet UIBarButtonItem *postButton;
	IBOutlet UIBarButtonItem *doneButton;
	IBOutlet UIBarButtonItem *optionsButton;
	
	PostOptionsController *postOptionsController;
	
	IBOutlet id<PostEditorControllerDataSource> dataSource;
	IBOutlet id<PostEditorControllerDelegate> delegate;
	
	BOOL editing;
}

@property (nonatomic, assign) id<AccountProvider> accountProvider;

@property (nonatomic, retain) UITableViewCell *subjectCell;
@property (nonatomic, retain) UITableViewCell *textCell;

@property (nonatomic, retain) UITextField *subjectField;
@property (nonatomic, retain) UITextView *textField;

@property (nonatomic, retain) UIBarButtonItem *postButton;
@property (nonatomic, retain) UIBarButtonItem *doneButton;

// @property (readonly) PostOptionsController *postOptionsController;

@property (nonatomic, retain) id<PostEditorControllerDataSource> dataSource;
@property (nonatomic, retain) id<PostEditorControllerDelegate> delegate;

- (IBAction) post:(id)sender;
- (IBAction) done:(id)sender;
- (void)openOptions;

- (void)startPostEditing;
- (void)endPostEditing;

- (void)resizeTextView;

- (void)saveState;

@end


@protocol PostEditorControllerDataSource<NSObject> 

- (LJAccount *)selectedAccount;

@end


@protocol PostEditorControllerDelegate<NSObject> 

@optional
- (void)postEditorControllerDidFinish:(PostEditorController *)controller;

@end
