//
//  UIViewController+Interceptor.m
//  neoEYED
//

#import "UIViewController+Interceptor.h"
#import <objc/runtime.h>

@implementation UIViewController (Interceptor)

+ (void)load
{
    Method viewDidLoadMethod = class_getInstanceMethod(self, @selector(viewDidLoad));
    Method interceptedViewDidLoadMethod = class_getInstanceMethod(self, @selector(interceptedViewDidLoad));
    method_exchangeImplementations(viewDidLoadMethod, interceptedViewDidLoadMethod);
}

- (void)interceptedViewDidLoad
{
    NSMutableDictionary *dataDictionary = [NSMutableDictionary
                                           dictionaryWithObjectsAndKeys:@"_viewDidLoad", @"eventType",
                                           [NSDate date], @"timestamp", nil];
    NSLog(@"Event Data Received: %@", dataDictionary);
}

@end
