//
//  ViewController.h
//  Remindy
//
//  Created by Shaohuan Li on 23/6/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventModel.h"

@interface ViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,UIWebViewDelegate,NSURLConnectionDelegate>

@property (nonatomic) NSCache *myCache;
@property (nonatomic) NSString *uid;
@property (nonatomic) NSDictionary *modules;

@property (strong, nonatomic) IBOutlet UIWebView *loginView;

@property (strong, nonatomic) IBOutlet UITableView *eventTableView;
@property (nonatomic) NSMutableArray *events;

-(void)checkForAccessToken:(NSString *)urlString;
-(void)getUid;
-(void)getModules;

@end
