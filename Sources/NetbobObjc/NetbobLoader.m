
#import "NetbobLoader.h"

@implementation NetbobLoader

+ (void)load
{
    SEL implementNetbobSelector = NSSelectorFromString(@"implementNetbob");
    if ([NSURLSessionConfiguration respondsToSelector:implementNetbobSelector])
    {
        [NSURLSessionConfiguration performSelector:implementNetbobSelector];
    }
}

@end
