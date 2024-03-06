//
//  FUUtil.h
//  faceunity_plugin
//
//  Created by 项林平 on 2023/10/27.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>


NS_ASSUME_NONNULL_BEGIN

@interface FUUtil : NSObject

+ (NSString *)pluginBundlePathWithName:(NSString *)name;

/// 请求相册权限
/// - Parameter handler: 回调
+ (void)requestPhotoLibraryAuthorization:(void (^)(PHAuthorizationStatus status))handler;

/// 获取本地视频地址
/// - Parameters:
///   - info: 从相册选择信息
///   - handler: 结果回调
+ (void)requestVideoURLFromInfo:(NSDictionary<NSString *,id> *)info resultHandler:(void (^)(NSURL *videoURL))handler;

/// 从视频地址获取首帧预览图
/// - Parameters:
///   - videoURL: 视频地址
///   - preferred: 是否调整方向
+ (UIImage *)previewImageFromVideoURL:(NSURL *)videoURL preferredTrackTransform:(BOOL)preferred;

/// 从视频地址获取最后一帧图片
/// - Parameters:
///   - videoURL: 视频地址
///   - preferred: 是否调整方向
+ (UIImage *)lastFrameImageFromVideoURL:(NSURL *)videoURL preferredTrackTransform:(BOOL)preferred;


/// 获取视频方向，参考 FUVideoOrientation
/// - Parameter videoURL: 视频地址
+ (NSUInteger)videoOrientationFromVideoURL:(NSURL *)videoURL;

+ (UIViewController *)topViewController;

@end

NS_ASSUME_NONNULL_END
