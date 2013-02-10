//
//  GDImage+Cocoa.h
//  GDFramework
//
//  Created by David Thorpe on 7/22/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "GDImage.h"

@interface GDImage (CocoaAdditions)
// return an NSImage from a GDImage
-(NSImage* )NSImage;
@end
