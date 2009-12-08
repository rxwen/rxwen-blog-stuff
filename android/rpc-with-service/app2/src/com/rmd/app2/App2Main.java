package com.rmd.app2;

import com.rmd.ISvcController;

import android.app.Activity;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Bundle;
import android.os.IBinder;
import android.os.RemoteException;
import android.util.Log;
import android.view.View;
import android.widget.Button;

public class App2Main extends Activity {
	/** Called when the activity is first created. */
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.main);
		Log.v("App2", "App2Main activity create.");
		
		Button btnStartSelf = (Button) findViewById(R.id.btnStartSelf);
		btnStartSelf.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				Intent i = new Intent(v.getContext(), App2Service.class);
//				v.getContext().startActivity(i);
				ServiceConnection con = new ServiceConnection() {
					
					@Override
					public void onServiceDisconnected(ComponentName name) {
						Log.v("App2", "App2Main Service Disconnected");
					}
					
					@Override
					public void onServiceConnected(ComponentName name, IBinder service) {
						Log.v("App2", "App2Main Service Connected.");
						Log.v("App2", service.getClass().toString());
						ISvcController svc = ISvcController.Stub.asInterface(service);
						try{
						svc.foo("hello");
						svc.bar("raymond");}
						catch(RemoteException ex)
						{
							
						}
					}
				};
				v.getContext().bindService(i, con, Context.BIND_AUTO_CREATE);//.startService(i);
//				v.getContext().unbindService(con);
			}
		});

	}

}