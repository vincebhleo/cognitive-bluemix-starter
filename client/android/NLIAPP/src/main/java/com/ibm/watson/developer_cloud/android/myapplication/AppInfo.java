package com.ibm.watson.developer_cloud.android.myapplication;

/**
 * Created by babagouda_biradar on 11/22/2016.
 */
public class AppInfo {
    private static AppInfo appinfo = new AppInfo( );

 /* A private Constructor prevents any other
    * class from instantiating.
    */

    private AppInfo() { }

    /* Static 'instance' method */
    public static AppInfo getInstance( ) {
        return appinfo;
    }

    public static String STTUSRname;
    public static String STTPassword;
    public static String TTSUSRname;
    public static String TTSPassword;
    public static String Payload;



}
