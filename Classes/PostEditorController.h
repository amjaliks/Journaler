//
//  PostEditorController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.08.
//  Copyright 2009 A25. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PostOptionsController.h"

@class LJAccount;
@protocol PostEditorControllerDataSource, PostEditorControllerDelegate;

@interface PostEditorController : UITableViewController<UITextViewDelegate, UITextFieldDelegate, PostOptionsControllerDataSource> {
	LJAccount *account;
	
	UITableViewCell *subjectCell;
	UITableViewCell *textCell;
	
	UITextField *subjectField;
	UITextView *textField;
	
	UIBarButtonItem *postButton;
	UIBarButtonItem *doneButton;
	UIBarButtonItem *optionsButton;
	
	PostOptionsController *postOptionsController;
	
	id<PostEditorControllerDataSource> dataSource;
	id<PostEditorControllerDelegate> delegate;
	
	BOOL editing;
}

@property (nonatomic, retain) IBOutlet UITableViewCell *subjectCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *textCell;

@property (nonatomic, retain) IBOutlet UITextField *subjectField;
@property (nonatomic, retain) IBOutlet UITextView *textField;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *postButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;

@property (readonly) PostOptionsController *postOptionsController;

@property (nonatomic, retain) IBOutlet id<PostEditorControllerDataSource> dataSource;
@property (nonatomic, retain) IBOutlet id<PostEditorControllerDelegate> delegate;

- (id)initWithAccount:(LJAccount *)account;

- (IBAction) post:(id)sender;
- (IBAction) done:(id)sender;
- (void)openOptions;

- (void)startPostEditing;
- (void)endPostEditing;

- (void)resizeTextView;
- (BOOL)isLandscape;

- (void)saveState;

@end


@protocol PostEditorControllerDataSource<NSObject> 

- (LJAccount *)selectedAccount;

@end


@protocol PostEditorControllerDelegate<NSObject> 

@optional
- (void)postEditorControllerDidFinish:(PostEditorController *)controller;

@end
