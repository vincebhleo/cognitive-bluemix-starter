package com.ibm.watson.developer_cloud.android.myapplication;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.text.InputType;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.gms.security.ProviderInstaller;

import org.eclipse.paho.client.mqttv3.MqttException;

import java.io.FileNotFoundException;
import java.io.InputStream;
import java.security.KeyStore;
import java.sql.Timestamp;
import java.util.Date;

import javax.net.SocketFactory;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import javax.net.ssl.TrustManagerFactory;

import app.IoTStarterApplication;
import iot.IoTClient;
import utils.Constants;
import utils.DeviceSensor;
import utils.LocationUtils;
import utils.MyIoTActionListener;

/**
 * Created by babagouda_biradar on 11/25/2016.
 */
public class settings extends Activity {
    private final String TAG = "settings";




    AppInfo mAPPinfo = AppInfo.getInstance();
    Button mbtnSettings;
    Handler handler = new Handler();

    String morganization, mDeviceid, mAuthToken;
    ProgressDialog pd;
    String mSTTunm,mSTTpwd,mTTSunm,mTTSpwd;

    Button savebuttons,btnshow;
    SharedPreferences pref;
    SharedPreferences.Editor editor;
    EditText mSTTUSR,mSTTPASS,mTTSUSR,mTTSPASS,org,deviceid,auth,hexcolor,titleAppSet;
   ImageButton imageButton;
    private IoTStarterApplication app;
    private BroadcastReceiver broadcastReceiver;
    String logouri,color;
    private static final int SELECT_PHOTO = 100;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.save_credentilas);
        app = (IoTStarterApplication) this.getApplication();
        app.setCurrentRunningActivity(TAG);
        pref=getApplicationContext().getSharedPreferences("MyPref", MODE_PRIVATE);
        editor = pref.edit();

        imageButton=(ImageButton)findViewById(R.id.logobuttonsetting);
        imageButton.setOnClickListener(imgButtonHandler);

        mSTTUSR=(EditText)findViewById(R.id.sttusername);
        mSTTUSR.setText(pref.getString("STTUSERNM", null));
        mSTTPASS=(EditText)findViewById(R.id.sttpassword);
        mSTTPASS.setText(pref.getString("STTPASS", null));
        mTTSUSR=(EditText)findViewById(R.id.ttsusername);
        mTTSUSR.setText(pref.getString("TTSUSRNM", null));
        mTTSPASS=(EditText)findViewById(R.id.ttspassword);
        mTTSPASS.setText(pref.getString("TTSPSS", null));

        org=(EditText) findViewById(R.id.organizationValue);
        org.setText(pref.getString("organization", null));


        btnshow = (Button) findViewById(R.id.showTokenButton);

        auth=(EditText) findViewById(R.id.authTokenValue);
        auth.setText(pref.getString("authtoken", null));
        hexcolor=(EditText) findViewById(R.id.hexcolor);
        hexcolor.setText(pref.getString("hexcolor", null));
        titleAppSet=(EditText)findViewById(R.id.titleAppSettings);
        titleAppSet.setText(pref.getString("title",null));


        deviceid=(EditText) findViewById(R.id.deviceIDValue);
        deviceid.setText(pref.getString("deviceid",null));
        logouri=pref.getString("logouri",null);
        if(logouri==null)
        {
            Uri path=Uri.parse("android.resource://com.ibm.watson.developer_cloud.android.myapplication/"+ R.drawable.logo);
            logouri=path.toString();
            InputStream imageStream1 = null;
            try {
                imageStream1 = getContentResolver().openInputStream(path);
            } catch (FileNotFoundException e) {
                e.printStackTrace();
            }
            Bitmap yourSelectedImage1 = BitmapFactory.decodeStream(imageStream1);
            imageButton.setImageBitmap(yourSelectedImage1);
            editor.putString("logouri",path.toString());
        }
        else
        {
            Uri image =Uri.parse(logouri);
            InputStream imageStream1 = null;
            try {
                imageStream1 = getContentResolver().openInputStream(image);
            } catch (FileNotFoundException e) {
                e.printStackTrace();
            }
            Bitmap yourSelectedImage1 = BitmapFactory.decodeStream(imageStream1);
            imageButton.setImageBitmap(yourSelectedImage1);
        }



        color=pref.getString("hexcolor", null);
        Button button=(Button)findViewById(R.id.activateButton1);
        RelativeLayout relativeLayout=(RelativeLayout)findViewById(R.id.topbar1);
        try{
            relativeLayout.setBackgroundColor(Color.parseColor(color));
            button.setBackgroundColor(Color.parseColor(color));
        }catch (StringIndexOutOfBoundsException e){
            e.printStackTrace();
        }


    }
    View.OnClickListener imgButtonHandler=new View.OnClickListener(){

        public void onClick(View v)
        {
            Intent photoPickerIntent = new Intent(Intent.ACTION_PICK);
            photoPickerIntent.setType("image/*");
            startActivityForResult(photoPickerIntent, SELECT_PHOTO);
        }
    };
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent imageReturnedIntent) {
        //super.onActivityResult(requestCode, resultCode, imageReturnedIntent);

        switch(requestCode) {
            case SELECT_PHOTO:
                if(resultCode == RESULT_OK){
                    Uri selectedImage = imageReturnedIntent.getData();
                    InputStream imageStream = null;
                    try {
                        imageStream = getContentResolver().openInputStream(selectedImage);
                    } catch (FileNotFoundException e) {
                        e.printStackTrace();
                    }
                    Bitmap yourSelectedImage = BitmapFactory.decodeStream(imageStream);
                    ImageButton temp=(ImageButton)findViewById(R.id.logobuttonsetting);
                    temp.setImageBitmap(yourSelectedImage);
                    Toast.makeText(app.getBaseContext(), selectedImage.toString(),
                            Toast.LENGTH_LONG).show();
                    app.setmlogoUri(selectedImage.toString());
                    editor.putString("logouri",selectedImage.toString());

                }
        }
    }


    @Override
    public void onResume() {
        Log.d(TAG, ".onResume() entered");

        super.onResume();
        app = (IoTStarterApplication) this.getApplication();
        app.setCurrentRunningActivity(TAG);

        if (broadcastReceiver == null) {
            Log.d(TAG, ".onResume() - Registering loginBroadcastReceiver");
            broadcastReceiver = new BroadcastReceiver() {

                @Override
                public void onReceive(Context context, Intent intent) {
                    Log.d(TAG, ".onReceive() - Received intent for loginBroadcastReceiver");
                    processIntent(intent);

                }
            };
        }
        {

        }

        getApplicationContext().registerReceiver(broadcastReceiver, new IntentFilter(Constants.APP_ID + Constants.INTENT_LOGIN));

        // initialise
        initializeLoginActivity();
    }

    /**
     * Initializing onscreen elements and shared properties
     */
    private void initializeLoginActivity() {
        Log.d(TAG, ".initializeLoginFragment() entered");


        initializeButtons();


    }

    /**
     * Update strings in the fragment based on IoTStarterApplication values.
     */

    void updateViewStrings() {
        Log.d(TAG, ".updateViewStrings() entered");
        // Update only if the organization is set to some non-empty string.
        if (app.getOrganization() != null) {
            ((EditText) findViewById(R.id.organizationValue)).setText(app.getOrganization());
        }

        // DeviceId should never be null at this point.
        if (app.getDeviceId() != null) {
            ((EditText) findViewById(R.id.deviceIDValue)).setText(app.getDeviceId());
        }

        if (app.getAuthToken() != null) {
            ((EditText) findViewById(R.id.authTokenValue)).setText(app.getAuthToken());
        }
        if (app.getmTTSusername()!= null) {
            ((EditText) findViewById(R.id.ttsusername)).setText(app.getmTTSusername());
        }
        if (app.getmTTSpassword() != null) {
            ((EditText) findViewById(R.id.ttspassword)).setText(app.getmTTSpassword());
        }
        if (app.getmSTTusername() != null) {
            ((EditText) findViewById(R.id.sttusername)).setText(app.getmSTTusername());
        }
        if (app.getmSTTpassword() != null) {
            ((EditText) findViewById(R.id.sttpassword)).setText(app.getmSTTpassword());
        }
        if (app.getmHexcolor() != null) {
            ((EditText) findViewById(R.id.hexcolor)).setText(app.getmHexcolor());
        }
        if (app.getmTitle() != null) {
            ((EditText) findViewById(R.id.titleAppSettings)).setText(app.getmTitle());
        }
        // Set 'Connected to IoT' to Yes if MQTT client is connected. Leave as No otherwise.
        if (app.isConnected()) {
          //  updateConnectedValues();
            //processConnectIntent();
        }
    }

    /**
     * Setup listeners for buttons.
     */
    private void initializeButtons() {
        Log.d(TAG, ".initializeButtons() entered");
        mSTTUSR = (EditText) findViewById(R.id.sttusername);
        mSTTPASS = (EditText) findViewById(R.id.sttpassword);
        mTTSUSR = (EditText) findViewById(R.id.ttsusername);
        mTTSPASS = (EditText) findViewById(R.id.ttspassword);
        hexcolor = (EditText) findViewById(R.id.hexcolor);
        titleAppSet=(EditText)findViewById(R.id.titleAppSettings);
        Button showTTSpswd = (Button) findViewById(R.id.showTTSpsd);

        showTTSpswd.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                handleShowTTSPassword();
            }
        });
        Button showSTTpswd = (Button) findViewById(R.id.showSTTpsd);
        showSTTpswd.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                handleShowSTTPassword();
            }
        });

        Button button = (Button) findViewById(R.id.showTokenButton);
        button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                handleShowToken();
            }
        });

        button = (Button) findViewById(R.id.activateButton1);
        button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                processDisconnectIntent();
                if (mTTSUSR.getText().toString().trim().length() > 0 & mTTSPASS.getText().toString().trim().length() > 0 & mSTTUSR.getText().toString().trim().length() > 0 & mSTTPASS.getText().toString().trim().length() > 0) {

                    app.setmSTTusername(mSTTUSR.getText().toString());
                    app.setmSTTpassword(mSTTPASS.getText().toString());
                    app.setmTTSusername(mTTSUSR.getText().toString());
                    app.setmTTSpassword(mTTSPASS.getText().toString());

                    handleActivate();

                } else {
                    displayconversationSetPropertiesDialog();

                }

            }
        });

        CheckBox checkbox = (CheckBox) findViewById(R.id.checkbox_ssl);
        checkbox.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onCheckboxClicked(v);
            }
        });
        checkbox.setChecked(app.isUseSSL());
    }

    private void handleActivate() {
        Log.d(TAG, ".handleActivate() entered");
        String buttonTitle = ((Button) findViewById(R.id.activateButton1)).getText().toString();
        Button activateButton = (Button) findViewById(R.id.activateButton1);
        app.setDeviceType("Android");


        app.setDeviceId(((EditText) findViewById(R.id.deviceIDValue)).getText().toString());
        app.setOrganization(((EditText) findViewById(R.id.organizationValue)).getText().toString());
        app.setAuthToken(((EditText) findViewById(R.id.authTokenValue)).getText().toString());


        editor.putString("organization", ((EditText) findViewById(R.id.organizationValue)).getText().toString());
        editor.putString("deviceid", ((EditText) findViewById(R.id.deviceIDValue)).getText().toString());
        editor.putString("authtoken", ((EditText) findViewById(R.id.authTokenValue)).getText().toString());

        editor.putString("STTUSERNM", ((EditText) findViewById(R.id.sttusername)).getText().toString());
        editor.putString("STTPASS", ((EditText) findViewById(R.id.sttpassword)).getText().toString());
        editor.putString("TTSUSRNM", ((EditText) findViewById(R.id.ttsusername)).getText().toString());
        editor.putString("TTSPSS", ((EditText) findViewById(R.id.ttspassword)).getText().toString());
        editor.putString("hexcolor", ((EditText) findViewById(R.id.hexcolor)).getText().toString());
        editor.putString("title", ((EditText) findViewById(R.id.titleAppSettings)).getText().toString());

        editor.commit();

        IoTClient iotClient = IoTClient.getInstance(this, app.getOrganization(), app.getDeviceId(), app.getDeviceType(), app.getAuthToken());
        activateButton.setEnabled(false);
        if (buttonTitle.equals(getResources().getString(R.string.savecredentials_button)) && !app.isConnected()) {
            if (checkCanConnect()) {
                // create ActionListener to handle message published results
                try {
                    SocketFactory factory = null;
                    if (app.isUseSSL()) {
                        try {
                            ProviderInstaller.installIfNeeded(this);

                            SSLContext sslContext;
                            KeyStore ks = KeyStore.getInstance("bks");
                            ks.load(this.getResources().openRawResource(R.raw.iot), "password".toCharArray());
                            TrustManagerFactory tmf = TrustManagerFactory.getInstance("X509");
                            tmf.init(ks);
                            TrustManager[] tm = tmf.getTrustManagers();
                            sslContext = SSLContext.getInstance("TLSv1.2");
                            sslContext.init(null, tm, null);
                            factory = sslContext.getSocketFactory();
                        } catch (Exception e) {
                            // TODO: handle exception
                            e.printStackTrace();
                        }
                    }

                    MyIoTActionListener listener = new MyIoTActionListener(this, Constants.ActionStateStatus.CONNECTING);
                    iotClient.connectDevice(app.getMyIoTCallbacks(), listener, factory);
                } catch (MqttException e) {
                    if (e.getReasonCode() == (Constants.ERROR_BROKER_UNAVAILABLE)) {
                        // error while connecting to the broker - send an intent to inform the user
                        Intent actionIntent = new Intent(Constants.ACTION_INTENT_CONNECTIVITY_MESSAGE_RECEIVED);
                        actionIntent.putExtra(Constants.CONNECTIVITY_MESSAGE, Constants.ERROR_BROKER_UNAVAILABLE);
                        sendBroadcast(actionIntent);
                    }
                }
            } else {
                displaySetPropertiesDialog();
                activateButton.setEnabled(true);
            }
        } else if (buttonTitle.equals(getResources().getString(R.string.deactivate_button)) && app.isConnected()) {
            // create ActionListener to handle message published results
            try {
                MyIoTActionListener listener = new MyIoTActionListener(this, Constants.ActionStateStatus.DISCONNECTING);
                iotClient.disconnectDevice(listener);
            } catch (MqttException e) {
                // Disconnect failed
            }
        }
    }



    /**************************************************************************
     * Functions to handle button presses
     **************************************************************************/

    /**
     * Check whether the required properties are set for the app to connect to IoT.
     *
     * @return True if properties are set, false otherwise.
     */
    private boolean checkCanConnect() {
        if (app.getOrganization().equals(Constants.QUICKSTART)) {
            app.setConnectionType(Constants.ConnectionType.QUICKSTART);
            if (app.getDeviceId() == null || app.getDeviceId().equals("")) {
                return false;
            }
        } else if (app.getOrganization().equals(Constants.M2M)) {
            app.setConnectionType(Constants.ConnectionType.M2M);
            if (app.getDeviceId() == null || app.getDeviceId().equals("")) {
                return false;
            }
        } else {
            app.setConnectionType(Constants.ConnectionType.IOTF);
            if (app.getOrganization() == null || app.getOrganization().equals("") ||
                    app.getDeviceId() == null || app.getDeviceId().equals("") ||
                    app.getAuthToken() == null || app.getAuthToken().equals("")) {
                return false;
            }
        }
        return true;
    }
    /**************************************************************************
     * Functions to process intent broadcasts from other classes
     **************************************************************************/

    /**
     * Process the incoming intent broadcast.
     *
     * @param intent The intent which was received by the fragment.
     */
    private void processIntent(Intent intent) {
        Log.d(TAG, ".processIntent() entered");

        // No matter the intent, update log button based on app.unreadCount.
        updateViewStrings();

        String data = intent.getStringExtra(Constants.INTENT_DATA);
        assert data != null;
        if (data.equals(Constants.INTENT_DATA_CONNECT)) {
            processConnectIntent();
            Intent i = new Intent(settings.this, MainActivity.class);
            i.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            startActivity(i);
            pd.cancel();
        } else if (data.equals(Constants.INTENT_DATA_DISCONNECT)) {
            processDisconnectIntent();
        } else if (data.equals(Constants.ALERT_EVENT)) {
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

    /**
     * Intent data contained INTENT_DATA_CONNECT.
     * Update Connected to Yes.
     */
    private void processConnectIntent() {
        Log.d(TAG, ".processConnectIntent() entered");
        //updateConnectedValues();

        // Log message with the following format:
        // [yyyy-mm-dd hh:mm:ss.S] Connected to server:
        // <message text>
        Date date = new Date();
        String logMessage = "[" + new Timestamp(date.getTime()) + "] Connected to server";
        app.getMessageLog().add(logMessage);
        Intent actionIntent = new Intent(Constants.APP_ID + Constants.INTENT_LOG);
        actionIntent.putExtra(Constants.INTENT_DATA, Constants.TEXT_EVENT);
        sendBroadcast(actionIntent);

        if (app.isAccelEnabled()) {
            LocationUtils locUtils = LocationUtils.getInstance(this);
            locUtils.connect();
            app.setDeviceSensor(DeviceSensor.getInstance(this));
            app.getDeviceSensor().enableSensor();
        }
    }

    /**
     * Display alert dialog indicating what properties must be set in order to connect to IoT.
     */
    private void displaySetPropertiesDialog() {
        new AlertDialog.Builder(this)
                .setTitle(getResources().getString(R.string.connect_props_title))
                .setMessage(getResources().getString(R.string.connect_props_text))
                .setPositiveButton(getResources().getString(R.string.ok), new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int whichButton) {
                        // Do nothing.
                    }
                }).show();
    }


    private void displayconversationSetPropertiesDialog() {
        new AlertDialog.Builder(this)
                .setTitle(getResources().getString(R.string.connect_props_title))
                .setMessage(getResources().getString(R.string.connect_conversation_props_text))
                .setPositiveButton(getResources().getString(R.string.ok), new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int whichButton) {
                        // Do nothing.
                    }
                }).show();
    }

   /* private void updateConnectedValues() {
        Button activateButton = (Button) findViewById(R.id.activateButton);
        activateButton.setEnabled(true);
        String connectedString = this.getString(R.string.is_connected);
        connectedString = connectedString.replace("No", "Yes");
        ((TextView) findViewById(R.id.isConnected)).setText(connectedString);
        activateButton.setText(getResources().getString(R.string.deactivate_button));
    }*/


    /**
     * Intent data contained INTENT_DATA_DISCONNECT.
     * Update Connected to No.
     */
    private void processDisconnectIntent() {
        Log.d(TAG, ".processDisconnectIntent() entered");
        Button activateButton = (Button) findViewById(R.id.activateButton1);
        activateButton.setEnabled(true);
        ((TextView) findViewById(R.id.isConnected)).setText(this.getString(R.string.is_connected));
        activateButton.setText(getResources().getString(R.string.savecredentials_button));

        // Log message with the following format:
        // [yyyy-mm-dd hh:mm:ss.S] Received alert:
        // <message text>
        Date date = new Date();
        String logMessage = "[" + new Timestamp(date.getTime()) + "] Disonnected from server";
        app.getMessageLog().add(logMessage);
        Intent actionIntent = new Intent(Constants.APP_ID + Constants.INTENT_LOG);
        actionIntent.putExtra(Constants.INTENT_DATA, Constants.TEXT_EVENT);
        sendBroadcast(actionIntent);

        if (app.getDeviceSensor() != null && app.isAccelEnabled()) {
            LocationUtils locUtils = LocationUtils.getInstance(this);
            app.getDeviceSensor().disableSensor();
            if (locUtils != null) {
                locUtils.disconnect();
            }
        }
    }

    /**
     * Toggle auth token text field secure text entry
     */
    private void handleShowToken() {
        Log.d(TAG, ".handleShowToken() entered");
        Button showTokenButton = (Button) findViewById(R.id.showTokenButton);
        String buttonTitle = showTokenButton.getText().toString();
        EditText tokenText = (EditText) findViewById(R.id.authTokenValue);
        if (buttonTitle.equals(getResources().getString(R.string.showToken_button))) {
            showTokenButton.setText(getResources().getString(R.string.hideToken_button));
            tokenText.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD);
        } else if (buttonTitle.equals(getResources().getString(R.string.hideToken_button))) {
            showTokenButton.setText(getResources().getString(R.string.showToken_button));
            tokenText.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);
        }
    }

    /**
     * Toggle TTS password text field secure text entry
     */
    private void handleShowTTSPassword() {
        Log.d(TAG, ".handleShowToken() entered");
        Button showTTSpswd = (Button) findViewById(R.id.showTTSpsd);
        String buttonTitle = showTTSpswd.getText().toString();
        //EditText mTTSPASS=(EditText)findViewById(R.id.ttspassword);
        if (buttonTitle.equals(getResources().getString(R.string.showTTSpsw_button))) {
            showTTSpswd.setText(getResources().getString(R.string.hideTTSpsw_button));
            mTTSPASS.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD);
        } else if (buttonTitle.equals(getResources().getString(R.string.hideTTSpsw_button))) {
            showTTSpswd.setText(getResources().getString(R.string.showTTSpsw_button));
            mTTSPASS.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);
        }
    }

    /**
     * Toggle  STT password  text field secure text entry
     */
    private void handleShowSTTPassword() {
        Log.d(TAG, ".handleShowToken() entered");
        Button showSTTpswd = (Button) findViewById(R.id.showSTTpsd);
        String buttonTitle = showSTTpswd.getText().toString();
        // EditText mSTTPASS=(EditText)findViewById(R.id.sttpassword);
        if (buttonTitle.equals(getResources().getString(R.string.showSTTpsw_button))) {
            showSTTpswd.setText(getResources().getString(R.string.hideSTTpsw_button));
            mSTTPASS.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD);
        } else if (buttonTitle.equals(getResources().getString(R.string.hideSTTpsw_button))) {
            showSTTpswd.setText(getResources().getString(R.string.showSTTpsw_button));
            mSTTPASS.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);
        }
    }

    public void onCheckboxClicked(View view) {
        boolean checked = ((CheckBox) view).isChecked();
        Log.d(TAG, ".onCheckboxClicked() Setting useSSL to " + checked);

        app.setUseSSL(checked);
    }
    public void onBackPressed() {
        Intent startMain = new Intent(Intent.ACTION_MAIN);
        startMain.addCategory(Intent.CATEGORY_HOME);
        startMain.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(startMain);

    }
}
