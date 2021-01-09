package app.kitachisuku.simple_timer

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.os.Handler
import android.media.MediaPlayer

class MainActivity: FlutterActivity() {
    private val CHANNEL = "package.timerSound/simpletimer"
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger,CHANNEL).setMethodCallHandler {
            call,result ->
            if(call.method == "playTimer")
            {
                playTimer()
            }else
            {
                result.notImplemented()
            }
        }
    }
    private fun playTimer(){
        lateinit var tm: MediaPlayer
        tm = MediaPlayer.create(this,R.raw.timer)
        tm.isLooping = false
        tm.start()
        Handler().postDelayed(Runnable {
            tm.release()
        }, 4000)
    }
}
