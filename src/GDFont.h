//
//  GDFont.h
//  GDFramework
//
//  Created by David Thorpe on 20/07/2007.
//  See LICENSE file for license
//

#import <Foundation/Foundation.h>

@interface GDFont : NSObject {
  NSString* m_thePath;
  float m_thePoints;
  void* m_theFontPtr;
}

+(GDFont* )trueTypeFontAtPath:(NSString* )thePath points:(float)points;
+(GDFont* )tinySystemFont;
+(GDFont* )smallSystemFont;
+(GDFont* )largeSystemFont;
+(GDFont* )giantSystemFont;
+(GDFont* )mediumBoldSystemFont;

-(NSSize)sizeOfString:(NSString* )theString;
-(float)emWidth;
-(float)emHeight;

@end
