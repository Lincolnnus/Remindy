//
//  ViewController.m
//  Remindy
//
//  Created by Shaohuan Li on 23/6/13.
//  Copyright (c) 2013 nus.cs3217. All rights reserved.
//

#import "ViewController.h"
#import "ModuleViewController.h"
//#import "AFJSONRequestOperation.h"

@interface ViewController ()
@end

@implementation ViewController

@synthesize loginView,myCache,moduleData;

- (void)viewDidLoad
{
    [super viewDidLoad];
    myCache = [[NSCache alloc] init]; 
    NSLog(@"token %@",[myCache objectForKey:@"token"]);
    
	NSString *apikey = @"ziGsQQOz1ymvjT2ZRQzDp";
    
	[loginView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    
	NSString *redirectUrlString = @"http://ivle.nus.edu.sg/api/login/login_result.ashx";
	NSString *authFormatString = @"https://ivle.nus.edu.sg/api/login/?apikey=%@";
    
    NSString *urlString = [NSString stringWithFormat:authFormatString, apikey, redirectUrlString];
	NSURL *url = [NSURL URLWithString:urlString];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
	[loginView loadRequest:request];
    loginView.delegate = self;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	
    NSString *urlString = request.URL.absoluteString;
	NSLog(@"urlString: %@", urlString);
	
    [self checkForAccessToken:urlString];
    
    return TRUE;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"finished lodding");
}

-(void)checkForAccessToken:(NSString *)urlString {
	
    
	NSError *error;
    
	NSLog(@"checkForAccessToken: %@", urlString);
	NSRegularExpression *regex = [NSRegularExpression
								  regularExpressionWithPattern:@"r=(.*)"
								  options:0 error:&error];
    if (regex != nil) {
        NSTextCheckingResult *firstMatch =
		[regex firstMatchInString:urlString
						  options:0 range:NSMakeRange(0, [urlString length])];
        if (firstMatch) {
            NSRange accessTokenRange = [firstMatch rangeAtIndex:1];
            NSString *success = [urlString substringWithRange:accessTokenRange];
            success = [success
                       stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			
			//check for r=0
			NSLog(@"success: %@", success);
			
			if ([success isEqualToString:@"0"]) {
				NSURL *responseURL = [NSURL URLWithString:urlString];
                
				NSString *token = [NSString stringWithContentsOfURL:responseURL
														   encoding:NSASCIIStringEncoding
															  error:&error];
				//print out the token or save for next logon or to navigate to next API call.
				[myCache setObject:token forKey:@"token"];
                [self getUid];
                [self getModules];
			}
        }
	}
    
}
- (void)getUid{
    NSString *token=[myCache objectForKey:@"token"];
    NSString *apikey = @"ziGsQQOz1ymvjT2ZRQzDp";
    NSString *useridUrlString = [NSString stringWithFormat:@"https://ivle.nus.edu.sg/api/Lapi.svc/UserID_Get?APIKey=%@&Token=%@", apikey, token];
    NSURL *url = [NSURL URLWithString:useridUrlString];
    NSLog(@"getting uid");
    NSString *uid = [NSString stringWithContentsOfURL:url];
    [myCache setObject:uid forKey:@"uid"];
    NSLog(@"uid%@",uid);
}
- (void)getModules{
    NSString *token=[myCache objectForKey:@"token"];
    NSString *apikey = @"ziGsQQOz1ymvjT2ZRQzDp";
    NSString *moduleUrlString = [NSString stringWithFormat:@"https://ivle.nus.edu.sg/api/Lapi.svc/Modules?APIKey=%@&AuthToken=%@&Duration=%d&IncludeAllInfo=%@", apikey, token,1000,@"true"];
    NSURL *url = [NSURL URLWithString:moduleUrlString];
    
    moduleData = [NSMutableData data];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (theConnection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        moduleData = [NSMutableData data];
    } else {
        // Inform the user that the connection failed.
    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showModuleView"]) {
        ModuleViewController *destViewController = segue.destinationViewController;
        destViewController.modules =[myCache objectForKey:@"modules"];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse");
    [moduleData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"receivedData");
    [moduleData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
    NSLog(@"Connection failed: %@", [error description]);
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    
    // convert to JSON
    NSError *myError = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:moduleData options:NSJSONReadingMutableLeaves error:&myError];
    
    // extract specific value...
    NSArray *results = [res objectForKey:@"Results"];
    [myCache setObject:results forKey:@"modules"];
    [self performSegueWithIdentifier:@"showModuleView" sender:self];
    
}
- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
