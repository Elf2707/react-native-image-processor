#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(RNImageProcessor, NSObject)

RCT_EXTERN_METHOD(createPngImage:
    (CGFloat) width
    height:(CGFloat) height
    fillColor:(NSString *)fillColor
    name:(NSString *) name
)

RCT_EXTERN_METHOD(drawImageOnImage:
    (NSString *) destImageName
    srcImageName: (NSString *) srcImageName
    destX: (CGFloat) destX
    destY: (CGFloat) destY
    sourceWidth: (CGFloat) sourceWidth
    sourceHeight: (CGFloat) sourceHeight
)

RCT_EXTERN_METHOD(drawMosaicImage:
    (NSArray *) imageNames
    name:(NSString *) name
    backgroundColor: (NSString *) backgroundColor
    options:(NSDictionary *) options
    resolve:(RCTPromiseResolveBlock) resolve
    reject:(RCTPromiseRejectBlock) reject
)

RCT_EXTERN_METHOD(saveToGallery:(NSString *) name format: (NSString *) format)

@end
