//
//  FilterScreenViewController.h
//  MailFilter
//
//  Created by Moe Burney on 2013-01-28.
//  Copyright (c) 2013 Dev70. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterScreenViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>{
    
}

@property (nonatomic,retain) NSArray *folders;
@property (nonatomic,retain) NSString *selectedFolder;
@property (nonatomic,retain) IBOutlet UILabel *sender;
@property (nonatomic,retain) IBOutlet UILabel *subject;
@property (nonatomic,retain) IBOutlet UISwitch *senderSwitch;
@property (nonatomic,retain) IBOutlet UISwitch *subjectSwitch;


- (IBAction)saveFilterRule:(id)sender;
- (IBAction)dismissFilterPage:(id)sender;



@end
