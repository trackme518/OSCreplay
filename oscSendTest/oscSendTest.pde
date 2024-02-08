import oscP5.*;
import netP5.*;

OscP5 osc;
NetAddress receiver;
boolean send = false;
int oscFps = 0;
int oscRecieved = 0;
long lastRecievedTime = 0;
int targetPort = 8888;

int oscSend = 0;
int oscSendFps = 0;

//int[] oscSendFpsAvereged = new int[5];

long lastSendTime = 0;

int oscSendTargetFps = 60;
int millisIntervalSend = 1000/oscSendTargetFps;

void setup() {
  size( 400, 400 );

  /* create a new instance of OscP5, the second parameter indicates the listening port */
  osc = new OscP5( this, targetPort );
  /* create a NetAddress which requires the receiver's IP address and port number */
  receiver = new NetAddress( "127.0.0.1", 7777 );
  frameRate(1000);
}

long timer = 0;
void draw() {
  background(0);
  fill(255);
  text( "OSC recieved fps: "+str(oscFps), 30, 30);
  text( "OSC send fps: "+str(oscSendFps), 30, 60);
  if (osc!=null && send) {

    text( "sending data to "+str(targetPort), 30, 90);
    if (millis()-timer>millisIntervalSend) { //100/16=16.666=>60fps
      for (int i=0; i<1; i++) { //send 10 messages in sequence
        osc.send( receiver, "/test_"+i, random( 255 ), random( 255 ), random( 255 ) );
        oscSend++;
      }
      timer = millis();
    }

    if (millis()-lastSendTime>1000) {
      oscSendFps = oscSend;
      oscSend = 0;
      lastSendTime = millis();
      //auto regulate sending frequency
      if ( oscSendFps < oscSendTargetFps ) {
        millisIntervalSend--;
      } else if (  oscSendFps > oscSendTargetFps ) {
        millisIntervalSend++;
      }
    }
  }
}

void keyPressed() {
  if (key==' ') {
    send = !send;
    println("sending: "+send);
  }
}

void oscEvent( OscMessage m ) {
  println(m);
  oscRecieved++;
  if (millis()-lastRecievedTime>1000) {
    oscFps = oscRecieved;
    oscRecieved = 0;
    lastRecievedTime = millis();
  }
}
