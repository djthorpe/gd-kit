//
//  GDColor.h
//  GDFramework
//
//  Created by David Thorpe on 20/07/2007.
//  See LICENSE file for license
//

#import <Foundation/Foundation.h>

@interface GDColor : NSObject {
  void* m_theImagePtr;
  int m_theIndex;
}

-(int)index;
-(float)redComponent;
-(float)greenComponent;
-(float)blueComponent;
-(float)alphaComponent;

@end
