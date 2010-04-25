package rmd.media.StreamingAudio;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.security.InvalidParameterException;

import android.app.Activity;
import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;

public class Main extends Activity {
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        Button btnStatic = (Button)findViewById(R.id.btnStatic);
        btnStatic.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				PlayAudio(AudioTrack.MODE_STATIC);
			}
		});
        

        Button btnStream = (Button)findViewById(R.id.btnStream);
        btnStream.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
				PlayAudio(AudioTrack.MODE_STREAM);
				
			}
		});
        
    }
    
    private void PlayAudio(int mode)
    {
    	if(AudioTrack.MODE_STATIC != mode && AudioTrack.MODE_STREAM != mode)
    		throw new InvalidParameterException();

    	String audioFilePath = "/data/1.wav";
    	long fileSize = 0;
    	long bytesWritten = 0;
    	int bytesRead = 0;
    	int bufferSize = 0;
    	byte[] buffer;
    	AudioTrack track;
    	
		File audioFile = new File(audioFilePath);
		fileSize = audioFile.length();
    	if(AudioTrack.MODE_STREAM == mode)
    	{
    		bufferSize = 8000;
    	}
    	else
    	{// AudioTrack.MODE_STATIC
    		bufferSize = (int)fileSize;
    	}
    	buffer = new byte[bufferSize];
    	track = new AudioTrack(AudioManager.STREAM_MUSIC, 44100, 
 				AudioFormat.CHANNEL_CONFIGURATION_MONO, AudioFormat.ENCODING_PCM_16BIT, 
 				bufferSize, mode);
    	// in stream mode, 
    	//   1. start track playback
    	//   2. write data to track
    	if(AudioTrack.MODE_STREAM == mode)
    		track.play(); 
    	FileInputStream audioStream = null;
    	try {
			audioStream = new FileInputStream(audioFile);
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}
    	
    	while(bytesWritten < fileSize)
    	{
    		try {
    			bytesRead = audioStream.read(buffer, 0, bufferSize);
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
    		bytesWritten += track.write(buffer, 0, bytesRead);
    	}
    	// in static mode,
    	//   1. write data to track
    	//   2. start track playback
    	if(AudioTrack.MODE_STATIC == mode)
    		track.play();
    }
    
}