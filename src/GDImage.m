//
//  GDImage.m
//  GDFramework
//
//  Created by David Thorpe on 20/07/2007.
//  See LICENSE file for license
//

#import <GDFramework/GDFramework.h>
#include "gd.h"

@interface GDImage (Private)
-(gdImagePtr)imagePtr;
-(void)setImagePtr:(gdImagePtr)imagePtr;
@end

@interface GDColor (Private)
-(id)initWithPtr:(void* )theImagePtr index:(int)theIndex;
@end

@interface GDFont (Private)
-(NSString* )path;
-(gdFontPtr)fontPtr;
-(float)points;
@end

@implementation GDImage

////////////////////////////////////////////////////////////////////////////////////////

+(BOOL)data:(NSData* )theData matches:(unsigned const char* )theSignature offset:(unsigned)theOffset length:(unsigned)theLength {
	unsigned const char* theBytes = [theData bytes];
	if([theData length] < (theOffset + theLength)) return NO;
	for(unsigned i = 0; i < theLength; i++) {
		if(*(theBytes+theOffset+i) != *(theSignature+i)) return NO;
	}
	return YES;
}

+(BOOL)dataIsPNG:(NSData* )theData {
	// starts with 0x89504e470d0a1a0a
	unsigned const char* theSignature = (unsigned const char* )"\x89\x50\x4e\x47\x0d\x0a\x1a\x0a";
	return [self data:theData matches:theSignature offset:0 length:8];
}

+(BOOL)dataIsJPEG:(NSData* )theData {
	// starts with 0xFFD8FF, 0x4A464946 at byte 6 onwards or 0x45786966 at byte 6 onwards
	unsigned const char* theSignature1 = (unsigned const char* )"\xFF\xD8\xFF";
	unsigned const char* theSignature2 = (unsigned const char* )"\x4A\x46\x49\x46";
	unsigned const char* theSignature3 = (unsigned const char* )"\x45\x78\x69\x66";
	
	if([self data:theData matches:theSignature1 offset:0 length:3]==NO) return NO;
	if([self data:theData matches:theSignature2 offset:6 length:4]==YES) return YES;
	if([self data:theData matches:theSignature3 offset:6 length:4]==YES) return YES;
	return NO;
}

+(BOOL)dataIsGIF:(NSData* )theData {
	// data starts with 0x474946383961 or 0x474946383761
	unsigned const char* theSignature1 = (unsigned const char* )"\x47\x49\x46\x38\x39\x61";
	unsigned const char* theSignature2 = (unsigned const char* )"\x47\x49\x46\x38\x37\x61";
	if([self data:theData matches:theSignature1 offset:0 length:6]==YES) return YES;
	if([self data:theData matches:theSignature2 offset:0 length:6]==YES) return YES;
	return NO;
}

+(BOOL)dataIsBMP:(NSData* )theData {
	// data starts with 0x424D
	unsigned const char* theSignature = (unsigned const char* )"\x42\x4D";
	if([self data:theData matches:theSignature offset:0 length:2]==YES) return YES;
	return NO;
}

+(BOOL)dataIsTIFF:(NSData* )theData {
	// data starts with 0x4D4D or 0x4949
	unsigned const char* theSignature1 = (unsigned const char* )"\x4D\x4D";
	unsigned const char* theSignature2 = (unsigned const char* )"\x49\x49";
	if([self data:theData matches:theSignature1 offset:0 length:2]==YES) return YES;
	if([self data:theData matches:theSignature2 offset:0 length:2]==YES) return YES;
	return NO;
}

////////////////////////////////////////////////////////////////////////////////////////

+(GDImageType)typeForFilename:(NSString* )thePath {
	NSString* theExtension = [thePath pathExtension];
	if([theExtension length]==0) return GDImageTypeUnknown;
	if([theExtension compare:@"jpeg" options:NSCaseInsensitiveSearch]==NSOrderedSame) return GDImageTypeJPEG;
	if([theExtension compare:@"jpg" options:NSCaseInsensitiveSearch]==NSOrderedSame) return GDImageTypeJPEG;
	if([theExtension compare:@"jpe" options:NSCaseInsensitiveSearch]==NSOrderedSame) return GDImageTypeJPEG;
	if([theExtension compare:@"gif" options:NSCaseInsensitiveSearch]==NSOrderedSame) return GDImageTypeGIF;
	if([theExtension compare:@"png" options:NSCaseInsensitiveSearch]==NSOrderedSame) return GDImageTypePNG;
	if([theExtension compare:@"bmp" options:NSCaseInsensitiveSearch]==NSOrderedSame) return GDImageTypeBMP;
	if([theExtension compare:@"tif" options:NSCaseInsensitiveSearch]==NSOrderedSame) return GDImageTypeTIFF;
	if([theExtension compare:@"tiff" options:NSCaseInsensitiveSearch]==NSOrderedSame) return GDImageTypeTIFF;
	return GDImageTypeUnknown;
}

+(GDImageType)typeForMimetype:(NSString* )theMimetype {
	if([theMimetype length]==0) return GDImageTypeUnknown;
	if([theMimetype compare:@"image/jpg" options:NSCaseInsensitiveSearch]==NSOrderedSame) return GDImageTypeJPEG;
	if([theMimetype compare:@"image/jpeg" options:NSCaseInsensitiveSearch]==NSOrderedSame) return GDImageTypeJPEG;
	if([theMimetype compare:@"image/pjpeg" options:NSCaseInsensitiveSearch]==NSOrderedSame) return GDImageTypeJPEG;
	if([theMimetype compare:@"image/gif" options:NSCaseInsensitiveSearch]==NSOrderedSame) return GDImageTypeGIF;
	if([theMimetype compare:@"image/png" options:NSCaseInsensitiveSearch]==NSOrderedSame) return GDImageTypePNG;
	if([theMimetype compare:@"image/tiff" options:NSCaseInsensitiveSearch]==NSOrderedSame) return GDImageTypeTIFF;
	if([theMimetype compare:@"image/x-ms-bmp" options:NSCaseInsensitiveSearch]==NSOrderedSame) return GDImageTypeBMP;
	if([theMimetype compare:@"image/bmp" options:NSCaseInsensitiveSearch]==NSOrderedSame) return GDImageTypeBMP;
	return GDImageTypeUnknown;
}

+(GDImageType)typeForData:(NSData* )theData {
	if([self dataIsGIF:theData]) return GDImageTypeGIF;
	if([self dataIsJPEG:theData]) return GDImageTypeJPEG;
	if([self dataIsPNG:theData]) return GDImageTypePNG;
	if([self dataIsBMP:theData]) return GDImageTypeBMP;
	if([self dataIsTIFF:theData]) return GDImageTypeTIFF;
	return GDImageTypeUnknown;
}

+(GDImageType)typeForFile:(NSString* )thePath {
	// read first 16 bytes of the file to determine signature
	NSFileHandle* theFileHandle = [NSFileHandle fileHandleForReadingAtPath:thePath];
	if(theFileHandle==nil) return GDImageTypeUnknown;
	NSData* theData = [theFileHandle readDataOfLength:16];
	[theFileHandle closeFile];
	if([theData length]==0) return GDImageTypeUnknown;
	return [self typeForData:theData];
}

////////////////////////////////////////////////////////////////////////////////////////

// create an empty image
-(id)initWithSize:(NSSize)theSize {
	self = [super init];
	if(self) {
		m_theImagePtr = gdImageCreate(theSize.width,theSize.height);
		if(m_theImagePtr==nil) {
			[self release];
			return nil;
		}
	}
	return self;
}

// create an image from pointer
-(id)initWithPtr:(void* )theImagePtr {
	self = [super init];
	if(self) {
		m_theImagePtr = theImagePtr;
		if(m_theImagePtr==nil) {
			[self release];
			return nil;
		}
	}
	return self;
}

// create image from data and auto-detect format
-(id)initWithData:(NSData* )theData {
	self = [super init];
	if(self) {
		m_theImagePtr = nil;
		switch([GDImage typeForData:theData]) {
			case GDImageTypeJPEG:
				m_theImagePtr = gdImageCreateFromJpegPtr([theData length],(void* )[theData bytes]);
				break;
			case GDImageTypeGIF:
				m_theImagePtr = gdImageCreateFromGifPtr([theData length],(void* )[theData bytes]);
				break;
			case GDImageTypePNG:
				m_theImagePtr = gdImageCreateFromPngPtr([theData length],(void* )[theData bytes]);
				break;
			case GDImageTypeBMP:
			case GDImageTypeTIFF:
			case GDImageTypeUnknown:
				return nil;
		}
		if(m_theImagePtr==nil) {
			[self release];
			return nil;
		}
	}
	return self;
}

// create image from file and auto-detect format
-(id)initWithFile:(NSString* )thePath {
	self = [super init];
	if(self) {
		m_theImagePtr = nil;
		GDImageType theType = [GDImage typeForFile:thePath];
		if(theType==GDImageTypeUnknown) {
			[self release];
			return nil;
		}
		NSData* theData = [NSData dataWithContentsOfFile:thePath];
		if(theData==nil) {
			[self release];
			return nil;
		}
		switch([GDImage typeForFile:thePath]) {
			case GDImageTypeJPEG:
				m_theImagePtr = gdImageCreateFromJpegPtr([theData length],(void* )[theData bytes]);
				break;
			case GDImageTypeGIF:
				m_theImagePtr = gdImageCreateFromGifPtr([theData length],(void* )[theData bytes]);
				break;
			case GDImageTypePNG:
				m_theImagePtr = gdImageCreateFromPngPtr([theData length],(void* )[theData bytes]);
				break;
			case GDImageTypeBMP:
			case GDImageTypeTIFF:
			case GDImageTypeUnknown:
				return nil;
		}
		if(m_theImagePtr==nil) {
			[self release];
			return nil;
		}
	}
	return self;
}

-(void)dealloc {
	[self setImagePtr:nil];
	[super dealloc];
}

////////////////////////////////////////////////////////////////////////////////////////

-(gdImagePtr)imagePtr {
	return (gdImagePtr)m_theImagePtr;
}

-(void)setImagePtr:(gdImagePtr)imagePtr {
	if(m_theImagePtr) {
		gdImageDestroy(m_theImagePtr);
	}
	m_theImagePtr = imagePtr;
}

////////////////////////////////////////////////////////////////////////////////////////

-(NSData* )_dataForType:(GDImageType)theImageType quality:(int)theQuality {
	int theJPEGQuality = (theQuality > 95 ? 95 : theQuality);
	int theLength = 0;
	void* theBytes = nil;
	switch(theImageType) {
		case GDImageTypeJPEG:
			theBytes = gdImageJpegPtr([self imagePtr],&theLength,theJPEGQuality);
			break;
		case GDImageTypeGIF:
			theBytes = gdImageGifPtr([self imagePtr],&theLength);
			break;
		case GDImageTypePNG:
			theBytes = gdImagePngPtrEx([self imagePtr],&theLength,-1);
			break;
		case GDImageTypeBMP:
		case GDImageTypeTIFF:
		case GDImageTypeUnknown:
			return nil;
	}
	if(theBytes==nil) {
		return nil;
	}
	NSData* theData = [NSData dataWithBytes:theBytes length:theLength];
	gdFree(theBytes);
	return theData;
}


-(BOOL)_writeToFile:(NSString* )thePath type:(GDImageType)theImageType quality:(int)theQuality {
	if([[NSFileManager defaultManager] fileExistsAtPath:thePath]==NO) {
		if([[NSFileManager defaultManager] createFileAtPath:thePath contents:nil attributes:nil]==NO) {
			return NO;
		}
	}
	NSData* theData = [self _dataForType:theImageType quality:theQuality];
	if(theData==nil) {
		return NO;
	}
	NSFileHandle* theFileHandle = [NSFileHandle fileHandleForWritingAtPath:thePath];
	if(theFileHandle==nil) {
		return NO;
	}
	[theFileHandle writeData:theData];
	[theFileHandle closeFile];
	return YES;
}

////////////////////////////////////////////////////////////////////////////////////////

-(NSData* )dataForType:(GDImageType)theImageType {
	return [self _dataForType:theImageType quality:-1];
}

-(NSData* )dataForType:(GDImageType)theImageType quality:(float)theQuality {
	return [self _dataForType:theImageType quality:(int)(theQuality * 95.0)];
}

-(BOOL)writeToFile:(NSString* )thePath type:(GDImageType)theImageType quality:(float)theQuality {
	return [self _writeToFile:thePath type:theImageType quality:(int)(theQuality * 95.0)];
}

-(BOOL)writeToFile:(NSString* )thePath type:(GDImageType)theImageType {
	return [self _writeToFile:thePath type:theImageType quality:-1];
}

////////////////////////////////////////////////////////////////////////////////////////

-(float)width {
	return (float)gdImageSX([self imagePtr]);
}

-(float)height {
	return (float)gdImageSY([self imagePtr]);
}

-(NSSize)size {
	return NSMakeSize([self width],[self height]);
}

////////////////////////////////////////////////////////////////////////////////////////

-(GDImage* )imageResizedTo:(NSSize)theSize resampled:(BOOL)isResampled {
	// create a new version of the image in the new size
	gdImagePtr theNewImage = gdImageCreateTrueColor(theSize.width,theSize.height);
	if(theNewImage==nil) {
		return nil;
	}
	// copy the existing image into the new one
	if(isResampled) {
		gdImageCopyResized(theNewImage,[self imagePtr],0,0,0,0,gdImageSX(theNewImage),gdImageSY(theNewImage),gdImageSX([self imagePtr]),gdImageSY([self imagePtr]));
	} else {
		gdImageCopyResampled(theNewImage,[self imagePtr],0,0,0,0,gdImageSX(theNewImage),gdImageSY(theNewImage),gdImageSX([self imagePtr]),gdImageSY([self imagePtr]));
	}
	// return image
	return [[[GDImage alloc] initWithPtr:theNewImage] autorelease];
}

-(GDImage* )imageConstrainedToMinSize:(NSSize)theSize resampled:(BOOL)isResampled {
	// determine what the size of the new image should be
	float widthFactor = (theSize.width / [self width]);
	float heightFactor = (theSize.height / [self height]);
	gdImagePtr theNewImage = nil;
	if(([self height] * widthFactor) > theSize.height) {
		// use width factor
		theNewImage = gdImageCreateTrueColor(theSize.width,[self height] * widthFactor);
	} else {
		// use height factor
		theNewImage = gdImageCreateTrueColor([self width] * heightFactor,theSize.height);
	}
	// create a new version of the image in the new size
	if(theNewImage==nil) {
		return nil;
	}
	// copy the existing image into the new one
	if(isResampled) {
		gdImageCopyResized(theNewImage,[self imagePtr],0,0,0,0,gdImageSX(theNewImage),gdImageSY(theNewImage),gdImageSX([self imagePtr]),gdImageSY([self imagePtr]));
	} else {
		gdImageCopyResampled(theNewImage,[self imagePtr],0,0,0,0,gdImageSX(theNewImage),gdImageSY(theNewImage),gdImageSX([self imagePtr]),gdImageSY([self imagePtr]));
	}
	// return image
	return [[[GDImage alloc] initWithPtr:theNewImage] autorelease];
}

-(GDImage* )imageConstrainedToMaxSize:(NSSize)theSize resampled:(BOOL)isResampled {
	// determine what the size of the new image should be
	float widthFactor = (theSize.width / [self width]);
	float heightFactor = (theSize.height / [self height]);
	gdImagePtr theNewImage = nil;
	if(([self height] * widthFactor) < theSize.height) {
		// use width factor
		theNewImage = gdImageCreateTrueColor([self width] * widthFactor,[self height] * widthFactor);
	} else {
		// use height factor
		theNewImage = gdImageCreateTrueColor([self width] * heightFactor,[self height] * heightFactor);
	}
	// create a new version of the image in the new size
	if(theNewImage==nil) {
		return nil;
	}
	// copy the existing image into the new one
	if(isResampled) {
		gdImageCopyResized(theNewImage,[self imagePtr],0,0,0,0,gdImageSX(theNewImage),gdImageSY(theNewImage),gdImageSX([self imagePtr]),gdImageSY([self imagePtr]));
	} else {
		gdImageCopyResampled(theNewImage,[self imagePtr],0,0,0,0,gdImageSX(theNewImage),gdImageSY(theNewImage),gdImageSX([self imagePtr]),gdImageSY([self imagePtr]));
	}
	// return image
	return [[[GDImage alloc] initWithPtr:theNewImage] autorelease];
}

-(GDImage* )imageConstrainedToSize:(NSSize)theSize resampled:(BOOL)isResampled cropped:(int)flags {
	// determine what the size of the new image should be
	float widthFactor = (theSize.width / [self width]);
	float heightFactor = (theSize.height / [self height]);
	float factor;
	float newWidth,newHeight;
	if(([self height] * widthFactor) > theSize.height) {
		// use width factor
		newWidth = theSize.width;
		newHeight = [self height] * widthFactor;
		factor = widthFactor;
	} else {
		// use height factor
		newWidth = [self width] * heightFactor;
		newHeight = theSize.height;
		factor = heightFactor;
	}
	// determine source offset
	float sourceX = 0;
	float sourceY = 0;
	if(newWidth != theSize.width) {
		if(flags & GDCropLeft) {
			// left crop
			sourceX = 0.0;
		} else if(flags & GDCropRight) {
			// right crop
			sourceX = (newWidth - theSize.width) / factor;
		} else {
			// center crop
			sourceX = (newWidth - theSize.width) / (factor * 2.0);
		}
	}
	if(newHeight != theSize.height) {
		if(flags & GDCropTop) {
			// top crop
			sourceY = 0.0;
		} else if(flags & GDCropBottom) {
			// bottom crop
			sourceY = (newHeight - theSize.height) / factor;
		} else {
			// center crop
			sourceY = (newHeight - theSize.height) / (factor * 2.0);
		}
	}
	// create a new version of the image in the new size
	gdImagePtr theNewImage = gdImageCreateTrueColor(theSize.width,theSize.height);
	if(theNewImage==nil) {
		return nil;
	}
	// copy the existing image into the new one
	if(isResampled) {
		gdImageCopyResized(theNewImage,[self imagePtr],0,0,sourceX,sourceY,newWidth,newHeight,gdImageSX([self imagePtr]),gdImageSY([self imagePtr]));
	} else {
		gdImageCopyResampled(theNewImage,[self imagePtr],0,0,sourceX,sourceY,newWidth,newHeight,gdImageSX([self imagePtr]),gdImageSY([self imagePtr]));
	}
	// return image
	return [[[GDImage alloc] initWithPtr:theNewImage] autorelease];
}

-(GDImage* )imageCroppedTo:(NSRect)theRect resampled:(BOOL)isResampled {
	// create a new version of the image in the new size
	gdImagePtr theNewImage = gdImageCreateTrueColor(theRect.size.width,theRect.size.height);
	if(theNewImage==nil) {
		return nil;
	}
	// convert rect co-ordinates to GD co-ordinates
	int left = theRect.origin.x;
	int top = [self height] - (theRect.origin.y + theRect.size.height);
	// copy the existing image into the new one
	if(isResampled) {
		gdImageCopyResized(theNewImage,[self imagePtr],0,0,left,top,gdImageSX(theNewImage),gdImageSY(theNewImage),theRect.size.width,theRect.size.height);
	} else {
		gdImageCopyResampled(theNewImage,[self imagePtr],0,0,left,top,gdImageSX(theNewImage),gdImageSY(theNewImage),theRect.size.width,theRect.size.height);
	}
	// return image
	return [[[GDImage alloc] initWithPtr:theNewImage] autorelease];
}

////////////////////////////////////////////////////////////////////////////////////////
// COLOUR HANDLING

-(GDColor* )colorForPoint:(NSPoint)thePoint {
	int theColorIndex = gdImageGetPixel([self imagePtr],thePoint.x,([self height] - thePoint.y));
	return (theColorIndex < 0) ? nil : [[[GDColor alloc] initWithPtr:[self imagePtr] index:theColorIndex] autorelease];
}

-(GDColor* )colorForRed:(float)theRed green:(float)theGreen blue:(float)theBlue {
	int theColorIndex = gdImageColorResolve([self imagePtr],(int)(theRed * 255.0),(int)(theGreen * 255.0),(int)(theBlue * 255.0));
	return (theColorIndex < 0) ? nil : [[[GDColor alloc] initWithPtr:[self imagePtr] index:theColorIndex] autorelease];
}

-(GDColor* )colorForRed:(float)theRed green:(float)theGreen blue:(float)theBlue alpha:(float)theAlpha {
	int theColorIndex = gdImageColorResolveAlpha([self imagePtr],(int)(theRed * 255.0),(int)(theGreen * 255.0),(int)(theBlue * 255.0),(int)((1.0 - theAlpha) * 127.0));
	return (theColorIndex < 0) ? nil : [[[GDColor alloc] initWithPtr:[self imagePtr] index:theColorIndex] autorelease];
}

////////////////////////////////////////////////////////////////////////////////////////
// DRAWING

-(void)drawRectFill:(NSRect)theRect withColor:(GDColor* )theColor {
	// convert rect co-ordinates to GD co-ordinates
	int left = theRect.origin.x;
	int right = theRect.origin.x + theRect.size.width;
	int top = [self height] - (theRect.origin.y + theRect.size.height);
	int bottom = [self height] - theRect.origin.y;
	// draw
	gdImageFilledRectangle([self imagePtr],left,top,right,bottom,[theColor index]);
}

-(void)drawRectOutline:(NSRect)theRect withColor:(GDColor* )theColor {
	// convert rect co-ordinates to GD co-ordinates
	int left = theRect.origin.x;
	int right = theRect.origin.x + theRect.size.width;
	int top = [self height] - (theRect.origin.y + theRect.size.height);
	int bottom = [self height] - theRect.origin.y;
	// draw
	gdImageRectangle([self imagePtr],left,top,right,bottom,[theColor index]);
}

-(void)drawLineFrom:(NSPoint)theSource to:(NSPoint)theDest withColor:(GDColor* )theColor {
	// convert points to GD units
	int x1 = theSource.x;
	int y1 = [self height] - theSource.y;
	int x2 = theDest.x;
	int y2 = [self height] - theDest.y;
	// draw
	gdImageLine([self imagePtr],x1,y1,x2,y2,[theColor index]);
}

-(void)drawImage:(GDImage* )theImage intoRect:(NSRect)theRect {
	// convert rect co-ordinates to GD co-ordinates
	int left = theRect.origin.x;
	int top = [self height] - (theRect.origin.y + theRect.size.height);
	// draw
	gdImageCopyResampled([self imagePtr],[theImage imagePtr],left,top,0,0,theRect.size.width,theRect.size.height,[theImage width],[theImage height]);
}

////////////////////////////////////////////////////////////////////////////////////////
// FILTERING

-(void)filterSharpenBy:(float)theAmount {
	gdImageSharpen([self imagePtr],theAmount * 100.0);
}

////////////////////////////////////////////////////////////////////////////////////////
// FONTS

-(void)drawString:(NSString* )theString point:(NSPoint)thePoint font:(GDFont* )theFont color:(GDColor* )theColor {
	// different versions for truetype and system fonts
	int x = thePoint.x;
	int y = ([self height] - thePoint.y);
	int bounds[8];
	if([theFont fontPtr]) {
		gdImageString([self imagePtr],[theFont fontPtr],x,y,(unsigned char* )[theString UTF8String],[theColor index]);
	} else {
		gdImageStringFT([self imagePtr],&bounds[0],[theColor index],(char* )[[theFont path] UTF8String],[theFont points],0.0,x,y,(char* )[theString UTF8String]);
	}
}


@end

