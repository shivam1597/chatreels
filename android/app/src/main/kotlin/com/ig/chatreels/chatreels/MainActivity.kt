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
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "chatreels.com/channel").setMethodCallHandler {
                call, result ->
            if(call.method == "getContacts") {
                var args = call.arguments as Map<String, String>
                result.success(checkWhatsApp(args["contactId"] as String))
            }
            else {
                result.notImplemented()
            }
        }
    }

    private fun checkWhatsApp(id: String): Boolean {
        val projection = arrayOf<String>(ContactsContract.RawContacts._ID)
        val selection = ContactsContract.Data.MIMETYPE + " = ? AND " + ContactsContract.Data.RAW_CONTACT_ID + " = ? "
        val selectionArgs = arrayOf(id, "com.whatsapp")
        val cursor: Cursor? = contentResolver.query(
            ContactsContract.RawContacts.CONTENT_URI,
            arrayOf(ContactsContract.RawContacts.CONTACT_ID, ContactsContract.RawContacts.DISPLAY_NAME_PRIMARY),
            ContactsContract.Data.MIMETYPE + " = ? AND " + ContactsContract.Data.RAW_CONTACT_ID + " = ? ",
            arrayOf(id, "com.whatsapp"),
            null
        )
        val hasWhatsApp: Boolean = cursor!!.moveToNext()
//        println(hasWhatsApp)
        return hasWhatsApp
//        if (hasWhatsApp) {
//            val rowContactId: String = cursor.getString(0)
//        }
    }
}
