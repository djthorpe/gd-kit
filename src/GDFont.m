//
//  GDFont.m
//  GDFramework
//
//  Created by David Thorpe on 7/22/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "GDFont.h"
#import "gdfontt.h"
#import "gdfonts.h"
#import "gdfontl.h"
#import "gdfontmb.h"
#import "gdfontg.h"

@implementation GDFont

-(id)initWithPath:(NSString* )thePath points:(float)points {
  self = [super init];
  if(self) {
    m_thePath = [thePath retain];
    m_thePoints = points;
    m_theFontPtr = nil;
  }
  return self;
}

-(id)initWithPtr:(void* )thePtr {
  self = [super init];
  if(self) {
    m_thePath = nil;
    m_thePoints = 0.0;
    m_theFontPtr = thePtr;
  }
  return self;
}

-(void)dealloc {
  [m_thePath release];
  [super dealloc];
}

+(GDFont* )trueTypeFontAtPath:(NSString* )thePath points:(float)points {
  if([[NSFileManager defaultManager] isReadableFileAtPath:thePath]==NO) {
    return nil;
  }
  return [[[GDFont alloc] initWithPath:thePath points:points] autorelease];
}

+(GDFont* )tinySystemFont {
  return [[[GDFont alloc] initWithPtr:gdFontGetTiny()] autorelease];
}

+(GDFont* )smallSystemFont {
  return [[[GDFont alloc] initWithPtr:gdFontGetSmall()] autorelease];
}

+(GDFont* )largeSystemFont {
  return [[[GDFont alloc] initWithPtr:gdFontGetLarge()] autorelease];  
}

+(GDFont* )giantSystemFont {
  return [[[GDFont alloc] initWithPtr:gdFontGetGiant()] autorelease];    
}

+(GDFont* )mediumBoldSystemFont {
  return [[[GDFont alloc] initWithPtr:gdFontGetMediumBold()] autorelease];      
}

-(NSString* )path {
  return m_thePath;
} 

-(gdFontPtr)fontPtr {
  return m_theFontPtr;
}

-(float)points {
  return m_thePoints;
}

-(NSSize)sizeOfString:(NSString* )theString {
  int bounds[8];
  if([self fontPtr]) {
    return NSMakeSize([self fontPtr]->w  * [theString length],[self fontPtr]->h);
  }
  if([self path]) {
    if(gdImageStringFT(nil,&bounds[0],0,(char* )[[self path] UTF8String],[self points],0.0,0,0,(char* )[theString UTF8String])==nil) {
      return NSMakeSize(bounds[2]-bounds[6],bounds[3]-bounds[7]);
    }
  }
  return NSMakeSize(0,0);
}

-(float)emWidth {
  if([self fontPtr]) {  
    return [self fontPtr]->w;
  }
  NSSize theSize = [self sizeOfString:@"m"];
  return theSize.width;
}

-(float)emHeight {
  if([self fontPtr]) {  
    return [self fontPtr]->h;
  }
  NSSize theSize = [self sizeOfString:@"m"];
  return theSize.height;  
}

@end
