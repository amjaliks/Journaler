//
//  PostEditorController.h
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.08.
//  Copyright 2009 A25. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol PostEditorControllerDelegate;

@interface PostEditorController : UITableViewController {
	UITableViewCell *subjectCell;
	UITableViewCell *textCell;
	
	UITextField *subjectField;
	UITextView *textField;
	
	id<PostEditorControllerDelegate> delegate;
}

@property (nonatomic, retain) IBOutlet UITableViewCell *subjectCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *textCell;

@property (nonatomic, retain) IBOutlet UITextField *subjectField;
@property (nonatomic, retain) IBOutlet UITextView *textField;

@property (nonatomic, retain) IBOutlet id<PostEditorControllerDelegate> delegate;

- (IBAction) cancel:(id)sender;
- (IBAction) post:(id)sender;

@end

@protocol PostEditorControllerDelegate<NSObject> 

@optional
- (void)postEditorControllerDidFinish:(PostEditorController *)controller;

@end
