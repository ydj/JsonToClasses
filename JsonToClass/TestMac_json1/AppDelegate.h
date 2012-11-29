//
//  AppDelegate.h
//  TestMac_json1
//
//  Created by YDJ on 12-11-26.
//  Copyright (c) 2012年 jingyoutimes. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JSONWindowController.h"
@interface AppDelegate : NSObject <NSApplicationDelegate>
{

      JSONWindowController *json;
}
@property (assign) IBOutlet NSWindow *window;
@property (nonatomic,strong)IBOutlet JSONWindowController *json;
- (IBAction)json:(id)sender;
@end
