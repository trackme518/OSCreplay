import websockets.*;
WebsocketServer ws;

Integer websocketPort = 9999;
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
    OscMessage currmsg = new OscMessage(addr); //reset
    if ( !json.isNull("data") ) { //check for content
      JSONArray values = json.getJSONArray("data");
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
    oscP5.send(currmsg, myRemoteLocation);
  }
}
