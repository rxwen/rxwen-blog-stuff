package com.rmd.drag;

import android.content.Context;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.widget.LinearLayout;

public class TouchInterceptor extends LinearLayout {

	public TouchInterceptor(Context context, AttributeSet attrs) {
		super(context, attrs);
	}
	
	@Override
	public boolean onInterceptTouchEvent(MotionEvent ev) {
		
		return super.onInterceptTouchEvent(ev);
	}

}
