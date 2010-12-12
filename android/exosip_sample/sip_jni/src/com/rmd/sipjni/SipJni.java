package com.rmd.sipjni;

import android.app.Activity;
import android.widget.TextView;
import android.os.Bundle;


public class SipJni extends Activity
{
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

    public native void startSipService();

    static {
        System.loadLibrary("osip");
        System.loadLibrary("exosip");
        System.loadLibrary("sip-jni");
    }
}
