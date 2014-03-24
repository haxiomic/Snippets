//
//  AppDelegate.m
//  termcolorconverter
//
//  Created by George Corney on 24/03/2014.
//  Copyright (c) 2014 haxiomic. All rights reserved.
//

/* Written quickly for the sake of a quick hack, but could be turned into a proper application with little effort */

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
}

- (NSDictionary *) terminalToITerm:(NSDictionary *)terminal{
    //Get .terminal plist
    NSDictionary * plistDict = terminal;//[self downloadPlist:self.urlField.stringValue];
    
    //Colors
    NSColor * black         = [NSKeyedUnarchiver unarchiveObjectWithData:[plistDict objectForKey:@"ANSIBlackColor"]];				//0
    NSColor * red           = [NSKeyedUnarchiver unarchiveObjectWithData:[plistDict objectForKey:@"ANSIRedColor"]];					//1
    NSColor * green         = [NSKeyedUnarchiver unarchiveObjectWithData:[plistDict objectForKey:@"ANSIGreenColor"]];				//2
    NSColor * yellow        = [NSKeyedUnarchiver unarchiveObjectWithData:[plistDict objectForKey:@"ANSIYellowColor"]];              //3
    NSColor * blue          = [NSKeyedUnarchiver unarchiveObjectWithData:[plistDict objectForKey:@"ANSIBlueColor"]];				//4
    NSColor * magenta       = [NSKeyedUnarchiver unarchiveObjectWithData:[plistDict objectForKey:@"ANSIMagentaColor"]];				//5
    NSColor * cyan          = [NSKeyedUnarchiver unarchiveObjectWithData:[plistDict objectForKey:@"ANSICyanColor"]];				//6
    NSColor * white         = [NSKeyedUnarchiver unarchiveObjectWithData:[plistDict objectForKey:@"ANSIWhiteColor"]];				//7
    NSColor * brightBlack   = [NSKeyedUnarchiver unarchiveObjectWithData:[plistDict objectForKey:@"ANSIBrightBlackColor"]];			//8
    NSColor * brightRed     = [NSKeyedUnarchiver unarchiveObjectWithData:[plistDict objectForKey:@"ANSIBrightRedColor"]];			//9
    NSColor * brightGreen   = [NSKeyedUnarchiver unarchiveObjectWithData:[plistDict objectForKey:@"ANSIBrightGreenColor"]];			//10
    NSColor * brightYellow  = [NSKeyedUnarchiver unarchiveObjectWithData:[plistDict objectForKey:@"ANSIBrightYellowColor"]];		//11
    NSColor * brightBlue    = [NSKeyedUnarchiver unarchiveObjectWithData:[plistDict objectForKey:@"ANSIBrightBlueColor"]];          //12
    NSColor * brightMagenta = [NSKeyedUnarchiver unarchiveObjectWithData:[plistDict objectForKey:@"ANSIBrightMagentaColor"]];		//13
    NSColor * brightCyan    = [NSKeyedUnarchiver unarchiveObjectWithData:[plistDict objectForKey:@"ANSIBrightCyanColor"]];          //14
    NSColor * brightWhite   = [NSKeyedUnarchiver unarchiveObjectWithData:[plistDict objectForKey:@"ANSIBrightWhiteColor"]];			//15
    
    NSColor * textColor       = [NSKeyedUnarchiver unarchiveObjectWithData:[plistDict objectForKey:@"TextColor"]];
    NSColor * textBoldColor   = [NSKeyedUnarchiver unarchiveObjectWithData:[plistDict objectForKey:@"TextBoldColor"]];
    NSColor * backgroundColor = [NSKeyedUnarchiver unarchiveObjectWithData:[plistDict objectForKey:@"BackgroundColor"]];
    NSColor * selectionColor  = [NSKeyedUnarchiver unarchiveObjectWithData:[plistDict objectForKey:@"SelectionColor"]];
    NSColor * cursorColor     = [NSKeyedUnarchiver unarchiveObjectWithData:[plistDict objectForKey:@"CursorColor"]];
    
    
    //Create iTerm plist
    NSMutableDictionary * iTermProfile = [[NSMutableDictionary alloc] init];
    
    [iTermProfile setObject:[self toITermColorFormat: black]         forKey:@"Ansi 0 Color"];
    [iTermProfile setObject:[self toITermColorFormat: red]           forKey:@"Ansi 1 Color"];
    [iTermProfile setObject:[self toITermColorFormat: green]         forKey:@"Ansi 2 Color"];
    [iTermProfile setObject:[self toITermColorFormat: yellow]        forKey:@"Ansi 3 Color"];
    [iTermProfile setObject:[self toITermColorFormat: blue]          forKey:@"Ansi 4 Color"];
    [iTermProfile setObject:[self toITermColorFormat: magenta]       forKey:@"Ansi 5 Color"];
    [iTermProfile setObject:[self toITermColorFormat: cyan]          forKey:@"Ansi 6 Color"];
    [iTermProfile setObject:[self toITermColorFormat: white]         forKey:@"Ansi 7 Color"];
    [iTermProfile setObject:[self toITermColorFormat: brightBlack]   forKey:@"Ansi 8 Color"];
    [iTermProfile setObject:[self toITermColorFormat: brightRed]     forKey:@"Ansi 9 Color"];
    [iTermProfile setObject:[self toITermColorFormat: brightGreen]   forKey:@"Ansi 10 Color"];
    [iTermProfile setObject:[self toITermColorFormat: brightYellow]  forKey:@"Ansi 11 Color"];
    [iTermProfile setObject:[self toITermColorFormat: brightBlue]    forKey:@"Ansi 12 Color"];
    [iTermProfile setObject:[self toITermColorFormat: brightMagenta] forKey:@"Ansi 13 Color"];
    [iTermProfile setObject:[self toITermColorFormat: brightCyan]    forKey:@"Ansi 14 Color"];
    [iTermProfile setObject:[self toITermColorFormat: brightWhite]   forKey:@"Ansi 15 Color"];
    
    [iTermProfile setObject:[self toITermColorFormat: backgroundColor]  forKey:@"Background Color"];
    [iTermProfile setObject:[self toITermColorFormat: textBoldColor]    forKey:@"Bold Color"];
    [iTermProfile setObject:[self toITermColorFormat: cursorColor]      forKey:@"Cursor Color"];
    [iTermProfile setObject:[self toITermColorFormat: textColor]        forKey:@"Cursor Text Color"];
    [iTermProfile setObject:[self toITermColorFormat: textColor]        forKey:@"Foreground Color"];
    [iTermProfile setObject:[self toITermColorFormat: textColor]        forKey:@"Selected Text Color"];
    [iTermProfile setObject:[self toITermColorFormat: selectionColor]   forKey:@"Selection Color"];
    
    /*iTerm format
     <key>Selection Color</key>
     <dict>
     <key>Blue Component</key>
     <real>0.19370138645172119</real>
     <key>Green Component</key>
     <real>0.15575926005840302</real>
     <key>Red Component</key>
     <real>0.0</real>
     </dict>
     */

    return iTermProfile;
}

- (NSDictionary *) toITermColorFormat:(NSColor *)c{
    return [[NSDictionary alloc] initWithObjectsAndKeys:
            [NSNumber numberWithFloat: [c redComponent]], @"Red Component",
            [NSNumber numberWithFloat: [c greenComponent]], @"Green Component",
            [NSNumber numberWithFloat: [c blueComponent]], @"Blue Component",
            nil];
}

- (BOOL) terminalToITermFromPath:(NSString *) terminalPath{
    //load plist from file
    NSDictionary * terminalProfile = [[NSDictionary alloc] initWithContentsOfFile:terminalPath];
    NSDictionary * iTermProfile = [self terminalToITerm:terminalProfile];
    
    //Save
    NSString * path = [[terminalPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"itermcolors"];
    NSLog(@"%@", path);
    
    BOOL result = [iTermProfile writeToFile:[path stringByExpandingTildeInPath] atomically:YES];
    
    if(result==YES)
        NSLog(@"Converted!");
    else
        NSLog(@"File save failed");
    
    return result;
}

@end


