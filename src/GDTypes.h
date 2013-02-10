
// cropping flags
typedef enum {
  GDCropCenter = 0,
  GDCropCentre = 0,
  GDCropTop    = 1,
  GDCropLeft   = 2,
  GDCropRight  = 4,
  GDCropBottom = 8
} GDCropFlags;

// image type flags
typedef enum {
  GDImageTypeUnknown = 0,
  GDImageTypeGIF  = 1,
  GDImageTypeJPEG = 2,
  GDImageTypePNG  = 3,
  GDImageTypeBMP  = 4,
  GDImageTypeTIFF = 5,
} GDImageType;