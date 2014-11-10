package com.rmd.sipjni;

import android.app.Activity;
import android.widget.TextView;
import android.widget.Toast;
import android.os.Bundle;
import android.os.Looper;
import android.util.Log;

public class SipJni extends Activity
{
    static final String LOG_TAG = "SipJni";
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);

        TextView  tv = new TextView(this);
        setContentView(tv);
        // sip service is a infinite loop
        // so run start a separate thread to run it
        Thread th = new Thread() {
            @Override
            public void run(){
                // call Looper.prepare so that this thread can accept message
               // Looper.prepare();
                startSipService();
            }
        };
        th.start();
    }

    public boolean onIncomingCall(String str)
    {
        Log.v(LOG_TAG, "onIncomingCall fired: " + str);
        // show Toast on ui thread
        this.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Toast.makeText(SipJni.this, "Incoming call", 5).show();
            }
        });
        return true;
    }

    public native void startSipService();

    static {
        // load needed libraries
        System.loadLibrary("osip");
        System.loadLibrary("exosip");
        System.loadLibrary("sip-jni");
    }
}
