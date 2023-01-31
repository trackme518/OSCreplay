import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

NetAddress otherServerLocation;
String myOscIp = "127.0.0.1";
String targetOscIp  ="127.0.0.1";
int oscListenPort = 12000;
int oscTargetPort = 16000;

void initOSCAPI() {
  oscP5 = new OscP5(this, oscListenPort);
  myRemoteLocation = new NetAddress(myOscIp, oscListenPort);
  otherServerLocation = new NetAddress(targetOscIp, oscTargetPort);
  //oscPrefix = "/"+oscPrefix; //this has to be included otherwise touchdesigner will not accept it
}

void oscEvent(OscMessage theOscMessage) {

  String currAddTrimmed = theOscMessage.addrPattern();
  if ( currAddTrimmed.length()>30 ) {
    currAddTrimmed = theOscMessage.addrPattern().substring(0, 30);
  }
  String eventStatus = str(millis())+" "+currAddTrimmed+" "+theOscMessage.typetag(); //store event to string for debug
  //println(eventStatus);
  addEventStatus(eventStatus);
  saveEvent( theOscMessage );

  //CONTROL GUI REMOTELY---------------------------------------------------------------
  if ( theOscMessage.checkAddrPattern("/oscutil_recording") &&  theOscMessage.checkTypetag("i") ) {
    int val = theOscMessage.get(0).intValue();
    val = constrain(val, 0, 1);
    cp5.getController("recordevents").setValue(val);
  }

  if ( theOscMessage.checkAddrPattern("/oscutil_play") &&  theOscMessage.checkTypetag("i") ) {
    int val = theOscMessage.get(0).intValue();
    val = constrain(val, 0, 1);
    cp5.getController("replayFile").setValue(val);
  }

  if ( theOscMessage.checkAddrPattern("/oscutil_loop") &&  theOscMessage.checkTypetag("i") ) {
    int val = theOscMessage.get(0).intValue();
    val = constrain(val, 0, 1);
    cp5.getController("loopReplay").setValue(val);
  }

  if ( theOscMessage.checkAddrPattern("/oscutil_performance") &&  theOscMessage.checkTypetag("i") ) {
    int val = theOscMessage.get(0).intValue();
    val = constrain(val, 0, 1);
    performanceMode =  boolean(val);
  }

  if ( theOscMessage.checkAddrPattern("/oscutil_file") &&  theOscMessage.checkTypetag("i") ) {
    int val = theOscMessage.get(0).intValue();
    cp5.getController("playbackFileList").setValue(val);
  }
  //---------------------------------------------------
}
