import websockets.*;
WebsocketServer ws;

int websocketPort = 9999;
String websocketPrefix = "/oscutil";
boolean useWebsocket = true;

void initWebsocket() {
  ws=new WebsocketServer(this, websocketPort, websocketPrefix );
  println("websocket server started");
}

void closeWebsocket() {
  ws=null;
  println("websocket server closed");
}

//ws.sendMessage("Server message");

void webSocketServerEvent(String msg) {
  //println(msg);
  if (!useWebsocket) {
    return;
  }
  JSONObject json = parseJSONObject(msg);// loadJSONObject( msg );//assume JSON format
  if (!json.isNull("address")) {
    String addr = json.getString("address");
    JSONArray values = null;
    if (  !json.isNull("data") ) {
      values = json.getJSONArray("data");
    }

    //this is control message not meant to be resend---------------------------
    //parse for value
    if ( addr.indexOf("/oscutil") != -1 ) {
      int controlVal = -1;
      if ( values!=null ) {
        if ( values.size()>0) {
          JSONObject item = values.getJSONObject(0);
          if ( item != null ) {
            if ( !item.isNull("value") &&  !item.isNull("type") ) {
              if ( item.getString("type").equals("i") ) {
                controlVal = values.getJSONObject(0).getInt("value");
                controlVal = constrain(controlVal, 0, 1);
              }
            }
          }
        }
      }
      /*
      //CONTROL GUI REMOTELY---------------------------------------------------------------
      if ( addr.equals("/oscutil_recording") &&  controlVal!=-1 ) {
        cp5.getController("recordevents").setValue(controlVal);
      }
      if ( addr.equals("/oscutil_play") &&  controlVal!=-1) {
        cp5.getController("replayFile").setValue(controlVal);
      }
      if ( addr.equals("/oscutil_loop") &&  controlVal!=-1 ) {
        cp5.getController("loopReplay").setValue(controlVal);
      }
      if ( addr.equals("/oscutil_performance") &&  controlVal!=-1 ) {
        performanceMode =  boolean(controlVal);
      }
      if ( addr.equals("/oscutil_file") &&  controlVal!=-1 ) {
        cp5.getController("playbackFileList").setValue(controlVal);
      }
      //SEND REPLY BACK:--------
      if ( addr.equals("/oscutil_listfiles") ) {
        String msgOut = "";
        replayFilesAvailable = listFiles(".csv"); //ArrayList<String>
        for (int i=0; i<replayFilesAvailable.size(); i++) {
          msgOut += replayFilesAvailable.get(i) + ";";
        }
        //send back the list of all avaliable file names
        if (ws != null ) {
          ws.sendMessage(msgOut);
        }
      }
      if ( addr.equals("/oscutil_countfiles") ) {
        replayFilesAvailable = listFiles(".csv"); //ArrayList<String>
        String msgOut = str( replayFilesAvailable.size() ) ;
        //send back the count of all avaliable files
        if (ws != null ) {
          ws.sendMessage(msgOut);
        }
      }
      */
      //END CONROL GUI messages
      //---------------------------------------------------
      eventstatus.addEventStatus( true, addr, "" ); //add to debug messages, ignore typetag
      return;//end the parsing loop here - no need to resend to OSC proxy - only to control GUI
    }

    //websocket messages that should be resend as OSC events:
    OscMessage currmsg = new OscMessage(addr); //reset
    if ( values != null ) { //check for content
      for (int i=0; i<values.size(); i++) {
        //Character currType = types.charAt(i);
        JSONObject item = values.getJSONObject(i);
        if ( item != null ) {
          String currType = item.getString("type");
          if ( currType.equals("f") ) {
            currmsg.add( item.getFloat("value") );
          }
          if ( currType.equals("i") ) {
            currmsg.add( item.getInt("value") );
          }
          if ( currType.equals("s") ) {
            currmsg.add( item.getString("value"));
          }
          if ( currType.equals("d") ) {
            currmsg.add( item.getDouble("value") ); //cast to double
          }
        }
      }
    }
    
    OscP5.flush(currmsg, otherServerLocation); //send without sending to OSCevent
    
    if (!performanceModeSet) {
      eventstatus.addEventStatus( true, currmsg.addrPattern(), currmsg.typetag() ); //add to debug messages
    }
  }//end check parameter address exists
}
