package com.rmd.sipjni;

import android.app.Activity;
import android.widget.TextView;
import android.widget.Toast;
import android.os.Bundle;
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
        Thread th = new Thread() {
            @Override
            public void run(){
                startSipService();
            }
        };
        th.start();
    }

    public boolean onIncomingCall(String str)
    {
        Log.v(LOG_TAG, "onIncomingCall fired");
        Toast.makeText(this, str, 3);
        return true;
    }

    public native void startSipService();

    static {
        System.loadLibrary("osip");
        System.loadLibrary("exosip");
        System.loadLibrary("sip-jni");
    }
}
