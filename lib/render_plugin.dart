import 'dart:async';
import 'faceunity_plugin.dart';

class RenderPlugin {
  static const _channel = FaceunityPlugin.methodChannel;

  static const int moduleCode = 6;

  // 开启内部相机
  static Future<void> startCamera() async {
    // {"module" : moduleCode, "arguments" : [{"intensity" : intensity}, {"type" : type}]}
    await _channel.invokeMethod("startCamera", {"module": moduleCode});
  }

  // 关闭内部相机
  static Future<void> stopCamera() async {
    await _channel.invokeMethod("stopCamera", {"module": moduleCode});
  }

  /// 切换前后置摄像头
  /// @param isFront 是否前置
  /// @return 返回 true 表示切换成功，false 表示切换失败（设备不支持分辨率等）
  static Future<bool> switchCamera(bool isFront) async {
    final bool result = await _channel.invokeMethod("switchCamera", {
      "module": moduleCode,
      "arguments": [
        {"isFront": isFront}
      ]
    });
    return result;
  }

  /// 设置相机曝光度
  /// @param exposure 曝光度，0.0-1.0
  /// @note 各端在插件里面自行转换为曝光度的实际值，iOS端为 -2.0 - 2.0，0.5 对应端上的 0.0
  static Future<void> setCameraExposure(double exposure) async {
    await _channel.invokeMethod("setCameraExposure", {
      "module": moduleCode,
      "arguments": [
        {"exposure": exposure}
      ]
    });
  }

  /// 手动对焦
  /// @param dx dy 屏幕横纵坐标
  static Future<void> manualFocus(double dx, double dy) async {
    await _channel.invokeMethod("manualFocus", {
      "module": moduleCode,
      "arguments": [
        {"dx": dx},
        {"dy": dy}
      ]
    });
  }

  /// 切换相机输出格式
  /// @param format 格式，0 BGRA 1 YUV
  /// @note iOS接口
  static Future<void> switchCameraOutputFormat(int format) async {
    await _channel.invokeMethod("switchCameraOutputFormat", {
      "module": moduleCode,
      "arguments": [
        {"format": format}
      ]
    });
  }

  /// 切换单双输入
  /// @param inputType 格式，0 单输入 1 双输入
  /// @note Android接口
  static Future<void> switchRenderInputType(int inputType) async {
    await _channel.invokeMethod("switchRenderInputType", {
      "module": moduleCode,
      "arguments": [
        {"inputType": inputType}
      ]
    });
  }

  /// 设置特效渲染状态
  /// @param isRendering 是否渲染特效
  /// @note true 渲染特效 false 渲染原图
  static Future<void> setRenderState(bool isRendering) async {
    await _channel.invokeMethod("setRenderState", {
      "module": moduleCode,
      "arguments": [
        {"isRendering": isRendering}
      ]
    });
  }

  /// 拍照保存图片
  /// @param callBack 保存结果异步回调
  /// @note 各端自行保存一帧图片到相册
  /// @note 原生端回调结构：method(takePhotoResult)、arguments(成功true和失败false)
  static Future<void> takePhoto(Function callBack) async {
    _channel.setMethodCallHandler((call) => callBack(call));
    await _channel.invokeMethod("takePhoto", {"module": moduleCode});
  }

  /// 开始视频录制
  /// @note 原生端自行决定怎么保存视频帧
  static Future<void> startRecord() async {
    _channel.invokeMethod("startRecord", {"module": moduleCode});
  }

  /// 结束视频录制并保存视频
  /// @return 返回是否保存成功结果
  /// @note 结束后原生端保存视频到相册
  static Future<bool> stopRecord() async {
    bool result =
        await _channel.invokeMethod("stopRecord", {"module": moduleCode});
    return result;
  }

  /// 切换相机分辨率
  /// @param preset 分辨率索引，参考 CapturePreset 枚举值
  /// @return 返回是否保存成功结果
  static Future<bool> switchCapturePreset(int preset) async {
    bool result = await _channel.invokeMethod("switchCapturePreset", {
      "module": moduleCode,
      "arguments": [
        {"preset": preset}
      ]
    });
    return result;
  }

  /// 开始图片渲染
  static Future<void> startImageRender() async {
    _channel.invokeMethod("startImageRender",{"module": moduleCode});
  }

  /// 停止图片渲染
  static Future<void> stopImageRender() async {
    _channel.invokeMethod("stopImageRender",{"module": moduleCode});
  }

  /// 图片渲染时捕获渲染图片并保存到相册
  /// @param callBack 保存结果异步回调
  /// @note 原生端回调结构：method(captureImageResult)、arguments(成功true和失败false)
  static Future<void> captureImage(Function callBack) async {
    _channel.setMethodCallHandler((call) => callBack(call));
    await _channel.invokeMethod("captureImage",{"module": moduleCode});
  }

  /// 释放图片资源
  static Future<void> disposeImageRender() async {
    _channel.invokeMethod("disposeImageRender",{"module": moduleCode});
  }

  /// 开始视频首帧预览
  /// @note 循环渲染首帧
  static Future<void> startPreviewingVideo() async {
    _channel.invokeMethod("startPreviewingVideo",{"module": moduleCode});
  }

  /// 停止视频首帧预览
  static Future<void> stopPreviewingVideo() async {
    _channel.invokeMethod("stopPreviewingVideo",{"module": moduleCode});
  }

  /// 开始播放视频，原生端开始解码和渲染
  /// @note 播放完成自动停止视频播放并循环渲染最后一帧
  static Future<void> startPlayingVideo() async {
    _channel.invokeMethod("startPlayingVideo",{"module": moduleCode});
  }

  /// 停止播放视频，原生端停止解码
  static Future<void> stopPlayingVideo() async {
    _channel.invokeMethod("stopPlayingVideo",{"module": moduleCode});
  }

  /// 开始导出视频，原生端开始解码和重新编码
  /// @note 导出过程中原生端使用 EventChannel 向 Flutter 端传递导出进度 (videoExportingProgress, 0.0-1.0)
  /// @note 导出完成原生端使用 EventChannel 向 Flutter 端传递导出到相册结果 (videoExportingResult, true/false)
  static Future<void> startExportingVideo() async {
    _channel.invokeMethod("startExportingVideo",{"module": moduleCode});
  }

  /// 停止导出视频，原生端停止解码和编码
  static Future<void> stopExportingVideo() async {
    _channel.invokeMethod("stopExportingVideo",{"module": moduleCode});
  }

  /// 停止所有编解码和渲染任务，释放相关资源
  /// @note 释放保存的帧数据、计时器的回收等
  static Future<void> disposeVideoRender() async {
    _channel.invokeMethod("disposeVideoRender",{"module": moduleCode});
  }

  static Future<void> dispose() async {
    _channel.invokeMethod("dispose",{"module": moduleCode});
  }
}
