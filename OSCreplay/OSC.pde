import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress otherServerLocation;

String targetOscIp  ="127.0.0.1";
//String myOscIp  ="127.0.0.1";
//int myOscPort =
int oscListenPort = 12000;
int oscTargetPort = 16000;

boolean proxyEnabled = false;

long lastOscUpdate = 0;
int countOscMessages = 0;
int fpsOscMessages = 0;

//MyOSCAgent oscListener;
//MyOSCAgent oscSender;

void initOSCAPI() {
  oscP5 = new OscP5(this, oscListenPort);
  otherServerLocation = new NetAddress(targetOscIp, oscTargetPort);

  eventstatus = new EventStatus(); //display debug info on send or recieved events

  //oscListener = new MyOSCAgent(oscListenPort, true, null);
  //oscSender = new MyOSCAgent(oscTargetPort, false, targetOscIp);
}

void oscEvent(OscMessage theOscMessage) {
  countOscMessages++;
  if(millis()-lastOscUpdate>1000){
    fpsOscMessages = countOscMessages;
    countOscMessages = 0;
    lastOscUpdate = millis();
  }

  String currAddTrimmed = theOscMessage.addrPattern();
  if ( currAddTrimmed.length()>30 ) {
    currAddTrimmed = theOscMessage.addrPattern().substring(0, 30);
  }

  if (!performanceModeSet) {
    eventstatus.addEventStatus( true, currAddTrimmed, theOscMessage.typetag() );
  }

  //save only OSC not ment to control GUI
  if ( !theOscMessage.addrPattern().contains("/oscutil") ) {
    //resend all incoming OSC messages to remote target - act as a proxy
    if (proxyEnabled) {
      oscP5.send(theOscMessage, otherServerLocation);
    }

    SaveEvent newLine = new SaveEvent(theOscMessage);
    newLine.saveEvent();
    //newLine.write(); //run on separate thread
    //saveEvent( theOscMessage );
    return;
  }

  //---------------------------------------------------------------------------------

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

  if ( theOscMessage.checkAddrPattern("/oscutil_listfiles") ) {
    OscMessage outmsg = new OscMessage("/oscutil_listfiles");
    replayFilesAvailable = listFiles(".csv"); //ArrayList<String>
    for (int i=0; i<replayFilesAvailable.size(); i++) {
      outmsg.add( replayFilesAvailable.get(i) );
    }
    //send back the list of all avaliable file names
    OscP5.flush(outmsg, otherServerLocation);
  }

  if ( theOscMessage.checkAddrPattern("/oscutil_countfiles") ) {
    OscMessage outmsg = new OscMessage("/oscutil_countfiles");
    replayFilesAvailable = listFiles(".csv"); //ArrayList<String>
    outmsg.add( replayFilesAvailable.size() );
    //send back the size of all avaliable file names
    OscP5.flush(outmsg, otherServerLocation);
  }
  //---------------------------------------------------
}
