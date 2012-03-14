package rmd.media.StreamingAudio;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.security.InvalidParameterException;

import java.net.InetAddress;
import java.net.DatagramSocket;
import java.net.DatagramPacket;
import java.net.SocketException;
import java.net.UnknownHostException;

import android.app.Activity;
import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.util.Log;

/** UdpStream activity sends and recv audio data through udp */
public class UdpStream extends Activity {
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.udpstream);
        Button btnSend = (Button)findViewById(R.id.btnSend);
        btnSend.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
                Log.d(LOG_TAG, "btnSend clicked");
                SendAudio();
			}
		});

        Button btnRecv = (Button)findViewById(R.id.btnRecv);
        btnRecv.setOnClickListener(new OnClickListener() {
			
			@Override
			public void onClick(View v) {
                Log.d(LOG_TAG, "btnRecv clicked");
                RecvAudio();
			}
		});
        
    }

    static final String LOG_TAG = "UdpStream";
    static final String AUDIO_FILE_PATH = "/sdcard/1.wav";
    static final int AUDIO_PORT = 2048;
    static final int SAMPLE_RATE = 8000;
    static final int SAMPLE_INTERVAL = 20; // milliseconds
    static final int SAMPLE_SIZE = 2; // bytes per sample
    static final int BUF_SIZE = SAMPLE_INTERVAL*SAMPLE_INTERVAL*SAMPLE_SIZE*2;
    
    public void RecvAudio()
    {
        Thread thrd = new Thread(new Runnable() {
			@Override
            public void run() 
            {
                Log.e(LOG_TAG, "start recv thread, thread id: "
                    + Thread.currentThread().getId());
                AudioTrack track = new AudioTrack(AudioManager.STREAM_MUSIC, 
                        SAMPLE_RATE, AudioFormat.CHANNEL_CONFIGURATION_MONO, 
                        AudioFormat.ENCODING_PCM_16BIT, BUF_SIZE, 
                        AudioTrack.MODE_STREAM);
                track.play();
                try
                {
                    DatagramSocket sock = new DatagramSocket(AUDIO_PORT);
                    byte[] buf = new byte[BUF_SIZE];

                    while(true)
                    {
                        DatagramPacket pack = new DatagramPacket(buf, BUF_SIZE);
                        sock.receive(pack);
                        Log.d(LOG_TAG, "recv pack: " + pack.getLength());
                        track.write(pack.getData(), 0, pack.getLength());
                    }
                }
                catch (SocketException se)
                {
                    Log.e(LOG_TAG, "SocketException: " + se.toString());
                }
                catch (IOException ie)
                {
                    Log.e(LOG_TAG, "IOException" + ie.toString());
                }
            } // end run
        });
        thrd.start();
    }

    public void SendAudio()
    {
        Thread thrd = new Thread(new Runnable() {
			@Override
            public void run() 
            {
                Log.e(LOG_TAG, "start send thread, thread id: "
                    + Thread.currentThread().getId());
                long file_size = 0;
                int bytes_read = 0;
                int bytes_count = 0;
                File audio = new File(AUDIO_FILE_PATH);
                FileInputStream audio_stream = null;
                file_size = audio.length();
                byte[] buf = new byte[BUF_SIZE];
                try
                {
                    InetAddress addr = InetAddress.getLocalHost();
                    DatagramSocket sock = new DatagramSocket();
                    audio_stream = new FileInputStream(audio);

                    while(bytes_count < file_size)
                    {
                        bytes_read = audio_stream.read(buf, 0, BUF_SIZE);
                        DatagramPacket pack = new DatagramPacket(buf, bytes_read,
                                addr, AUDIO_PORT);
                        sock.send(pack);
                        bytes_count += bytes_read;
                        Log.d(LOG_TAG, "bytes_count : " + bytes_count);
                        Thread.sleep(SAMPLE_INTERVAL, 0);
                    }
                }
                catch (InterruptedException ie)
                {
                    Log.e(LOG_TAG, "InterruptedException");
                }
                catch (FileNotFoundException fnfe)
                {
                    Log.e(LOG_TAG, "FileNotFoundException");
                }
                catch (SocketException se)
                {
                    Log.e(LOG_TAG, "SocketException");
                }
                catch (UnknownHostException uhe)
                {
                    Log.e(LOG_TAG, "UnknownHostException");
                }
                catch (IOException ie)
                {
                    Log.e(LOG_TAG, "IOException");
                }
            } // end run
        });
        thrd.start();
    }
    
}
