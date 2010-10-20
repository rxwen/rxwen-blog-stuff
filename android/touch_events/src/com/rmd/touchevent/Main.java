package com.rmd.touchevent;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;

public class Main extends Activity {
	
	private static final String LOG_TAG = "Main";
	private ViewGroup m_root, m_level1_1, m_level1_2;
	private View m_level2_1, m_level2_2;
	
	private View.OnClickListener m_click_listener = new View.OnClickListener() {
		
		@Override
		public void onClick(View v) {
			Log.v(LOG_TAG, String.format("%d onClick event fired on %s", System.currentTimeMillis(), v.getTag()));
		}
	};
	
	private View.OnTouchListener m_touch_listener_true = new View.OnTouchListener() {
		
		@Override
		public boolean onTouch(View v, MotionEvent event) {
            if(event.getAction() != MotionEvent.ACTION_MOVE)
			Log.v(LOG_TAG, String.format(System.currentTimeMillis() + " onTouch event " + event.getAction()+ " fired on %s, returns true",v.getTag()));
			return true;
		}
	};

	private View.OnTouchListener m_touch_listener_false = new View.OnTouchListener() {
		
		@Override
		public boolean onTouch(View v, MotionEvent event) {
            if(event.getAction() != MotionEvent.ACTION_MOVE)
			Log.v(LOG_TAG, String.format(System.currentTimeMillis() + " onTouch event " + event.getAction()+ " fired on %s, returns false",v.getTag()));
			return false;
		}
	};
	
	private View.OnLongClickListener m_long_click_listener_true = new View.OnLongClickListener() {
		
		@Override
		public boolean onLongClick(View v) {
			Log.v(LOG_TAG, String.format(System.currentTimeMillis() + " OnLongClickListener event fired on %s, returns true",v.getTag()));
			return true;
		}
	};
	
	private View.OnLongClickListener m_long_click_listener_false = new View.OnLongClickListener() {
		
		@Override
		public boolean onLongClick(View v) {
			Log.v(LOG_TAG, String.format(System.currentTimeMillis() + " OnLongClickListener event fired on %s, returns false",v.getTag()));
			return false;
		}
	};
	
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        m_root = (ViewGroup)findViewById(R.id.root);
        m_level1_1 = (ViewGroup)findViewById(R.id.level1_1);
        m_level1_2 = (ViewGroup)findViewById(R.id.level1_2);
        m_level2_1 = findViewById(R.id.level2_1);
        m_level2_2 = findViewById(R.id.level2_2);        

        m_root.setTag("m_root");
        m_level1_1.setTag("m_level1_1");
        m_level1_2.setTag("m_level1_2");
        m_level2_1.setTag("m_level2_1");
        m_level2_2.setTag("m_level2_2");
        m_level2_2.setLongClickable(false);
        
        m_root.setOnClickListener(m_click_listener);
        m_level1_1.setOnClickListener(m_click_listener);
        m_level1_2.setOnClickListener(m_click_listener);
        m_level2_1.setOnClickListener(m_click_listener);
        m_level2_2.setOnClickListener(m_click_listener);
        
        m_root.setOnTouchListener(m_touch_listener_false);
        m_level1_1.setOnTouchListener(m_touch_listener_true);
        m_level1_2.setOnTouchListener(m_touch_listener_false);
        m_level2_1.setOnTouchListener(m_touch_listener_false);
        m_level2_2.setOnTouchListener(m_touch_listener_false);

        m_root.setOnLongClickListener(m_long_click_listener_true);
        m_level1_1.setOnLongClickListener(m_long_click_listener_true);
        m_level1_2.setOnLongClickListener(m_long_click_listener_true);
        m_level2_1.setOnLongClickListener(m_long_click_listener_false);
        m_level2_2.setOnLongClickListener(m_long_click_listener_false);
    }
}
