package com.rmd.mplayer;

import android.app.ListActivity;
import android.content.ContentResolver;
import android.content.Intent;
import android.database.Cursor;
import android.os.Bundle;
import android.provider.MediaStore;
import android.view.View;
import android.widget.ListView;
import android.widget.SimpleCursorAdapter;

public class VideoSelector extends ListActivity {

    public static final String FILE_PATH = "FILE_PATH";	
    public void onCreate(Bundle icicle)
    {
        super.onCreate(icicle);
        init();
    }

    public void init() {
        setContentView(R.layout.video_selector);

        MakeCursor();

        // Map Cursor columns to views defined in media_list_item.xml
        SimpleCursorAdapter adapter = new SimpleCursorAdapter(
                this,
                android.R.layout.simple_list_item_1,
                mCursor,
                new String[] { MediaStore.Video.Media.TITLE},
                new int[] { android.R.id.text1 });

        setListAdapter(adapter);
    }

    @Override
    protected void onListItemClick(ListView l, View v, int position, long id)
    {
    	String filePath = mCursor.getString(mCursor.getColumnIndex(MediaStore.Video.Media.DATA));
        mCursor.moveToPosition(position);
        Intent result = new Intent();
		result.putExtra(FILE_PATH, filePath);
        setResult(RESULT_OK, result);
        finish();
    }

    private void MakeCursor() {
        String[] cols = new String[] {
                MediaStore.Video.Media._ID,
                MediaStore.Video.Media.TITLE,
                MediaStore.Video.Media.DATA,
                MediaStore.Video.Media.MIME_TYPE,
                MediaStore.Video.Media.ARTIST
        };
        ContentResolver resolver = getContentResolver();
        if (resolver == null) {
            System.out.println("resolver = null");
        } else {
            mSortOrder = MediaStore.Video.Media.TITLE + " COLLATE UNICODE";
            mWhereClause = MediaStore.Video.Media.TITLE + " != ''";
            mCursor = resolver.query(MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
                cols, mWhereClause , null, mSortOrder);
        }
    }

    private Cursor mCursor;
    private String mWhereClause;
    private String mSortOrder;
}
