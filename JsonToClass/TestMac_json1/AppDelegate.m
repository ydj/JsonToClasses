//
//  AppDelegate.m
//  TestMac_json1
//
//  Created by YDJ on 12-11-26.
//  Copyright (c) 2012年 jingyoutimes. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate
@synthesize json=_json;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
  //  json = [[JSONWindowController alloc] initWithWindowNibName:@"JSONWindowController"];
    //[[json window] makeKeyAndOrderFront:nil];
    
   // [self.window addChildWindow:[json window] ordered:NSWindowOut];
    
   // json=[[JSONWindowController alloc] init];
    
    
    
}
- (NSString *) description
{
    NSString *result = @"";
    result = [result stringByAppendingFormat:@"%@ : %@\n",@"",@""];
    return result;
}

- (IBAction)json:(id)sender {
    
    json = [[JSONWindowController alloc] initWithWindowNibName:@"JSONWindowController"];
    [[json window] makeKeyAndOrderFront:nil];
}

- (IBAction)donate:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://zxapi.sinaapp.com/paypal.html"]];
}
@end
