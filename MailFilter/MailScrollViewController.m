//
//  MailScrollViewController.m
//  MailFilter
//
//  Created by Moe Burney on 2012-11-25.
//  Copyright (c) 2012 Dev70. All rights reserved.
//

#import "MailScrollViewController.h"
#import "ImapSync.h"
#import "Message.h"

@interface MailScrollViewController ()

@property (assign) BOOL pageControlUsed;
@property (assign) NSUInteger page;
@property (assign) BOOL rotating;
- (void)loadScrollViewWithPage:(int)page;
- (void)populateChildViewControllers:(NSMutableArray *)data;
- (void)populateView:(int)page:(NSMutableArray *)data;

@end

@implementation MailScrollViewController

@synthesize scrollView;
@synthesize pageControl;
@synthesize pageControlUsed = _pageControlUsed;
@synthesize page = _page;
@synthesize rotating = _rotating;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 200)];
    
    // Init Scroll View Programatically
	[self.scrollView setPagingEnabled:YES];
	[self.scrollView setScrollEnabled:YES];
	[self.scrollView setShowsHorizontalScrollIndicator:NO];
	[self.scrollView setShowsVerticalScrollIndicator:NO];
	[self.scrollView setDelegate:self];
    [self.view addSubview:self.scrollView];

    
    // Init Page Control Programatically
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.frame = CGRectMake(110,200,100,100);
    [self.pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    //self.pageControl.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.pageControl];
    
}

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers {
	return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	UIViewController *viewController = [self.childViewControllers objectAtIndex:self.pageControl.currentPage];
	[viewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	_rotating = YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
	UIViewController *viewController = [self.childViewControllers objectAtIndex:self.pageControl.currentPage];
	[viewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
	self.scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * [self.childViewControllers count], scrollView.frame.size.height);
    NSUInteger page = 0;
	for (viewController in self.childViewControllers) {
		CGRect frame = self.scrollView.frame;
		frame.origin.x = frame.size.width * page;
		frame.origin.y = 0;
		viewController.view.frame = frame;
		page++;
	}
    
	CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * _page;
    frame.origin.y = 0;
	[self.scrollView scrollRectToVisible:frame animated:NO];
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	_rotating = NO;
	UIViewController *viewController = [self.childViewControllers objectAtIndex:self.pageControl.currentPage];
	[viewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
	for (NSUInteger i =0; i < [self.childViewControllers count]; i++) {
		[self loadScrollViewWithPage:i];
	}
    
	self.pageControl.currentPage = 0;
	_page = 0;
	[self.pageControl setNumberOfPages:[self.childViewControllers count]];
    
	UIViewController *viewController = [self.childViewControllers objectAtIndex:self.pageControl.currentPage];
	if (viewController.view.superview != nil) {
		[viewController viewWillAppear:animated];
	}
    
	self.scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * [self.childViewControllers count], scrollView.frame.size.height);
    
    //messageBatchIndex is the position index that tells us which message array (i.e. batch of 5 messages)
    //to use in order to populate the view controllers.
    //this position is incremented when the user goes forward on the fifth view controller
    //and it is decremented when the user goes backward on the first view controller
    self.messageBatchIndex = 0;
    
    //connect to the server and get the first batch of messages (i.e. the first 5 messages)
    ImapSync *dataManager = [ImapSync sharedDataManager];
    self.messages = [dataManager getMessagesFirstBatch];
    self.messageBatches = [[NSMutableArray alloc] init];
    [self.messageBatches addObject:self.messages];

    //now populate the view controllers' views with the first 5 messages
    [self populateChildViewControllers:self.messages];

}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if ([self.childViewControllers count]) {
		UIViewController *viewController = [self.childViewControllers objectAtIndex:self.pageControl.currentPage];
		if (viewController.view.superview != nil) {
			[viewController viewDidAppear:animated];
		}
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	if ([self.childViewControllers count]) {
		UIViewController *viewController = [self.childViewControllers objectAtIndex:self.pageControl.currentPage];
		if (viewController.view.superview != nil) {
			[viewController viewWillDisappear:animated];
		}
	}
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	UIViewController *viewController = [self.childViewControllers objectAtIndex:self.pageControl.currentPage];
	if (viewController.view.superview != nil) {
		[viewController viewDidDisappear:animated];
	}
	[super viewDidDisappear:animated];
}

- (void)loadScrollViewWithPage:(int)page {
    if (page < 0)
        return;
    if (page >= [self.childViewControllers count])
        return;
    
	// replace the placeholder if necessary
    UIViewController *controller = [self.childViewControllers objectAtIndex:page];
    if (controller == nil) {
		return;
    }
    
	// add the controller's view to the scroll view
    if (controller.view.superview == nil) {
        CGRect frame = self.scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        //NSLog(@"adding subview");
        [self.scrollView addSubview:controller.view];

    }
}

- (void)previousPage {
	if (_page - 1 > 0) {
        
		// update the scroll view to the appropriate page
		CGRect frame = self.scrollView.frame;
		frame.origin.x = frame.size.width * (_page - 1);
		frame.origin.y = 0;
        
		UIViewController *oldViewController = [self.childViewControllers objectAtIndex:_page];
		UIViewController *newViewController = [self.childViewControllers objectAtIndex:_page - 1];
		[oldViewController viewWillDisappear:YES];
		[newViewController viewWillAppear:YES];
        
		[self.scrollView scrollRectToVisible:frame animated:YES];
        
		self.pageControl.currentPage = _page - 1;
		// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
		_pageControlUsed = YES;
	}
}

- (void)nextPage {

	if (_page + 1 > self.pageControl.numberOfPages) {
		// update the scroll view to the appropriate page
		CGRect frame = self.scrollView.frame;
		frame.origin.x = frame.size.width * (_page + 1);
		frame.origin.y = 0;
        
		UIViewController *oldViewController = [self.childViewControllers objectAtIndex:_page];
		UIViewController *newViewController = [self.childViewControllers objectAtIndex:_page + 1];
		[oldViewController viewWillDisappear:YES];
		[newViewController viewWillAppear:YES];
        
		[self.scrollView scrollRectToVisible:frame animated:YES];
        
		self.pageControl.currentPage = _page + 1;
		// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
		_pageControlUsed = YES;
	}
}

- (IBAction)changePage:(id)sender {

    int page = ((UIPageControl *)sender).currentPage;
    
	// update the scroll view to the appropriate page
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    
	UIViewController *oldViewController = [self.childViewControllers objectAtIndex:_page];
	UIViewController *newViewController = [self.childViewControllers objectAtIndex:self.pageControl.currentPage];
	[oldViewController viewWillDisappear:YES];
	[newViewController viewWillAppear:YES];
    
	[self.scrollView scrollRectToVisible:frame animated:YES];
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    _pageControlUsed = YES;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	UIViewController *oldViewController = [self.childViewControllers objectAtIndex:_page];
	UIViewController *newViewController = [self.childViewControllers objectAtIndex:self.pageControl.currentPage];
	[oldViewController viewDidDisappear:YES];
	[newViewController viewDidAppear:YES];
    
	_page = self.pageControl.currentPage;
}

#pragma mark -
#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (_pageControlUsed || _rotating) {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
    
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    // If user is trying to scroll forward from final page
    // update the messages and repopulate the view controllers and redraw screens
 
    //user is scrolling from page 5 to 6 (page 6 is an empty page w/ activity indicator)
    if (self.scrollView.contentOffset.x == 1600)
    {
        [self updateMessageBatch:@"forward"];        
        [self populateChildViewControllers:self.messages];
        
        //once the new messages are loaded, jump the user back to the first page w/the new content
        //[self gotoFirstPage];
    }
      
        
    // Switch the indicator when more than 50% of the previous/next page is visible
  	if (self.pageControl.currentPage != page) {
		UIViewController *oldViewController = [self.childViewControllers objectAtIndex:self.pageControl.currentPage];
		UIViewController *newViewController = [self.childViewControllers objectAtIndex:page];
		[oldViewController viewWillDisappear:YES];
		[newViewController viewWillAppear:YES];
		self.pageControl.currentPage = page;
		[oldViewController viewDidDisappear:YES];
		[newViewController viewDidAppear:YES];
		_page = page;
	}
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _pageControlUsed = NO;

}

- (void)updateMessageBatch:(NSString *)direction
{
    if (direction == @"forward")
    {
        //NSLog(@"%i", self.messageBatchIndex);
        //NSLog(@"%i", [self.messageBatches count]);

        //NSLog(@"calling updateMessageBatch:forward for new messages");

        if (self.messageBatchIndex == ([self.messageBatches count] - 1))
        {
            NSLog(@"calling ImapSync for new messages");

            //fetch a new batch of emails and add it to messageBatches
            ImapSync *dataManager = [ImapSync sharedDataManager];

            int start = [[self.messages objectAtIndex:[self.messages count] - 1] sequenceNumber] + 1;
            [self.messageBatches addObject:[dataManager getMessages:start:start + 5]];
        }
        self.messageBatchIndex++;
    }
    else
    {
        self.messageBatchIndex--;
    }
        self.messages = [self.messageBatches objectAtIndex:self.messageBatchIndex];

}

#pragma mark -
#pragma mark data fetch methods

- (void)populateChildViewControllers:(NSMutableArray* )data
{    
    for (NSUInteger i = 0; i < [self.childViewControllers count] - 1; i++)
    {
		[self populateView:i:data];
	}
    
}


- (void)populateView:(int)page:(NSMutableArray *)data
{
    if (page < 0)
        return;
    if (page >= [self.childViewControllers count] - 1)
        return;
    
    UIViewController *controller = [self.childViewControllers objectAtIndex:page];
    if (controller == nil) {
		return;
    }
    
    [[[controller view]subviews]
     makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
    Message *msg = [data objectAtIndex:page];
    
    //TODO: add message number label

    //here we the add subject label
    CGRect labelFrameSubject = CGRectMake(20, 20, 280, 60);
    UILabel *subjectLabel = [[UILabel alloc]initWithFrame:labelFrameSubject];
    subjectLabel.numberOfLines = 0;
    [subjectLabel setBackgroundColor:[UIColor clearColor]];
    NSString *subject = msg.subject;
    subjectLabel.text = subject;
    subjectLabel.font = [subjectLabel.font fontWithSize:18];
    [subjectLabel setTextColor:[UIColor colorWithRed:(52/255.f) green:(49/255.f) blue:(47/255.f) alpha:1 ]];
    [subjectLabel setShadowColor:[UIColor darkGrayColor]];
    [subjectLabel setShadowOffset:CGSizeMake(0, -1)];
    [[controller view] addSubview:subjectLabel];
    
    //TODO: add sender (sent from) label

    
    //here we add the body label
    CGRect labelFrameBody = CGRectMake(50, 80, 280, 300);
    UILabel *myLabel = [[UILabel alloc]initWithFrame:labelFrameBody];
    myLabel.numberOfLines = 0;
    [myLabel setBackgroundColor:[UIColor clearColor]];
    NSString *body = msg.body;
    myLabel.text = body;
    [myLabel setTextColor:[UIColor colorWithRed:(52/255.f) green:(49/255.f) blue:(47/255.f) alpha:1 ]];
    [myLabel setShadowColor:[UIColor darkGrayColor]];
    [myLabel setShadowOffset:CGSizeMake(0, -1)];
    [[controller view] addSubview:myLabel];
    
    //TODO: add date label

    
}




@end
