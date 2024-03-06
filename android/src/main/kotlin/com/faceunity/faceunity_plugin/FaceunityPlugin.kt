package com.faceunity.faceunity_plugin

import android.content.Context
import android.util.Log
import androidx.annotation.NonNull
import androidx.lifecycle.Lifecycle
import com.faceunity.core.enumeration.FUFaceProcessorDetectModeEnum
import com.faceunity.core.faceunity.FUAIKit
import com.faceunity.core.utils.FULogger
import com.faceunity.core.faceunity.OffLineRenderHandler
import com.faceunity.core.camera.FUCamera;
import com.faceunity.faceunity_plugin.FaceunityKit
import com.faceunity.faceunity_plugin.modules.BaseModulePlugin
import com.faceunity.faceunity_plugin.modules.FUBodyBeautyPlugin
import com.faceunity.faceunity_plugin.modules.FUMakeupPlugin
import com.faceunity.faceunity_plugin.modules.FUStickerPlugin
import com.faceunity.faceunity_plugin.modules.FUFaceBeautyPlugin
import com.faceunity.faceunity_plugin.modules.RenderPlugin
import com.faceunity.faceunity_plugin.render.GLSurfaceViewPlatformViewFactory
import com.faceunity.faceunity_plugin.render.NotifyFlutterListener
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.loader.FlutterLoader
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.lifecycle.HiddenLifecycleReference
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlin.coroutines.resume
import com.faceunity.faceunity_plugin.utils.FuDeviceUtils

/** FaceunityPlugin */
class FaceunityPlugin : FlutterPlugin, MethodCallHandler,EventChannel.StreamHandler, ActivityAware {
    companion object {
        private const val TAG = "FaceunityPlugin"
    }

    private val glSurfaceViewPlatformViewFactory = GLSurfaceViewPlatformViewFactory()
    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var flutterPluginBindings: FlutterPlugin.FlutterPluginBinding

    private var eventSink: EventChannel.EventSink? = null
    private val faceBeautyPlugin by lazy { FUFaceBeautyPlugin() }
    private val stickerPlugin by lazy { FUStickerPlugin() }
    private val makeupPlugin by lazy { FUMakeupPlugin() }
    private val bodyPlugin by lazy { FUBodyBeautyPlugin() }
    private val sensorHandler by lazy { SensorHandler() }
    private val renderPlugin by lazy { RenderPlugin(channel) }

    private lateinit var context: Context
    private val mainScope = MainScope()
    private lateinit var lifecycle: Lifecycle

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        flutterPluginBindings = flutterPluginBinding
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "faceunity_plugin")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        Log.i(TAG, "onMethodCall: ${call.method}, arguments: ${call.arguments}")
        when {
            faceBeautyPlugin.containsMethod(call.method) -> faceBeautyPlugin.handleMethod(call, result)
            makeupPlugin.containsMethod(call.method) -> makeupPlugin.handleMethod(call, result)
            stickerPlugin.containsMethod(call.method) -> stickerPlugin.handleMethod(call, result)
            bodyPlugin.containsMethod(call.method) -> bodyPlugin.handleMethod(call, result)
            renderPlugin.containsMethod(call.method) -> renderPlugin.handleMethod(call, result)
            else -> methodCall(call, result)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        eventSink = null
        mainScope.cancel()
        renderPlugin.dispose()
        glSurfaceViewPlatformViewFactory.release()
        //单页面不会走flutter widget dispose 逻辑，所以在这做一次兜底
        destroyRenderKit()
    }

    private fun methodCall(call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }

            "isHighPerformanceDevice" -> {
                result.success(FaceunityKit.devicePerformanceLevel == FuDeviceUtils.DEVICE_LEVEL_HIGH)
            }

            "isNPUSupported" -> {
                result.success(false)
            }
            
            "turnOffEffects" -> {
                turnOnOffEffects(false)
            }

            "turnOnEffects" -> {
                turnOnOffEffects(true)
            }
            "setupRenderKit" -> setupRenderKit()
            "destoryRenderKit" -> destroyRenderKit()
            "startRenderPlugin" -> startRenderPlugin()
            "diposeRenderPlugin" -> diposeRenderPlugin()
        }
    }


  private fun startRenderPlugin(){
      eventChannel = EventChannel(flutterPluginBindings.binaryMessenger, "render_event_channel")
        eventChannel.setStreamHandler(this)
        glSurfaceViewPlatformViewFactory.setRenderFrameListener(object : NotifyFlutterListener {
            override fun notifyFlutter(data: Map<String, Any>) {
                mainScope.launch {
                    eventSink?.success(data)
                }
            }
        })
        flutterPluginBindings.platformViewRegistry.registerViewFactory("faceunity_display_view", glSurfaceViewPlatformViewFactory)
        renderPlugin.init(glSurfaceViewPlatformViewFactory)
   }

  private fun diposeRenderPlugin(){
    eventChannel.setStreamHandler(null)
    eventSink = null
    mainScope.cancel()
    renderPlugin.dispose()
    glSurfaceViewPlatformViewFactory.release()
   }



    private fun turnOnOffEffects(enable: Boolean) {
        FaceunityKit.isEffectsOn = enable
        faceBeautyPlugin.enableBeauty(enable)
        makeupPlugin.enableMakeup(enable)
        bodyPlugin.enableBody(enable)
        stickerPlugin.enableSticker(enable)
    }

    private fun setupRenderKit() {
        FaceunityKit.setupKit(context) {
            OffLineRenderHandler.getInstance().onResume()
        }
        sensorHandler.register(context) {
            FaceunityKit.deviceOrientation = it
        }
    }

    private fun destroyRenderKit() {
        sensorHandler.unregister()
        OffLineRenderHandler.getInstance().queueEvent {
            FaceunityKit.releaseKit()
        }
        OffLineRenderHandler.getInstance().onPause()
    }

      override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        this.eventSink = events
    }

     override fun onCancel(arguments: Any?) {
    }

     override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        lifecycle = getActivityLifecycle(binding)
        lifecycle.addObserver(glSurfaceViewPlatformViewFactory)
    }

    override fun onDetachedFromActivityForConfigChanges() {

    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivity() {
        lifecycle.removeObserver(glSurfaceViewPlatformViewFactory)
    }


    private fun getActivityLifecycle(
        activityPluginBinding: ActivityPluginBinding,
    ): Lifecycle {
        val reference = activityPluginBinding.lifecycle as HiddenLifecycleReference
        return reference.lifecycle
    }
}
