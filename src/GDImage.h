//
//  GDImage.h
//  GDFramework
//
//  Created by David Thorpe on 20/07/2007.
//  See LICENSE file for license
//

#import <Foundation/Foundation.h>
#import "GDTypes.h"
#import "GDColor.h"
#import "GDFont.h"

// GDImage
@interface GDImage : NSObject {
  void* m_theImagePtr;
}

// constructors for images
-(id)initWithSize:(NSSize)theSize;
-(id)initWithData:(NSData* )theData;
-(id)initWithFile:(NSString* )thePath;

// guess what type of image
+(GDImageType)typeForFilename:(NSString* )thePath;
+(GDImageType)typeForMimetype:(NSString* )theMimetype;
+(GDImageType)typeForData:(NSData* )theData;  
+(GDImageType)typeForFile:(NSString* )thePath;

// create data blobs for images, write out images
// when writing JPEG's, the 'quality' setting should be between 0.0 and 1.0
-(BOOL)writeToFile:(NSString* )thePath type:(GDImageType)theImageType;
-(BOOL)writeToFile:(NSString* )thePath type:(GDImageType)theImageType quality:(float)theQuality;
-(NSData* )dataForType:(GDImageType)theImageType;
-(NSData* )dataForType:(GDImageType)theImageType quality:(float)theQuality;

// get dimensions of image
-(float)width;
-(float)height;
-(NSSize)size;

// create new image by resizing and constraining
-(GDImage* )imageResizedTo:(NSSize)theSize resampled:(BOOL)isResampled;
-(GDImage* )imageCroppedTo:(NSRect)theRect resampled:(BOOL)isResampled;
-(GDImage* )imageConstrainedToMaxSize:(NSSize)theSize resampled:(BOOL)isResampled;
-(GDImage* )imageConstrainedToMinSize:(NSSize)theSize resampled:(BOOL)isResampled;
-(GDImage* )imageConstrainedToSize:(NSSize)theSize resampled:(BOOL)isResampled cropped:(int)flags;

// retrieving colours from image, components are all 0.0->1.0
-(GDColor* )colorForPoint:(NSPoint)thePoint;
-(GDColor* )colorForRed:(float)theRed green:(float)theGreen blue:(float)theBlue;
-(GDColor* )colorForRed:(float)theRed green:(float)theGreen blue:(float)theBlue alpha:(float)theAlpha;

// drawing into an image
-(void)drawRectFill:(NSRect)theRect withColor:(GDColor* )theColor;
-(void)drawRectOutline:(NSRect)theRect withColor:(GDColor* )theColor;
-(void)drawLineFrom:(NSPoint)theSource to:(NSPoint)theDest withColor:(GDColor* )theColor;
-(void)drawImage:(GDImage* )theImage intoRect:(NSRect)theRect;
-(void)drawString:(NSString* )theString point:(NSPoint)thePoint font:(GDFont* )theFont color:(GDColor* )theColor;

// filtering the image
-(void)filterSharpenBy:(float)theAmount;

@end
