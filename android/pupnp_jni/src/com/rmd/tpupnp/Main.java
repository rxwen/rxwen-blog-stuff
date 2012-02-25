package com.rmd.tpupnp;

import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;
import android.util.Log;

public class Main extends Activity
{
    private static String LOG_TAG = "tpupnp";
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        TextView tv = new TextView(this); //(TextView)findViewById(R.id.tvMain);
        if(null == tv)
            Log.v(LOG_TAG, "tv is null");

        if(0 == startUpnp())
            tv.setText("start successed");
        else
            tv.setText("start failed"); 
        setContentView(tv);
    }
    public native int startUpnp();
    public native String  stringFromJNI();
    static {
        Log.v(LOG_TAG, "Main static initializer, load pupnp library");
        System.loadLibrary("pupnp");
    }
}
