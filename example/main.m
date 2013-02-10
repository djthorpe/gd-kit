//
//  main.m
//  GDFramework
//  This is an example of how to use GDFramework to do work with images

#import <Foundation/Foundation.h>
#import <GDFramework/GDFramework.h>

int main(int argc,char* argv[]) {
  int returnValue = 0;    
  NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init]; 

  GDImage* theImage = [[GDImage alloc] initWithFile:@"/Users/djt/Subversion/GDFramework/example/max.jpg"];
  if(theImage==NO) {
    NSLog(@"Error - image cannot be loaded");   
    returnValue = -1;
    goto APPLICATION_QUIT;
  }

  // constain the original image to a new size
  GDImage* theNewImage = [theImage imageConstrainedToSize:NSMakeSize(400,400) resampled:NO cropped:GDCropCenter];
  
  // allocate the colours in the new image
  GDColor* theRed = [theNewImage colorForRed:1.0 green:0.0 blue:0.0 alpha:0.25];
  GDColor* theBlue = [theNewImage colorForRed:0.0 green:0.0 blue:1.0 alpha:0.25];
  GDColor* theWhite = [theNewImage colorForRed:1.0 green:1.0 blue:1.0];
  
  // red square
  [theNewImage drawRectFill:NSMakeRect(0,0,200,200) withColor:theRed];
  [theNewImage drawRectOutline:NSMakeRect(0,0,200,200) withColor:theWhite];

  // blue square
  [theNewImage drawRectFill:NSMakeRect(200,0,200,400) withColor:theBlue];
  [theNewImage drawRectOutline:NSMakeRect(200,0,200,400) withColor:theWhite];
  
  // image
  [theNewImage drawImage:theImage intoRect:NSMakeRect(200,0,200,200)];
  [theNewImage drawRectOutline:NSMakeRect(200,0,200,200) withColor:theWhite];

  // text - truetype fonts
  GDFont* theFont1 = [GDFont trueTypeFontAtPath:@"/Users/djt/Subversion/Fluxo/lib/batik-1.6/samples/tests/resources/ttf/glb12.ttf" points:56.0];
  NSString* theString = @"Mr. Max";
  NSSize theSize = [theFont1 sizeOfString:theString];
  [theNewImage drawString:theString point:NSMakePoint(20,[theNewImage height] - theSize.height - 20) font:theFont1 color:theWhite];

  // text - system fonts
  GDFont* theFont2 = [GDFont tinySystemFont];
  [theNewImage drawString:@"Rendered by libgd, freetype and GDFramework" point:NSMakePoint(20,[theNewImage height] - theSize.height - 30) font:theFont2 color:theWhite];

  
  // write out the images
  NSLog(@"Write PNG");
  [theNewImage writeToFile:@"/Users/djt/max.png" type:GDImageTypePNG];  
  NSLog(@"Write GIF");
  [theNewImage writeToFile:@"/Users/djt/max.gif" type:GDImageTypeGIF];  
  NSLog(@"Write JPEG, quality 0.2");
  [theNewImage writeToFile:@"/Users/djt/max.jpeg" type:GDImageTypeJPEG quality:0.2];  

  // use AppKit to write out the TIFF version
  NSData* theTIFF = [[theNewImage NSImage] TIFFRepresentation];
  [theTIFF writeToFile:@"/Users/djt/max.tiff" atomically:NO];

  // release the original image
  [theImage release];
  
APPLICATION_QUIT:
  [pool release];
  return returnValue;
}

