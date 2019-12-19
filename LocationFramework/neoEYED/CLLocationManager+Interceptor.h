//
//  CLLocationManager+Interceptor.h
//  neoEYED
//

#import <CoreLocation/CoreLocation.h>

@interface CLLocationManager (Interceptor) <CLLocationManagerDelegate>

@property (nonatomic, assign) id<CLLocationManagerDelegate> locationDelegate;


@end
