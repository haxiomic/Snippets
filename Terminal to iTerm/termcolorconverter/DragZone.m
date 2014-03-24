//
//  DragZone.m
//  termcolorconverter
//
//  Created by George Corney on 24/03/2014.
//  Copyright (c) 2014 haxiomic. All rights reserved.
//

#import "DragZone.h"
#import "AppDelegate.h"

@implementation DragZone

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self registerForDraggedTypes:[NSArray arrayWithObjects:
                                       NSColorPboardType, NSFilenamesPboardType, nil]];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
    
    return YES;
}



- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    //check to see if we can accept the data
    return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSArray *draggedFilePaths = [pboard propertyListForType:NSFilenamesPboardType];
    
    if([draggedFilePaths count]<=0){return NO;}
    
    NSString* path = [draggedFilePaths objectAtIndex:0];
    
    AppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
    [appDelegate terminalToITermFromPath:path];
                                
    return YES;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    
    // This will cause the + sign to appear next to the cursor when hovering over the view.
    return NSDragOperationCopy;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender{
}

@end
