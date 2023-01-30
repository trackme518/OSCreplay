//TBD websocket parser
//TBD renmae adress patterns (from settings like in touchdesigner chan1 chan2 ...)
//TBD remap values?

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
}

void draw() {
  if (replay!=null) {
    replay.updateReplay();
  }

  if (!performanceMode) {
    background(0);
    displayCommands();
    cp5.draw();

    if (performanceModeSet) {
      performanceModeSet = false;
    }
  } else {
    if (!performanceModeSet) {
      renderPerformanceModeHint(); //see GUI tab
      performanceModeSet = true;
      /*
      String hint = "Press 'F' to turn off performance mode";
       background(0);
       pushStyle();
       textFont(mediumFont);
       text(hint,width/2-textWidth(hint)/2, height/2-12);
       performanceModeSet = true;
       popStyle();
       */
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
