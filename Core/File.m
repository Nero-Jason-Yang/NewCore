//
//  File.m
//  NewCore
//
//  Created by Jason Yang on 14-7-29.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "File.h"

@implementation File

@end

@implementation File (RemoteURL)

- (NSURL *)thumbnailURL
{
    // TODO
    return nil;
}

@end

@implementation File (ImageCache)

- (NSString *)thumbnailCacheKey
{
    // TODO
    return nil;
}

@end

#import "UIImageView+WebCache.h"
#import "objc/runtime.h"

@interface FadeinImageView : UIImageView
@end
@implementation FadeinImageView
@end

@implementation UIImageView (File)

+ (void)cacheRefreshThumbnailWithFile:(File *)file
{
    NSURL *url = [file thumbnailURL];
    NSString *key = [file thumbnailCacheKey];
    [[SDWebImageManager sharedManager] refreshWithURL:url key:key];
}

- (void)setThumbnailWithFile:(File *)file placeholderImage:(UIImage *)placeholder
{
    return [self setThumbnailWithFile:file placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)setThumbnailWithFile:(File *)file placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletedBlock)completedBlock
{
    [self cancelCurrentImageLoad];
    
    self.image = placeholder;
    
    NSURL *url = [file thumbnailURL];
    NSString *key = [file thumbnailCacheKey];
    if (url && key) {
        __weak UIImageView *wself = self;
        id <SDWebImageOperation> operation = [SDWebImageManager.sharedManager downloadWithURL:url key:key options:options progress:progressBlock completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
            if (!wself) return;
            dispatch_main_sync_safe(^{
                if (!wself) return;
                
                FadeinImageView *fadein = [self fadeinImageView];
                fadein.image = nil;
                fadein.alpha = 0.0f;
                
                if (image) {
                    if (image == placeholder || cacheType != SDImageCacheTypeNone) {
                        wself.image = image;
                        wself.alpha = 1.0f;
                    }
                    else {
                        fadein.image = image;
                        [UIView animateWithDuration:0.3f animations:^{
                            wself.alpha = 0.0f;
                            fadein.alpha = 1.0f;
                        } completion:^(BOOL finished) {
                            wself.alpha = 1.0f;
                            fadein.alpha = 0.0f;
                            
                            if (fadein.image) {
                                wself.image = image;
                                fadein.image = nil;
                            }
                        }];
                    }
                }
                
                if (completedBlock && finished) {
                    completedBlock(image, error, cacheType);
                }
            });
        }];
        objc_setAssociatedObject(self, &operationKey, operation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (FadeinImageView *)fadeinImageView
{
    for (UIView *sibling in self.superview.subviews) {
        if ([sibling isKindOfClass:FadeinImageView.class]) {
            return (FadeinImageView *)sibling;
        }
    }
    
    FadeinImageView *fadein = [[FadeinImageView alloc] initWithFrame:self.frame];
    [self.superview insertSubview:fadein aboveSubview:self];
    return fadein;
}

- (void)clearFadeinEffect
{
    FadeinImageView *fadein = [self fadeinImageView];
    for (UIView *sibling in self.superview.subviews) {
        if ([sibling isKindOfClass:FadeinImageView.class]) {
            fadein = (FadeinImageView *)sibling;
            break;
        }
    }
    
    if (fadein) {
        fadein.image = nil;
        fadein.alpha = 0.0f;
        self.alpha = 1.0f;
    }
}

@end
