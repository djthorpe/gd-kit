//
//  GDColor.m
//  GDFramework
//
//  Created by David Thorpe on 7/22/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "GDColor.h"
#include "gd.h"

@implementation GDColor

-(id)initWithPtr:(void* )theImagePtr index:(int)theIndex {
  self = [super init];
  if (self != nil) {
    if(theIndex < 0 || theImagePtr==nil) {
      [self release];
      return nil;
    }
    m_theIndex = theIndex;
    m_theImagePtr = theImagePtr;
  }
  return self;
}

////////////////////////////////////////////////////////////////////////////////////////

-(gdImagePtr)imagePtr {
  return (gdImagePtr)m_theImagePtr;
}

-(int)index {
  return m_theIndex;
}

////////////////////////////////////////////////////////////////////////////////////////

-(float)redComponent {
  return ((float)gdImageRed([self imagePtr],[self index])) / 255.0;
}
  
-(float)greenComponent {
  return ((float)gdImageGreen([self imagePtr],[self index])) / 255.0;  
}

-(float)blueComponent {
  return ((float)gdImageBlue([self imagePtr],[self index])) / 255.0;
}

-(float)alphaComponent {
  return 1.0 - ((float)gdImageAlpha([self imagePtr],[self index])) / 127.0;
}

////////////////////////////////////////////////////////////////////////////////////////

-(NSString* )description {
  return [NSString stringWithFormat:@"<GDColor %f,%f,%f,%f>",[self redComponent],[self greenComponent],[self blueComponent],[self alphaComponent]];
}

@end
