package com.rmd;

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

public class App1Main extends Activity {
	/** Called when the activity is first created. */
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.main);
		
		Button btnStartAct = (Button) findViewById(R.id.btnStartAct);
		btnStartAct.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				Intent i = new Intent("com.rmd.app2act");
				v.getContext().startActivity(i);
			}
		});
		Button btnStartSvc = (Button) findViewById(R.id.btnStartSvc);
		btnStartSvc.setOnClickListener(new View.OnClickListener() {
			public void onClick(View v) {
				Intent i = new Intent("com.rmd.app2svc");
				ServiceConnection con = new ServiceConnection() {
					
					@Override
					public void onServiceDisconnected(ComponentName name) {
						Log.v("App1", "App1Main Service Disconnected.");
					}
					
					@Override
					public void onServiceConnected(ComponentName name, IBinder service) {
						Log.v("App1", "App1Main Service Connected.");
						Log.v("App1", service.getClass().toString());
						ISvcController svc = ISvcController.Stub.asInterface(service);
						try{
						svc.foo("hello");
						svc.bar("raymond");}
						catch(RemoteException ex)
						{
							
						}
					}
				};
				v.getContext().bindService(i, con,  Context.BIND_AUTO_CREATE);
			}
		});
	}

}