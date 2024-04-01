//
//  FacebookShare.h
//  RNShare
//
//  Created by Luciano Bracco on 31/03/2024.
//

#import "FacebookShare.h"
#import <FBSDKShareKit/FBSDKShareKit.h>

@implementation FacebookShareModule

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(shareSingle:(NSDictionary *)data
                  reject:(RCTPromiseRejectBlock)reject
                  resolve:(RCTPromiseResolveBlock)resolve)
{
    NSDictionary *imageDict = data[@"image"];
    NSDictionary *videoDict = data[@"video"];
    
    if (!imageDict || !videoDict) {
        reject(@"MISSING_PARAMETERS", @"Image or video parameters are missing", nil);
        return;
    }
    
    NSString *title = imageDict[@"title"];
    NSString *message = imageDict[@"message"];
    NSString *imageName = imageDict[@"imageName"];
    NSString *videoPath = videoDict[@"videoPath"];
    
    if (!imageName || !videoPath) {
        reject(@"MISSING_PARAMETERS", @"Image name or video path parameter is missing", nil);
        return;
    }
    
    UIImage *image = [UIImage imageNamed:imageName];
    if (!image) {
        reject(@"INVALID_IMAGE", @"Image not found", nil);
        return;
    }
    
    NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
    
    [self shareMediaToFacebookWithImage:image title:title message:message videoURL:videoURL reject:reject resolve:resolve];
}

- (void)shareMediaToFacebookWithImage:(UIImage *)image
                             videoURL:(NSURL *)videoURL
                                title:(NSString *)title
                              message:(NSString *)message
                               reject:(RCTPromiseRejectBlock)reject
                              resolve:(RCTPromiseResolveBlock)resolve {
    FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
    photo.image = image;
    photo.userGenerated = YES;
    
    FBSDKShareVideo *video = [[FBSDKShareVideo alloc] init];
    video.videoURL = videoURL;
    
    FBSDKSharePhotoContent *photoContent = [[FBSDKSharePhotoContent alloc] init];
    photoContent.photos = @[photo];
    photoContent.contentTitle = title; // Set title
    
    FBSDKShareVideoContent *videoContent = [[FBSDKShareVideoContent alloc] init];
    videoContent.video = video;
    videoContent.contentTitle = title; // Set title
    
    FBSDKShareMediaContent *content = [[FBSDKShareMediaContent alloc] init];
    content.media = @[photoContent, videoContent];
    content.contentDescription = message; // Set message
    
    FBSDKShareDialog *shareDialog = [[FBSDKShareDialog alloc] init];
    shareDialog.fromViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    shareDialog.shareContent = content;
    shareDialog.mode = FBSDKShareDialogModeAutomatic;
    
    if (![shareDialog canShow]) {
        reject(@"SHARE_DIALOG_NOT_AVAILABLE", @"Share dialog is not available", nil);
        return;
    }
    
    [shareDialog show];
    resolve(@YES);
}


@end
