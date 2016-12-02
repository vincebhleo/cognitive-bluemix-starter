/*******************************************************************************
 * Copyright (c) 2014-2015 IBM Corp.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * and Eclipse Distribution License v1.0 which accompany this distribution.
 *
 * The Eclipse Public License is available at
 *   http://www.eclipse.org/legal/epl-v10.html
 * and the Eclipse Distribution License is available at
 *   http://www.eclipse.org/org/documents/edl-v10.php.
 *
 * Contributors:
 *    Mike Robertson - initial contribution
 *******************************************************************************/
package utils;

/**
 * Build messages to be published by the application.
 * This class is currently unused.
 */
public class MessageFactory {

    /**
     * Construct a JSON formatted string accel event message

     * @param lon Double containing device longitude
     * @param lat Double containing device latitude
     * @return String containing JSON formatted message
     */
    public static String getAccelMessage(double lon, double lat) {
        return "{ \"d\": {" +
                "\"lon\":" + lon + ", " +
                "\"lat\":" + lat + " " +
                "} }";
    }
    /**
     * Construct a JSON formatted string text event message
     * @param text String of text message to send
     * @return String containing JSON formatted message
     */
    public static String getTextMessage(String text ) {
        return "{\"d\":{" +
                "\"text\":\"" + text + "\"" +
                " } }";
    }

    /**
     * Construct a JSON formatted string touchmove event message
     * @param x Double of relative x position on screen
     * @param y Double of relative y position on screen
     * @param dX Double of relative x delta from previous position
     * @param dY Double of relative y delta from previous position
     * @param ended True if final message of the touch, false otherwise
     * @return String containing JSON formatted message
     */
  /*  public static String getTouchMessage(double x, double y, double dX, double dY, boolean ended) {
        String endString;
        if (ended) {
            endString = ", \"ended\":1 } }";
        } else {
            endString = " } }";
        }

        return "{ \"d\": { " +
                "\"screenX\":" + x + ", " +
                "\"screenY\":" + y + ", " +
                "\"deltaX\":" + dX + ", " +
                "\"deltaY\":" + dY +
                endString;
    }*/

}
