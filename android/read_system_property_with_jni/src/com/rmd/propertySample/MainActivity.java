package com.rmd.propertySample;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.widget.TextView;

public class MainActivity extends Activity
{
    private static String LOG_TAG = "read_property.MainActivity";
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        TextView tv = (TextView)findViewById(R.id.tvPropertyValue);
        String name = "net.dns1";
        String value = getProperty(name);
        tv.setText(tv.getText() + "\n" + name + ": " + value);

        Log.v(LOG_TAG, "getProperty returns "+value);
    }

    public native String getProperty(String name);
    public native void setProperty(String name, String value);
    static {
        try {
            Log.v(LOG_TAG, "Main static initializer, load syspropertylibrary");
            System.loadLibrary("sysproperty");
        }
        catch (UnsatisfiedLinkError ex) {
            Log.v(LOG_TAG, "UnsatisfiedLinkError ");
        }
    }
}

