package com.rmd.touchevent;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.LinearLayout;
import android.view.MotionEvent;

public class MyViewGroup extends LinearLayout
{
    public MyViewGroup(Context context, AttributeSet attrs)
    {
        super(context, attrs);
    }

    @Override
    public boolean onInterceptTouchEvent(MotionEvent event)
    {
        return false;
    }
}
