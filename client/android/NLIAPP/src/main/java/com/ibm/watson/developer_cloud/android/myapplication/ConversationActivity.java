package com.ibm.watson.developer_cloud.android.myapplication;

import android.app.AlertDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.RadioGroup;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.ibm.watson.developer_cloud.android.library.audio.MicrophoneInputStream;
import com.ibm.watson.developer_cloud.android.library.audio.StreamPlayer;
import com.ibm.watson.developer_cloud.android.library.audio.utils.ContentType;
import com.ibm.watson.developer_cloud.android.library.camera.CameraHelper;
import com.ibm.watson.developer_cloud.android.library.camera.GalleryHelper;
import com.ibm.watson.developer_cloud.language_translation.v2.LanguageTranslation;
import com.ibm.watson.developer_cloud.language_translation.v2.model.Language;
import com.ibm.watson.developer_cloud.speech_to_text.v1.SpeechToText;
import com.ibm.watson.developer_cloud.speech_to_text.v1.model.RecognizeOptions;
import com.ibm.watson.developer_cloud.speech_to_text.v1.model.SpeechResults;
import com.ibm.watson.developer_cloud.speech_to_text.v1.websocket.RecognizeCallback;
import com.ibm.watson.developer_cloud.text_to_speech.v1.TextToSpeech;
import com.ibm.watson.developer_cloud.text_to_speech.v1.model.Voice;

import org.eclipse.paho.client.mqttv3.MqttException;

import java.io.FileNotFoundException;
import java.io.InputStream;
import java.util.ArrayList;

import app.IoTStarterApplication;
import iot.IoTClient;
import utils.Constants;
import utils.MessageFactory;
import utils.MyIoTActionListener;

/**
 * Created by babagouda_biradar on 11/15/2016.
 */
public class ConversationActivity extends AppCompatActivity {
    AppInfo mAPPinfo = AppInfo.getInstance();
    private final String TAG = "LOgin";
    private RadioGroup targetLanguage;
    private EditText input;
    private ImageButton mic;
    private Button translate;
    private ImageButton play;
    private TextView translatedText;
    private Button gallery;
    private Button camera;
    private ImageView loadedImage;
    double lon = 0.0;
    double lat = 0.0;
    private SpeechToText speechService;
    private TextToSpeech textService;
    private LanguageTranslation translationService;
    private Language selectedTargetLanguage = Language.ENGLISH;

    private StreamPlayer player = new StreamPlayer();
    private CameraHelper cameraHelper;
    private GalleryHelper galleryHelper;

    private MicrophoneInputStream capture;
    private boolean listening = false;


    ArrayList<String> mobileArray;
    ArrayList<String> mResponseArray;
    private ListView mChatListView;
    // ArrayAdapter<String> adapter;


    private static String payload;

    ArrayList<DataModel> dataModels;

    private static CustomAdapter adapter;


    private IoTStarterApplication app;
    private BroadcastReceiver broadcastReceiver;
    SharedPreferences pref;
    SharedPreferences.Editor editor;
    ImageButton settings;
    String hexcolor,title;
    String logouri;
    Handler handler = new Handler();
    MediaPlayer mp;
    ImageView imageView;
    Uri path;
    Bitmap yourSelectedImage1;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        ActionBar actionBar = getSupportActionBar();
        actionBar.hide();

        pref = getApplicationContext().getSharedPreferences("MyPref", MODE_PRIVATE);
        editor = pref.edit();
        hexcolor=pref.getString("hexcolor", null);
        title=pref.getString("title",null);
        logouri=pref.getString("logouri",null);
        if(logouri!=null&&!logouri.isEmpty()){

             path=Uri.parse(logouri);
            InputStream imageStream1 = null;
            try {
                imageStream1 = getContentResolver().openInputStream(path);
            } catch (FileNotFoundException e) {
                e.printStackTrace();
            }
             yourSelectedImage1 = BitmapFactory.decodeStream(imageStream1);
        }


        imageView=(ImageView)findViewById(R.id.logo);
        TextView titleView=(TextView)findViewById(R.id.titleapp);
        RelativeLayout relativeLayout=(RelativeLayout)findViewById(R.id.topbar);
        ImageButton ib=(ImageButton)findViewById(R.id.mic);
        try{

            if(logouri!=null&&!logouri.isEmpty()){

                imageView.setImageBitmap(yourSelectedImage1);
            }else{
                imageView.setBackgroundResource(R.drawable.logo);
            }

            if(title!=null&&!title.isEmpty()){

                titleView.setText(title);
            }else{
                titleView.setText("Natural Language Interface");
            }


            relativeLayout.setBackgroundColor(Color.parseColor(hexcolor));

            ib.setBackgroundColor(Color.parseColor(hexcolor));
        }catch (StringIndexOutOfBoundsException e){
            e.printStackTrace();
        }


        mp = MediaPlayer.create(this, R.raw.listening_sound);

        cameraHelper = new CameraHelper(this);
        galleryHelper = new GalleryHelper(this);

        speechService = initSpeechToTextService();
        textService = initTextToSpeechService();
        translationService = initLanguageTranslationService();

        targetLanguage = (RadioGroup) findViewById(R.id.target_language);
        input = (EditText) findViewById(R.id.input);
        mic = (ImageButton) findViewById(R.id.mic);
        translate = (Button) findViewById(R.id.translate);
        play = (ImageButton) findViewById(R.id.play);
        translatedText = (TextView) findViewById(R.id.translated_text);
        gallery = (Button) findViewById(R.id.gallery_button);
        camera = (Button) findViewById(R.id.camera_button);
        loadedImage = (ImageView) findViewById(R.id.loaded_image);
        settings = (ImageButton) findViewById(R.id.settings);
        mobileArray = new ArrayList<String>();
        /*
        * called the settings screen
        * */
        settings.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                try {

                    MyIoTActionListener listener = new MyIoTActionListener(ConversationActivity.this, Constants.ActionStateStatus.PUBLISH);
                    IoTClient iotClient = IoTClient.getInstance(ConversationActivity.this);
                    iotClient.disconnectDevice(listener);
                } catch (MqttException e) {
                }
              //  pref.edit().clear().commit();
                Intent i = new Intent(ConversationActivity.this, com.ibm.watson.developer_cloud.android.myapplication.settings.class);
                startActivity(i);


            }
        });
        /*
        * Display chart History
        * created Cutomized Listview.
        * */
        mResponseArray = new ArrayList<String>();
        mChatListView = (ListView) findViewById(R.id.chatlist);
        dataModels = new ArrayList<>();
        adapter = new CustomAdapter(dataModels, getApplicationContext());
        mChatListView.setAdapter(adapter);

        /*
        *
        *
        *
        * */
        mic.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //mic.setEnabled(false);
                String item = input.getText().toString();

            if(input.getText().toString().trim().length() > 0){


                dataModels.add(new DataModel(item, "", "", ""));
                sendTexttoWiot(item);
                adapter.notifyDataSetChanged();
                handler.postDelayed(new Runnable() {
                    public void run() {
                        // do something
                        input.setText("");

                        dataModels.add(new DataModel("", app.getPayload(), "", ""));
                        adapter.notifyDataSetChanged();

                        new SynthesisTask().execute(app.getPayload());

                    }
                }, 1000);
            }

            }

        });
        mic.setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                mp.start();
                if (listening != true) {
                    capture = new MicrophoneInputStream(true);
                    new Thread(new Runnable() {
                        @Override
                        public void run() {
                            try {
                               // speechService.recognizeUsingWebSockets(capture, getRecognizeOptions(), new MicrophoneRecognizeDelegate());
                                speechService.recognizeUsingWebSocket(capture, getRecognizeOptions(), new MicrophoneRecognizeDelegate());

                            } catch (Exception e) {
                                showError(e);
                            }
                        }
                    }).start();
                    listening = true;
                }
                return true;
            }
        });
        mic.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                if (event.getAction() == MotionEvent.ACTION_UP) {
                    // We're only interested in anything if our speak button is currently pressed.


                    if (listening) {
                        // Do something when the button is released.
                        try {
                            capture.close();
                            listening = false;
                            if(input.getText().toString().trim().length() > 0) {

                                String item = input.getText().toString();

                                dataModels.add(new DataModel(item, "", "", ""));
                                sendTexttoWiot(item);
                                adapter.notifyDataSetChanged();

                                handler.postDelayed(new Runnable() {
                                    public void run() {
                                        // do something
                                        input.setText("");

                                        dataModels.add(new DataModel("", app.getPayload(), "", ""));
                                        adapter.notifyDataSetChanged();

                                        new SynthesisTask().execute(app.getPayload());

                                    }
                                }, 1000);
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                }
                return false;
            }
        });

    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.menu, menu);
        return true;
    }

    /*
    *
    * On resume get called.
    * */
    @Override
    public void onResume() {
        Log.d(TAG, ".onResume() entered");

        super.onResume();


        app = (IoTStarterApplication) getApplication();
        app.setCurrentRunningActivity(TAG);

        if (app.getCurrentLocation() != null) {
            lon = app.getCurrentLocation().getLongitude();
            lat = app.getCurrentLocation().getLatitude();
        }

        if (broadcastReceiver == null) {
            Log.d(TAG, ".onResume() - Registering LogBroadcastReceiver");
            broadcastReceiver = new BroadcastReceiver() {

                @Override
                public void onReceive(Context context, Intent intent) {
                    Log.d(TAG, ".onReceive() - Received intent for logBroadcastReceiver");
                    processIntent(intent);
                }
            };
        }

        getApplicationContext().registerReceiver(broadcastReceiver,
                new IntentFilter(Constants.APP_ID + Constants.INTENT_PROFILES));

        // initialise
        //initializeProfilesActivity();

    }
    /*
    * this is the method sending text msg to IOTP.
    *
    * */

    private void sendTexttoWiot(String message) {

        String messageData = MessageFactory.getTextMessage(message);
        try {
            // create ActionListener to handle message published results
            MyIoTActionListener listener = new MyIoTActionListener(this, Constants.ActionStateStatus.PUBLISH);
            IoTClient iotClient = IoTClient.getInstance(this);
            iotClient.publishEvent(Constants.TEXT_EVENT, "json", messageData, 0, false, listener);


            //iotClient.publishCommand(Constants.TEXT_EVENT, "json", messageData, 0, false, listener);

            int count = app.getPublishCount();
            app.setPublishCount(++count);

            String runningActivity = app.getCurrentRunningActivity();
            if (runningActivity != null && runningActivity.equals(ConversationActivity.class.getName())) {
                Intent actionIntent = new Intent(Constants.APP_ID + Constants.INTENT_IOT);
                actionIntent.putExtra(Constants.INTENT_DATA, Constants.INTENT_DATA_PUBLISHED);
                sendBroadcast(actionIntent);
            }
        } catch (MqttException e) {
            // Publish failed
        }

    }

    private void showTranslation(final String translation) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                translatedText.setText(translation);
            }
        });
    }

    private void showError(final Exception e) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {

                Toast.makeText(ConversationActivity.this, e.getMessage(),Toast.LENGTH_SHORT ).show();
                //e.printStackTrace();
            }
        });
    }

    private void showMicText(final String text) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                input.setText(text);
            }
        });
    }

    private void enableMicButton() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mic.setEnabled(true);
            }
        });
    }

    /*
    * thes all usernsme and password of the STT  amn TTS.
    * */

   /* String username =pref.getString("TTSUSRNM", null);
    String password =pref.getString("TTSPSS", null);
    String username =pref.getString("STTUSERNM", null);
    String password =pref.getString("STTPASS", null);*/
  /* String username = getString(R.string.speech_text_username);
    String password = getString(R.string.speech_text_password);
    String username = getString(R.string.text_speech_username);
    String password = getString(R.string.text_speech_password);*/

    private SpeechToText initSpeechToTextService() {
        SpeechToText service = new SpeechToText();
        String username =pref.getString("STTUSERNM", null);
        String password =pref.getString("STTPASS", null);
        service.setUsernameAndPassword(username, password);
        service.getCustomization(pref.getString("customstt",null));
        service.setEndPoint("https://stream.watsonplatform.net/speech-to-text/api");
        return service;
    }

    private TextToSpeech initTextToSpeechService() {
        TextToSpeech service = new TextToSpeech();
        String username =pref.getString("TTSUSRNM", null);
        String password =pref.getString("TTSPSS", null);
        service.setUsernameAndPassword(username, password);
        service.setEndPoint("https://stream.watsonplatform.net/text-to-speech/api");
        return service;
    }

    private LanguageTranslation initLanguageTranslationService() {
        LanguageTranslation service = new LanguageTranslation();
        String username = getString(R.string.language_translation_username);
        String password = getString(R.string.language_translation_password);
        service.setUsernameAndPassword(username, password);
        service.setEndPoint("https://gateway.watsonplatform.net/language-translation/api");
        return service;
    }


    private RecognizeOptions getRecognizeOptions() {
        return new RecognizeOptions.Builder()
                .continuous(true)
                .contentType(ContentType.OPUS.toString())
                .model("en-US_BroadbandModel")
                .interimResults(true)
                .inactivityTimeout(2000)
                .build();
    }

    private void processIntent(Intent intent) {
        Log.d(TAG, ".processIntent() entered");

        String data = intent.getStringExtra(Constants.INTENT_DATA);
        assert data != null;
        //listAdapter.notifyDataSetInvalidated();

        if (data.equals(Constants.ALERT_EVENT)) {
            String message = intent.getStringExtra(Constants.INTENT_DATA_MESSAGE);
            new AlertDialog.Builder(this)
                    .setTitle(getResources().getString(R.string.alert_dialog_title))
                    .setMessage(message)
                    .setPositiveButton(getResources().getString(R.string.ok), new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int whichButton) {
                        }
                    }).show();
        }
    }

    private abstract class EmptyTextWatcher implements TextWatcher {
        private boolean isEmpty = true; // assumes text is initially empty

        @Override public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

        @Override public void onTextChanged(CharSequence s, int start, int before, int count) {
            if (s.length() == 0) {
                isEmpty = true;
                onEmpty(true);
            } else if (isEmpty) {
                isEmpty = false;
                onEmpty(false);
            }
        }

        @Override public void afterTextChanged(Editable s) {}

        public abstract void onEmpty(boolean empty);
    }

    private class MicrophoneRecognizeDelegate implements RecognizeCallback {

        @Override
        public void onTranscription(SpeechResults speechResults) {
            System.out.println(speechResults);
            String text = speechResults.getResults().get(0).getAlternatives().get(0).getTranscript();
            showMicText(text);
        }

        @Override public void onConnected() {

        }

        @Override public void onError(Exception e) {
            showError(e);
            enableMicButton();
        }

        @Override public void onDisconnected() {
            enableMicButton();
        }
    }

    private class TranslationTask extends AsyncTask<String, Void, String> {

        @Override protected String doInBackground(String... params) {
            showTranslation(translationService.translate(params[0], Language.ENGLISH, selectedTargetLanguage).execute().getFirstTranslation());
            return "Did translate";
        }
    }

    private class SynthesisTask extends AsyncTask<String, Void, String> {

        @Override protected String doInBackground(String... params) {
            player.playStream(textService.synthesize(params[0], Voice.EN_MICHAEL).execute());
            return "Did synthesize";
        }
    }

   /* @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        switch (requestCode) {
            case CameraHelper.REQUEST_PERMISSION: {
                // permission granted
                if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    cameraHelper.dispatchTakePictureIntent();
                }
            }
        }
    }*/

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode == CameraHelper.REQUEST_IMAGE_CAPTURE) {
            loadedImage.setImageBitmap(cameraHelper.getBitmap(resultCode));
        }

        if (requestCode == GalleryHelper.PICK_IMAGE_REQUEST) {
            loadedImage.setImageBitmap(galleryHelper.getBitmap(resultCode, data));
        }
    }
    public void onBackPressed() {
        Intent startMain = new Intent(Intent.ACTION_MAIN);
        startMain.addCategory(Intent.CATEGORY_HOME);
        startMain.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(startMain);

    }
}
