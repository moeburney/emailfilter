//
//  MailScrollViewController.h
//  MailFilter
//
//  Created by Moe Burney on 2012-11-25.
//  Copyright (c) 2012 Dev70. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MailScrollViewController : UIViewController <UIScrollViewDelegate>

//todo: make the scrollview programatically instead of IBOutlet to see if it works

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic,retain) NSMutableArray *messageBatches;
@property (nonatomic,retain) NSMutableArray *messages;
@property (nonatomic) NSUInteger messageBatchIndex;



- (IBAction)changePage:(id)sender;


@end
