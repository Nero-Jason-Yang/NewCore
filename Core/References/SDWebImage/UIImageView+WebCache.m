/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+WebCache.h"
#import "objc/runtime.h"

static char operationKey;
static char operationArrayKey;

@implementation UIImageView (WebCache)

- (void)setImageWithURL:(NSURL *)url {
    [self setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    [self setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options {
    [self setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)setImageWithURL:(NSURL *)url completed:(SDWebImageCompletedBlock)completedBlock {
    [self setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:completedBlock];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletedBlock)completedBlock {
    [self setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletedBlock)completedBlock {
    [self setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletedBlock)completedBlock {
    [self cancelCurrentImageLoad];

    self.image = placeholder;

    if (url) {
        __weak UIImageView *wself = self;
        id <SDWebImageOperation> operation = [SDWebImageManager.sharedManager downloadWithURL:url options:options progress:progressBlock completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
            if (!wself) return;
            dispatch_main_sync_safe(^{
                if (!wself) return;
                if (image) {
                    wself.image = image;
                    [wself setNeedsLayout];
                }
                if (completedBlock && finished) {
                    completedBlock(image, error, cacheType);
                }
            });
        }];
        objc_setAssociatedObject(self, &operationKey, operation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)setAnimationImagesWithURLs:(NSArray *)arrayOfURLs {
    [self cancelCurrentArrayLoad];
    __weak UIImageView *wself = self;

    NSMutableArray *operationsArray = [[NSMutableArray alloc] init];

    for (NSURL *logoImageURL in arrayOfURLs) {
        id <SDWebImageOperation> operation = [SDWebImageManager.sharedManager downloadWithURL:logoImageURL options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
            if (!wself) return;
            dispatch_main_sync_safe(^{
                __strong UIImageView *sself = wself;
                [sself stopAnimating];
                if (sself && image) {
                    NSMutableArray *currentImages = [[sself animationImages] mutableCopy];
                    if (!currentImages) {
                        currentImages = [[NSMutableArray alloc] init];
                    }
                    [currentImages addObject:image];

                    sself.animationImages = currentImages;
                    [sself setNeedsLayout];
                }
                [sself startAnimating];
            });
        }];
        [operationsArray addObject:operation];
    }

    objc_setAssociatedObject(self, &operationArrayKey, [NSArray arrayWithArray:operationsArray], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)cancelCurrentImageLoad {
    // Cancel in progress downloader from queue
    id <SDWebImageOperation> operation = objc_getAssociatedObject(self, &operationKey);
    if (operation) {
        [operation cancel];
        objc_setAssociatedObject(self, &operationKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)cancelCurrentArrayLoad {
    // Cancel in progress downloader from queue
    NSArray *operations = objc_getAssociatedObject(self, &operationArrayKey);
    for (id <SDWebImageOperation> operation in operations) {
        if (operation) {
            [operation cancel];
        }
    }
    objc_setAssociatedObject(self, &operationArrayKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

#import "File.h"

@interface FadeinImageView : UIImageView
@end
@implementation FadeinImageView
@end

@implementation UIImageView (File)

+ (void)refreshImageCacheWithFile:(id<File>)file type:(FileContentType)type
{
    NSURL *url = [file URLForType:type];
    NSString *key = [file cacheKeyForType:type];
    [[SDWebImageManager sharedManager] refreshWithURL:url key:key];
}

- (void)setImageWithFile:(id<File>)file type:(FileContentType)type placeholderImage:(UIImage *)placeholder
{
    return [self setImageWithFile:file type:type placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)setImageWithFile:(id<File>)file type:(FileContentType)type placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletedBlock)completedBlock
{
    [self cancelCurrentImageLoad];
    
    self.image = placeholder;
    
    NSURL *url = [file URLForType:type];
    NSString *key = [file cacheKeyForType:type];
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
