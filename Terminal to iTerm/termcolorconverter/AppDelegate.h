//
//  AppDelegate.h
//  termcolorconverter
//
//  Created by George Corney on 24/03/2014.
//  Copyright (c) 2014 haxiomic. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

- (BOOL) terminalToITermFromPath:(NSString *) terminalPath;

@end
