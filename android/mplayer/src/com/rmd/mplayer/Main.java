package com.rmd.mplayer;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.VideoView;

public class Main extends Activity {

	private VideoView m_vvPlayer;

	/** Called when the activity is first created. */
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.main);

		m_vvPlayer = (VideoView) findViewById(R.id.vvMain);
		Button btnSelectFile = (Button) findViewById(R.id.btnSelectFile);
		btnSelectFile.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				Intent i = new Intent();
				i.setClass(v.getContext(), VideoSelector.class);
				startActivityForResult(i, 0);
			}
		});
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		if (RESULT_OK == resultCode) {
			Bundle bd = data.getExtras();
			String path = bd.getString(VideoSelector.FILE_PATH);
			m_vvPlayer.setVideoPath(path);
			m_vvPlayer.start();
		}
	}
}