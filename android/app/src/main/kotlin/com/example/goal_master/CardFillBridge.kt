package com.ayoub.goalmaster

import android.net.Uri
import android.content.ClipDescription
import android.content.ClipboardManager
import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PersistableBundle
import androidx.webkit.JavaScriptExecutionWorld
import androidx.webkit.JavaScriptReplyProxy
import androidx.webkit.ScriptHandler
import androidx.webkit.WebMessageCompat
import androidx.webkit.WebViewCompat
import androidx.webkit.WebViewFeature
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.webviewflutter.WebViewFlutterAndroidExternalApi
import org.json.JSONObject
import android.webkit.WebView

private const val CARD_FILL_CHANNEL = "goal_master/card_fill"
private const val ALLOWED_CARD_ORIGIN = "https://npg.moamalat.net:6006"
private const val DEBUG_TEST_CARD_ORIGIN = "http://10.0.2.2:8766"

class CardFillBridge(
    private val engine: FlutterEngine,
    private val appContext: Context,
    private val channel: MethodChannel
) {
    private class Session(val id: Long, val webView: WebView, val world: JavaScriptExecutionWorld, val script: ScriptHandler) {
        var ready: JavaScriptReplyProxy? = null
        var pending: MethodChannel.Result? = null
        var timeout: Runnable? = null
    }
    private val sessions = mutableMapOf<Long, Session>()
    private val main = Handler(Looper.getMainLooper())

    fun handle(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "markClipboardSensitive") {
            result.success(markClipboardSensitive(call.argument<String>("text")))
            return
        }
        val id = call.argument<Number>("webViewId")?.toLong()
        if (id == null) { result.success(if (call.method == "install") mapOf("ok" to false, "status" to "missing_webview_id") else mapOf("ok" to false, "reason" to "unsupported")); return }
        when (call.method) {
            "install" -> result.success(install(id, call.argument("script"), call.argument("origins")))
            "fill" -> fill(id, call, result)
            "dispose" -> { dispose(id); result.success(null) }
            else -> result.notImplemented()
        }
    }

    private fun install(id: Long, script: String?, origins: List<String>?): Map<String, Any> {
        fun status(code: String, ok: Boolean = false) = mapOf("ok" to ok, "status" to code)
        val origin = origins?.singleOrNull() ?: return status("invalid_origin_rules")
        val providerOrigin = origin == ALLOWED_CARD_ORIGIN
        val debugFixtureOrigin = BuildConfig.DEBUG && origin == DEBUG_TEST_CARD_ORIGIN
        if (script.isNullOrBlank()) return status("empty_script")
        if (!providerOrigin && !debugFixtureOrigin) return status("origin_not_allowlisted")
        val webView = WebViewFlutterAndroidExternalApi.getWebView(engine, id) ?: return status("webview_not_registered")
        if (!WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_LISTENER)) return status("web_message_listener_unsupported")
        if (!WebViewFeature.isFeatureSupported(WebViewFeature.DOCUMENT_START_SCRIPT)) return status("document_start_script_unsupported")
        if (!WebViewFeature.isFeatureSupported(WebViewFeature.JS_INJECTION_IN_FRAME_AND_WORLD)) return status("frame_world_injection_unsupported")
        dispose(id)
        var scriptHandler: ScriptHandler? = null
        var operation = "create_execution_world"
        return try {
            val world = JavaScriptExecutionWorld("goal-master-card-fill", webView)
            operation = "addJavaScriptOnEvent"
            val handler = WebViewCompat.addJavaScriptOnEvent(webView, script, WebViewCompat.INJECTION_EVENT_DOCUMENT_START, setOf(origin), world)
            scriptHandler = handler
            val session = Session(id, webView, world, handler)
            operation = "addWebMessageListener"
            WebViewCompat.addWebMessageListener(webView, "goalMasterCardFill", setOf(origin), world) { _, message, sourceOrigin, _, reply ->
                if (originOf(sourceOrigin) != origin) return@addWebMessageListener
                val body = runCatching { JSONObject(message.data ?: return@addWebMessageListener) }.getOrNull() ?: return@addWebMessageListener
                when (body.optString("type")) {
                    "ready" -> { session.ready = reply; emit(id, "ready") }
                    "gone" -> { session.ready = null; emit(id, "gone") }
                    "result" -> finish(session, body.optJSONObject("result"))
                }
            }
            sessions[id] = session
            status("installed", true)
        } catch (error: Exception) {
            runCatching { scriptHandler?.remove() }
            val failure = status("script_install_failed").toMutableMap()
            if (BuildConfig.DEBUG) {
                failure["operation"] = operation
                failure["exceptionType"] = error.javaClass.simpleName.take(80)
                failure["safeReason"] = safeInstallReason(error.message)
            }
            failure
        }
    }

    private fun safeInstallReason(message: String?): String {
        if (message.isNullOrBlank()) return "no_message"
        return message
            .replace(Regex("https?://\\S+"), "<url>")
            .replace(Regex("\\b\\d{8,}\\b"), "<redacted>")
            .replace(Regex("[^A-Za-z0-9 _.:/<>-]"), " ")
            .trim()
            .take(120)
            .ifEmpty { "no_safe_message" }
    }

    private fun markClipboardSensitive(expectedText: String?): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU || expectedText.isNullOrEmpty()) {
            return false
        }
        val clipboard = appContext.getSystemService(ClipboardManager::class.java) ?: return false
        val clip = clipboard.primaryClip ?: return false
        if (clip.itemCount == 0 || clip.getItemAt(0).coerceToText(appContext).toString() != expectedText) {
            return false
        }
        val extras = PersistableBundle(clip.description.extras ?: PersistableBundle())
        extras.putBoolean(ClipDescription.EXTRA_IS_SENSITIVE, true)
        clip.description.setExtras(extras)
        clipboard.setPrimaryClip(clip)
        return true
    }

    private fun originOf(uri: Uri): String {
        val scheme = uri.scheme ?: return ""
        val host = uri.host ?: return ""
        val port = if (uri.port != -1) uri.port else if (scheme == "https") 443 else 80
        return "$scheme://$host:$port"
    }
    private fun emit(id: Long, state: String) = main.post { channel.invokeMethod("state", mapOf("webViewId" to id.toInt(), "state" to state)) }

    private fun fill(id: Long, call: MethodCall, result: MethodChannel.Result) {
        val session = sessions[id]
        val frame = session?.ready
        if (session == null || frame == null || session.pending != null) { result.success(mapOf("ok" to false, "reason" to "no_ready_frame")); return }
        val payload = JSONObject().put("op", "fill")
            .put("pan", call.argument<String>("pan") ?: "")
            .put("exp", call.argument<String>("exp") ?: "")
            .put("name", call.argument<String>("name") ?: "")
            .put("acceptTerms", call.argument<Boolean>("acceptTerms") ?: false)
        session.pending = result
        val timeout = Runnable { finish(session, null) }
        session.timeout = timeout
        main.postDelayed(timeout, 10_000)
        try { frame.postMessage(payload.toString()) } catch (_: Exception) { finish(session, null) }
    }

    private fun finish(session: Session, outcome: JSONObject?) {
        val result = session.pending ?: return
        session.pending = null
        session.timeout?.let(main::removeCallbacks)
        session.timeout = null
        val safe = mutableMapOf<String, Any>("ok" to (outcome?.optBoolean("ok") ?: false))
        if (outcome == null) safe["reason"] = "no_ready_frame"
        for (key in listOf("pan", "exp", "name", "terms", "cvv")) {
            outcome?.optString(key)?.takeIf { it in setOf("filled", "failed", "absent", "checked", "skipped", "untouched") }?.let { safe[key] = it }
        }
        outcome?.optString("reason")?.takeIf { it in setOf("unknown_form", "cvv_not_empty", "invalid_card") }?.let { safe["reason"] = it }
        result.success(safe)
    }

    private fun dispose(id: Long) {
        val session = sessions.remove(id) ?: return
        session.timeout?.let(main::removeCallbacks)
        try {
            WebViewCompat.removeWebMessageListener(session.webView, session.world, "goalMasterCardFill")
            session.script.remove()
        } catch (_: Exception) { }
    }

    companion object {
        fun register(engine: FlutterEngine, appContext: Context) {
            val channel = MethodChannel(engine.dartExecutor.binaryMessenger, CARD_FILL_CHANNEL)
            val bridge = CardFillBridge(engine, appContext.applicationContext, channel)
            channel.setMethodCallHandler { call, result -> bridge.handle(call, result) }
        }
    }
}
