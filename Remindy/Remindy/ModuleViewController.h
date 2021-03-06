//
//  ModuleViewController.h
//  Remindy
//
//  Created by Shaohuan Li on 6/7/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventViewController.h"

@interface ModuleViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,NSURLConnectionDelegate>
@property (strong, nonatomic) IBOutlet UITableView *moduleTableView;
@property (nonatomic) NSArray *modules;
@property (nonatomic) NSString *uid;
@property (nonatomic) NSString *token;
@property (nonatomic) NSDictionary *selectedModule;
@property (nonatomic) NSMutableArray *eventList;
@property (nonatomic) EventViewController * destViewController;
@property (nonatomic, strong) NSMutableData *moduleData;
-(void)checkForModules;
@end
