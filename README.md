gd-kit
======

David Thorpe, djt@mutablelogic.com
July 2007

INTRODUCTION
------------

This is a framework for using the "GD" graphics library in Objective-C.
You can use this library for reading and writing images in GIF, JPEG and PNG
formats. There are many other image manipulation routines in the GD library that
I haven't included here, but it should be trivial to extend the framework to 
include most of the functionality of the GD library.


WHY
------------

If you're writing a daemon foundation tool you can't use the NSImage or NSFont
classes. The GD library is also much simpler - for better or worse - than 
Apple's frameworks. The GD library (and the PNG / JPEG libraries) are quite 
difficult to compile for Mac OS X. Here I provide a universal version of the
GD library and I have copied the JPEG and PNG libaries from another source.



USING GDFramework
------------

There is an example command-line tool provided which shows you how to use the
framework. The basis of the framework is "GDImage", which represents a single
bitmapped image. Include the GDFramework by adding frameworks to your XCode
project, and in your source you can use the following import statement:

```objc
#import <GDFramework/GDFramework.h>
```

You can create a GDImage from an NSData object or from a file:

```objc
  GDImage* theImage = [[GDImage alloc] initWithFile:thePath];
  
  GDImage* theImage = [[GDImage alloc] initWithData:theData];
```

These will try to auto-detect the type of image from the contents. They will
return 'nil' if the image cannot be autodetected, or the format is not supported.
You can also create an empty image into which you can draw:

```objc
  GDImage* theImage = [[GDImage alloc] initWithSize:theSize];
```

RESIZING AND CROPPING
------------


```objc
-(GDImage* )imageResizedTo:(NSSize)theSize resampled:(BOOL)isResampled;
```

  This method will return a new image of the exact new size. Either straight
  'pixel copy' is performed or resampling of the image can be done to create
  slightly smoother versions.

```objc
-(GDImage* )imageConstrainedToMaxSize:(NSSize)theSize resampled:(BOOL)isResampled;
```

  This method will resize the image, maintaining image aspect ratios. The size will
  be no larger than the size provided.

```objc
-(GDImage* )imageConstrainedToMinSize:(NSSize)theSize resampled:(BOOL)isResampled;
```

  This method will resize the image, maintaining image aspect ratios. The size will
  be no smaller than the size provided.

```objc
-(GDImage* )imageConstrainedToSize:(NSSize)theSize resampled:(BOOL)isResampled cropped:(int)flags;
```

  This method will resize the image, maintaining image aspect ratios. Cropping will
  be performed on the image to ensure it fits exactly to the correct dimensions. You can
  specify left, right, top or bottom cropping by OR'ing flags. For example,

  * (GDCropTop | GDCropLeft) will ensure the cropping is performed so the top left
    of the image is visible.
  
  * (GDCropRight | GDCropBottom) will ensure the cropping is performed so the bottom
    right of the image is visible.
  
  Other combinations are possible. By default, GDCropCentre cropping is 
  performed both horizontally and vertically.


COLOUR
------------

To retrieve colour from an image use the following methods:

```objc
-(GDColor* )colorForPoint:(NSPoint)thePoint;
```

  This will return a colour value from a point in the image, where the point
  uses Quartz conventions (the bottom-left of the image is the origin)

```objc
-(GDColor* )colorForRed:(float)theRed green:(float)theGreen blue:(float)theBlue;
```

  This will return a colour value from red, green and blue components, where the
  components are between 0.0 and 1.0, as per Quartz conventions.
  
```objc
-(GDColor* )colorForRed:(float)theRed green:(float)theGreen blue:(float)theBlue alpha:(float)theAlpha;
```

  This will return a colour value from red, green, blue and alpha components,
  where the components are between 0.0 and 1.0, as per Quartz conventions. For
  alpha, 0.0 means complete transparency and 1.0 means complete opacity.
  
You can create colour values from a GDImage, but you shouldn't try to allocate
GDColor objects yourself.


DRAWING
------------

You can draw outlines and filled rectangles, and place images into others using
the following methods:

```objc
  -(void)drawRectFill:(NSRect)theRect withColor:(GDColor* )theColor;

  -(void)drawRectOutline:(NSRect)theRect withColor:(GDColor* )theColor;

  -(void)drawLineFrom:(NSPoint)theSource to:(NSPoint)theDest withColor:(GDColor* )theColor;

  -(void)drawImage:(GDImage* )theImage intoRect:(NSRect)theRect;
```

Again, these follow Quartz conventions with the origin at the bottom left of the
image.


FILTERING
------------


There is only one filter in the GD graphics library for sharpening:

```objc
  -(void)filterSharpenBy:(float)theAmount;
```

The amount should be between 0.0 and 1.0, although I believe it's possible
to go higher.


FONTS
------------


You can render in-built system fonts or TrueType fonts into your images. To
create a font object, use one of the following methods:

```objc
  +(GDFont* )trueTypeFontAtPath:(NSString* )thePath points:(float)points;

  +(GDFont* )tinySystemFont;

  +(GDFont* )smallSystemFont;

  +(GDFont* )largeSystemFont;

  +(GDFont* )giantSystemFont;

  +(GDFont* )mediumBoldSystemFont;
```

You can obtain the em width or height (the width or height of the 'm' letter),
or the size that an NSString may take:

```objc
  -(float)emWidth;

  -(float)emHeight;

  -(NSSize)sizeOfString:(NSString* )theString;
```

To draw a string in an image, use the following GDImage method:

```objc
  -(void)drawString:(NSString* )theString point:(NSPoint)thePoint font:(GDFont* )theFont color:(GDColor* )theColor;
```

Here, I think the point is the top left point of the string, rather than the
bottom left. This may not exactly follow the Quartz conventions.



OUTPUT
------------


You can output a GDImage into PNG, JPEG and GIF formats. If you've got a
window manager (that is, running your application as an agent or application
rather than a daemon) you can also convert the GDImage into an NSImage, which will
output the TIFF format amongst others. You will need to include one of the
following GDImageType constants when using these methods:

  GDImageTypeGIF, GDImageTypeJPEG or GDImageTypePNG

The methods for outputting images are as follows:

```objc
-(BOOL)writeToFile:(NSString* )thePath type:(GDImageType)theImageType;
```

  This will write the GDImage to a file. Will return YES on success. The
  file will be overwritten if it already exists.  

```objc
-(BOOL)writeToFile:(NSString* )thePath type:(GDImageType)theImageType quality:(float)theQuality;
```

  As above, but will allow you to set quality of output for JPEG files. The
  quality parameter should be between 0.0 and 1.0.

```objc
-(NSData* )dataForType:(GDImageType)theImageType;
```

  This will return an NSData object which contains the bitmap image. Will
  return nil on failure.

```objc
-(NSData* )dataForType:(GDImageType)theImageType quality:(float)theQuality;
```

  As above, but will allow you to set quality of output for JPEG files. The
  quality parameter should be between 0.0 and 1.0.

```objc
-(NSImage* )NSImage
```

  Will return an NSImage for the GDImage.


DETECTING FILE FORMATS

There are some additional methods for detecting the image file format from 
filenames, mimetypes or data:

```objc
  +(GDImageType)typeForFilename:(NSString* )thePath;

  +(GDImageType)typeForMimetype:(NSString* )theMimetype;

  +(GDImageType)typeForData:(NSData* )theData;  

  +(GDImageType)typeForFile:(NSString* )thePath;
```

These will return a GDImageType of one of the following types:

```objc
  GDImageTypeGIF
  GDImageTypeJPEG
  GDImageTypePNG
  GDImageTypeBMP
  GDImageTypeTIFF
```

If the format could not be detected, the constant GDImageTypeUnknown is
returned. Note that reading and writing TIFF and BMP image file formats are not
yet supported by this framework.


REBUILDING INSTRUCTIONS
------------


If you want to re-build the GD library, I can suggest the following method,
for creating a universal binary static library. Version 2.0.33 seems to work OK 
with Mac OS X but the newest release doesn't.

1. Download the previously-compiled PNG and JPEG libraries 

   http://ethan.tira-thompson.com/Mac%20OS%20X%20Ports.html
   
2. Unpack freetype into subdirectory "freetype-2.3.5" and run the following
   commands:
   
   cd freetype-2.3.5
   export CFLAGS="-isysroot /Developer/SDKs/MacOSX10.4u.sdk -arch i386 -arch ppc -I/usr/local/include"
   export LDFLAGS="-Wl,-syslibroot,/Developer/SDKs/MacOSX10.4u.sdk -arch i386 -arch ppc"
   ln -s `which glibtool` ./libtool
   ./configure --disable-shared --enable-static --prefix=/opt/freetype-2.3.5  --disable-dependency-tracking --without-freetype --without-fontconfig
   make
   sudo make install
   
3. Unpack gd into a subdirectory "gd-2.0.33" and run the following commands:

  cd gd-2.0.33
  export CFLAGS="-isysroot /Developer/SDKs/MacOSX10.4u.sdk -arch i386 -arch ppc -I/usr/local/include"
  export LDFLAGS="-Wl,-syslibroot,/Developer/SDKs/MacOSX10.4u.sdk -arch i386 -arch ppc"
  ln -s `which glibtool` ./libtool
  ./configure --disable-shared --enable-static --prefix=/opt/gd-2.0.33 --with-freetype=/opt/freetype-2.3.5 --without-fontconfig --disable-dependency-tracking
  make
  sudo make install
  
This will install the GD library into /opt/gd-2.0.33. You should then copy the
libraries and include files into the GDFramework before rebuilding the framework.



FOR FURTHER INFORMATION
------------

See the GD website,

  http://www.libgd.org/
  
There are some helpful rebuild instructions here:

  http://www.libgd.org/DOC_INSTALL_OSX
  
I used the universal binaries for PNG and JPEG libraries from here:

  http://ethan.tira-thompson.com/Mac%20OS%20X%20Ports.html

Thank you Ethan Tira-Thompson.

  


