import websockets.*;
WebsocketServer ws;

int websocketPort = 9999;
String websocketPrefix = "/oscutil";
boolean useWebsocket = true;

void initWebsocket() {
  ws= new WebsocketServer(this, websocketPort, websocketPrefix );
}

void closeWebsocket() {
  ws= null;
}

//ws.sendMessage("Server message");

void webSocketServerEvent(String msg) {
  if (!useWebsocket) {
    return;
  }
  println(msg);
}
