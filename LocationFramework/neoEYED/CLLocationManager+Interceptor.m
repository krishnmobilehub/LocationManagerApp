//
//  CLLocationManager+Interceptor.m
//  neoEYED
//


#import "CLLocationManager+Interceptor.h"
#import <objc/runtime.h>

@implementation CLLocationManager (Interceptor)

@dynamic locationDelegate;

+ (void)load
{
    Method delegateMethod = class_getInstanceMethod(self, @selector(setDelegate:));
    Method interceptedDelegateMethod = class_getInstanceMethod(self, @selector(interceptAndSetDelegate:));
    method_exchangeImplementations(delegateMethod, interceptedDelegateMethod);
}

- (void)interceptAndSetDelegate:(id<CLLocationManagerDelegate>)delegate
{
    [self setLocationDelegate:delegate];
    [self interceptAndSetDelegate:self];
}

- (void)setLocationDelegate:(id)object
{
    objc_setAssociatedObject(self, @selector(locationDelegate), object, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)locationDelegate
{
    return objc_getAssociatedObject(self, @selector(locationDelegate));
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations
{
    NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"_deviceLocation", @"eventType",
                                           [NSDate date], @"timestamp", nil];
    CLLocation *locationObject = [locations firstObject];
    NSDictionary *locationDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithDouble:locationObject.coordinate.latitude], @"latitude",
                                        [NSNumber numberWithDouble:locationObject.coordinate.longitude], @"longitude",
                                        [NSNumber numberWithDouble:locationObject.altitude], @"altitude",
                                        [NSNumber numberWithDouble:locationObject.course], @"course",
                                        [NSNumber numberWithDouble:locationObject.speed], @"speed", nil];
    [dataDictionary setObject:locationDictionary forKey:@"location"];
    NSLog(@"Event Data Received: %@", dataDictionary);
    
    [self.locationDelegate locationManager:manager didUpdateLocations:locations];
}


@end
