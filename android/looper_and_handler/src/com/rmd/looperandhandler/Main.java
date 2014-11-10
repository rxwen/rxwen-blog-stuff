package com.rmd.looperandhandler;

import android.app.Activity;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

public class Main extends Activity {
    /** Called when the activity is first created. */
	private final String LOG_TAG = "LOOPER_AND_HANDLER";
	private Handler m_handler1, m_handler2;
	private TextView m_show_text;
	private Button m_send_message1, m_send_message2, m_send_runnable;

    private Handler.Callback m_handler_callback =new Handler.Callback() {
		
		@Override
		public boolean handleMessage(Message msg) {
			Log.v(LOG_TAG, "m_handler_callback handleMessage fired");
			m_show_text.setText((String)msg.obj);
			return true;
		}
	};
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        
        m_show_text = (TextView)findViewById(R.id.showText);
        m_send_message1 = (Button)findViewById(R.id.sendMessage1);
        m_send_message2 = (Button)findViewById(R.id.sendMessage2);
        m_send_runnable = (Button)findViewById(R.id.sendRunnable);
        
        // handler1 and handler2 both associated with main looper
        m_handler1 = new Handler()
        {
        	public void handleMessage(android.os.Message msg) {
        		Log.v(LOG_TAG, "m_handler1 handleMessage fired");
        		m_show_text.setText((String)msg.obj);
        	}
        }; 
        m_handler2 = new Handler(m_handler_callback);
        
        // *** 1 *** send message to handler 1
        m_send_message1.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View v) {
				new Thread(){
					public void run() {
						Message msg = m_handler1.obtainMessage(1, 2, 3, "new message for handler 1");
						m_handler1.sendMessage(msg);
					} // end run()
				}.start(); // end new Thread
			}// end onClick
		}); // end m_send_message1.setOnClickListener

        // *** 2 *** send message to handler 2
        m_send_message2.setOnClickListener(new View.OnClickListener() {
			
			@Override
			public void onClick(View v) {
				new Thread(){
					public void run() {
						Message msg = m_handler2.obtainMessage(1, 2, 3, "new message for handler 2");
						m_handler2.sendMessage(msg);
					} // end run()
				}.start(); // end new Thread()
			} // end onClick
		}); // end m_send_message2.setOnClickListener
        
        // *** 3 *** send runnable to handler2
        m_send_runnable.setOnClickListener(new View.OnClickListener() {
        	@Override
        	public void onClick(View v) {
        		new Thread(){
        			public void run()
        			{
        				m_handler2.post(new Runnable() {
							public void run() {
								m_show_text.setText("runnable for handler 2");
							} // end runnable.run
        				}); // end m_handler2.post
        			}; // end thread.run
        		}.start();// end new Thread
        	} // end onClick
        }); // end m_send_runnable.setOnClickListener
        
    }
     
}