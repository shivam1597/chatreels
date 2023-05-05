package com.ig.chatreels.chatreels
import android.content.Intent
import android.database.Cursor
import android.provider.ContactsContract
import android.widget.Toast
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "chatreels.com/channel"
        ).setMethodCallHandler { call, result ->
            if (call.method == "showToast") {
                var args = call.arguments as Map<String, String>
                result.success(showToast(args["toast"] as String))
            } else {
                result.notImplemented()
            }
        }
    }

    private fun showToast(toastMessage: String){
        Toast.makeText(this@MainActivity, toastMessage, Toast.LENGTH_SHORT).show()
    }
}
