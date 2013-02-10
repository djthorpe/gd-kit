//
//  GDImage+Cocoa.m
//  GDFramework
//
//  Created by David Thorpe on 7/22/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "GDImage+Cocoa.h"

@implementation GDImage (CocoaAdditions)

-(NSImage* )NSImage {
  // create an NSImage from this data
  return [[[NSImage alloc] initWithData:[self dataForType:GDImageTypePNG]] autorelease];
}

@end
