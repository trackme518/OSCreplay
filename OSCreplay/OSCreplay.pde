//TBD rename adress patterns (from settings like in touchdesigner chan1 chan2 ...)
//TBD remap values?
//TBD error on cwebsocket connection timeout


boolean performanceMode = false;
boolean performanceModeSet = false;
int maxFrameRate = 1000;
float avgFps = 0.0;

void setup() {
  //size(640, 480);
  size(640, 480, P2D);
  surface.setTitle("OSC REPLAY ");
  frameRate(maxFrameRate);
}

boolean intialised = false;

void draw() {

  //SHOW FPS COUNTER
  //calculate fps - exponential running average
  //avgFps =  approxRollingAverage (avgFps, frameRate, 60 ); //averaged framerate over 60 samples
  //display fps in window title every 1/4 seconds
  if ( frameCount% round(frameRate/4.0) ==0 ) {
    surface.setTitle("OSC REPLAY "+round(  frameRate  )+"fps OSC fps: "+fpsOscMessages+" " );//current:"+round(frameRate)
    //surface.setTitle("OSC REPLAY "+round(  avgFps  )+"fps OSC fps: "+fpsOscMessages+" " );//current:"+round(frameRate)
  }

  if (performanceModeSet) {
    return;
  }

  if (!intialised && frameCount > 2) {
    initGUI();
    initOSCAPI();
    initReplay(); //see replay tab - playback events from CSV file
    if (useWebsocket) {
      initWebsocket();
    }
    intialised = true;
  }

  if (!intialised ) {
    background(0);
    fill(255);
    textSize(24);
    text("loading...", width/2-textWidth("loading...")/2, height/2);
    return;
  }



  if (replay!=null) {
    replay.updateReplay();
  }

  if (!performanceMode) {
    background(0);
    if (eventstatus != null ) {
      eventstatus.displayEvents(); //see status tab
    }
    updateGUI();
    //performanceModeSet = false;
  } else {
    if (!performanceModeSet) {
      renderPerformanceModeHint(); //see GUI tab
      performanceModeSet = true;
    }
  }
}


//----------------------------------------------------------------------------
//ESTABLISH CONNECTION BASED ON CURRENT IP with IMU sensor
import java.net.InetAddress;

void oscConnect() {
  OscMessage connection = new OscMessage("/connect");
  String currIp = targetOscIp; //get value from GUI
  String[] ipComponents = split(currIp, ".");
  String brodcastIP = ipComponents[0]+"."+ipComponents[1]+"."+ipComponents[2]+".255";

  println("current IP: " + currIp);
  NetAddress broadcast = new NetAddress(brodcastIP, oscListenPort);
  connection.add(currIp);
  oscP5.send(connection, broadcast);
  println("Sending IP "+currIp+" over OSC: "+brodcastIP);
}
