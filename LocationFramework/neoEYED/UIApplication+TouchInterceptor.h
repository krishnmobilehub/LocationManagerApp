//
//  UIApplication+TouchInterceptor.h
//  neoEYED
//

#import <UIKit/UIKit.h>

@interface UIApplication (TouchInterceptor)

@property (nonatomic, assign) NSDictionary *startPoint;
@property (nonatomic, assign) NSNumber *zoomGesture;

@end
