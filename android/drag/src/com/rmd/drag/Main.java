package com.rmd.drag;

import android.app.Activity;
import android.os.Bundle;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;

public class Main extends Activity {
	private View selected_item = null;
	private int offset_x = 0;
	private int offset_y = 0;
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        ViewGroup container = (ViewGroup)findViewById(R.id.container);
        container.setOnTouchListener(new View.OnTouchListener() {
			
			@Override
			public boolean onTouch(View v, MotionEvent event) {
				switch(event.getActionMasked())
				{
					case MotionEvent.ACTION_MOVE:
						int x = (int)event.getX() - offset_x;
						int y = (int)event.getY() - offset_y;
				         LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
	                                new ViewGroup.MarginLayoutParams(
	                                                LinearLayout.LayoutParams.WRAP_CONTENT,
	                                                LinearLayout.LayoutParams.WRAP_CONTENT));
				         lp.setMargins(x, y, 0, 0);

						selected_item.setLayoutParams(lp);
						break;
					default:
						break;
				}
				return true;
			}
		});
        
        ImageView img = (ImageView)findViewById(R.id.img);
        img.setOnTouchListener(new View.OnTouchListener() {
			
			@Override
			public boolean onTouch(View v, MotionEvent event) {
				switch(event.getActionMasked())
				{
					case MotionEvent.ACTION_DOWN:
						offset_x = (int)event.getX();
						offset_y = (int)event.getY();
						selected_item = v;
						break;
					default:
						break;
				}
				// return false to ignore further MotionEvents 
				// and give the parent a chance to handle MotionEvent
				return false;
			}
		});
    }
}