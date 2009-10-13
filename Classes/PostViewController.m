//
//  PostViewController.m
//  Journaler
//
//  Created by Aleksejs Mjaliks on 09.10.13.
//  Copyright 2009 A25. All rights reserved.
//

#import "PostViewController.h"
#import "LiveJournal.h"

@implementation PostViewController

@synthesize webView;

@synthesize dataSource;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)viewWillAppear:(BOOL)animated {
	LJEvent *event = [dataSource selectEventForPostViewController:self];
	NSString *path = [[NSBundle mainBundle] pathForResource:@"back" ofType:@"png"];
	path = [path stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
	
	NSLog(path);
	
	NSString *template = @"<style>* {font-family: Helvetica} h1 {font-size: 15px}</style><h1>%@</h1>%@";
	
	[webView loadHTMLString:[NSString stringWithFormat:template, event.subject, event.eventView] baseURL:nil];
	//[webView loadHTMLString:[NSString stringWithFormat:@"<img src=\"file://%@\" />", path] baseURL:nil];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
