//TBD rename adress patterns (from settings like in touchdesigner chan1 chan2 ...)
//TBD remap values?
//TBD error on cwebsocket connection timeout

boolean performanceMode = false;
boolean performanceModeSet = false;
int maxFrameRate = 1000;
float avgFps = 0.0;

void setup() {
  size(640, 480, P2D);
  surface.setTitle("OSC REPLAY ");
  loadData(); //load user data
  initOSCAPI();
  initReplay(); //see replay tab - playback events from CSV file
  if (useWebsocket) {
    initWebsocket();
  }
  initGUI();
  frameRate(maxFrameRate);
  NetInfo.print();
}

void draw() {
  if (replay!=null) {
    replay.updateReplay();
  }

  if (!performanceMode) {
    background(0);
    if (eventstatus != null ) {
      eventstatus.displayEvents(); //see status tab
    }
    //displayCommands();
    cp5.draw();

    if (performanceModeSet) {
      performanceModeSet = false;
    }
  } else {
    if (!performanceModeSet) {
      renderPerformanceModeHint(); //see GUI tab
      performanceModeSet = true;
    }
  }


  //SHOW FPS COUNTER
  //calculate fps - exponential running average
  avgFps =  approxRollingAverage (avgFps, frameRate, 60 ); //averaged framerate over 60 samples
  //display fps in window title every 1/4 seconds
  if ( frameCount% round(frameRate/4.0) ==0 ) {
    surface.setTitle("OSC REPLAY "+round(  avgFps  )+"fps" );//current:"+round(frameRate)
  }
}
