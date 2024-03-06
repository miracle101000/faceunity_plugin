import 'package:flutter/services.dart';

class FaceunityPlugin {
  static const methodChannel = MethodChannel('faceunity_plugin');

  static Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  // 设备是否高端机型
  static Future<bool> isHighPerformanceDevice() async {
    final bool result =
        await methodChannel.invokeMethod("isHighPerformanceDevice");
    return result;
  }

  // 设备是否支持 NPU
  static Future<bool> isNPUSupported() async {
    final bool result = await methodChannel.invokeMethod("isNPUSupported");
    return result;
  }

  // 获取模块鉴权码
  static Future<int> getModuleCode(int code) async {
    final int result = await methodChannel.invokeMethod("getModuleCode", {
      "arguments": [
        {"code": code}
      ]
    });
    return result;
  }

  // 初始化 FURenderKit，包括 AI bundle 加载
  static Future<void> setupRenderKit() async {
    await methodChannel.invokeMethod("setupRenderKit");
  }

  // 销毁 FURenderKit
  static Future<void> destoryRenderKit() async {
    await methodChannel.invokeMethod("destoryRenderKit");
  }

  // 检查美颜是否已经加载，没有加载则需要在接口方法加载美颜
  static Future<void> checkIsBeautyLoaded() async {
    await methodChannel.invokeMethod("checkIsBeautyLoaded");
  }

  // 检查美体是否已经加载，没有加载则需要在接口方法加载美体
  static Future<void> checkIsBodyLoaded() async {
    await methodChannel.invokeMethod("checkIsBodyLoaded");
  }

  /// 加载美颜
  /// @note 两端插件初始化时已经加载了美颜，可以不用再加载美颜，卸妆后可以调用该方法重新加载
  static Future<void> loadBeauty() async {
    await methodChannel.invokeMethod("loadBeauty");
  }

  // 卸载美颜（释放内存）
  static Future<void> unloadBeauty() async {
    methodChannel.invokeMethod("unloadBeauty");
  }

  // 加载美体
  static Future<void> loadBody() async {
    await methodChannel.invokeMethod("loadBody");
  }

  // 卸载美体（释放内存）
  static Future<void> unloadBody() async {
    methodChannel.invokeMethod("unloadBody");
  }

  /// 关闭所有已经加载的特效（美颜、美妆、贴纸、美体）
  /// @note iOS插件只是把加载的特效对象的 enable 属性设置为 NO，并不卸载已经加载的特效对象
  static Future<void> turnOffEffects() async {
    await methodChannel.invokeMethod("turnOffEffects");
  }

  /// 开启所有特效
  /// @note iOS插件只是把加载的特效对象的 enable 属性设置为 YES，并不重新加载特效对象
  static Future<void> turnOnEffects() async {
    await methodChannel.invokeMethod("turnOnEffects");
  }

  /// 设置最大人脸数量
  /// @param number 1-4
  static Future<void> setMaximumFacesNumber(int number) async {
    await methodChannel.invokeMethod("setMaximumFacesNumber", {
      "arguments": [
        {"number": number}
      ]
    });
  }

  /// 请求原生相册
  /// @param type 类型（0照片 1视频）
  static Future<void> requestAlbumForType(int type) async {
    await methodChannel.invokeMethod("requestAlbumForType", {
      "arguments": [
        {"type": type}
      ]
    });
  }

  /// 原生图片和视频选择完成回调，需要原生端调用 MethodChannel("fulive_plugin") 的 invokeMethod 方法
  /// @param callBack 原生端选择完图片和视频并缓存后的回调
  /// @note 原生端选择图片和视频后先自行缓存，Flutter端进入图片或视频渲染后使用
  /// @note 原生端回调结构：method(photoSelected或videoSelected)、arguments(成功true和失败false)
  static Future<void> requestAlbumCallBack(Function callBack) async {
    methodChannel.setMethodCallHandler((call) => callBack(call));
  }

  /// 设置人脸检测模式
  /// @param mode 0图片 1视频，参考 FURenderKit 相关接口
  static Future<void> setFaceProcessorDetectMode(int mode) async {
    await methodChannel.invokeMethod("setFaceProcessorDetectMode", {
      "arguments": [
        {"mode": mode}
      ]
    });
  }

  static Future<void> startRenderPlugin() async {
    await methodChannel.invokeMethod("startRenderPlugin");
  }

  static Future<void> diposeRenderPlugin() async {
    await methodChannel.invokeMethod("diposeRenderPlugin");
  }
}
