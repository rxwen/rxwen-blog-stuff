package com.rmd.app2;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import android.os.RemoteException;
import android.util.Log;

import com.rmd.ISvcController;

public class App2Service extends Service {

	IBinder svcController = null;
	
	@Override
	public IBinder onBind(Intent intent) {
		Log.v("App2", "App2 service onBind.");
		if(null == svcController)
		{
			svcController = new ISvcController.Stub() {
				
				@Override
				public void foo(String arg) throws RemoteException {
					Log.v("App2Service", "foo fired with argument: " + arg);
				}
				
				@Override
				public void bar(String arg) throws RemoteException {
					Log.v("App2Service", "bar fired with argument: " + arg);
				}

				@Override
				public void func(int arg, String str) throws RemoteException {
					Log.v("App2Service", "func fired with argument: " + str);
				}
			};
		}
		Log.v("App2", "App2 service onBind.");
		Log.v("App2", svcController.getClass().toString() + "\t hash code: " + svcController.hashCode());
		return svcController;
	}

	public void onCreate() {
		super.onCreate();
		Log.v("App2", "App2 service create.");
	}
	@Override
	public void onDestroy() {
		super.onDestroy();
		Log.v("App2", "App2 service destroy.");
	}
	
	public void onStart(Intent intent, int startId) {
		
		Log.v("App2", "App2 service start.");
	};
	
	@Override
	public boolean onUnbind(Intent intent) {
		Log.v("App2", "App2 service onUnbind.");
	
		return super.onUnbind(intent);
	}
	
	@Override
	public void onRebind(Intent intent) {
		Log.v("App2", "App2 service rebind.");
	
		super.onRebind(intent);
	}
}
