import com.krab.lazy.*;
import com.krab.lazy.stores.LayoutStore;
LazyGui gui;

boolean guiVisible = true;

PFont smallFont;
PFont mediumFont;

color orange = color(247, 162, 113);
color darkblue  =color(0, 45, 90);
color lightblue = color(0, 170, 255);
color yellow  = color(244, 243, 123);
color pink = color(233, 108, 252); //color(245, 148, 171);
color black  = color(0);
color white  = color(255);

void initGUI() {
  gui = new LazyGui(this, new LazyGuiSettings()
    .setLoadLatestSaveOnStartup(true)
    .setAutosaveOnExit(true)
    );
  gui.hide("options");

  smallFont = createFont("Arial", 12);
  mediumFont = createFont("Arial", 18);
  textFont(smallFont, 12);
}


void playAudio() {
  OscMessage myMessage = new OscMessage("/play");
  //myMessage.add(true);
  oscP5.send(myMessage, otherServerLocation);
  println("play");
}

void stopAudio() {
  OscMessage myMessage = new OscMessage("/stop");
  oscP5.send(myMessage, otherServerLocation);
  println("stop");
}
//========================================================================================

void updateGUI() {

  websocketPort = gui.sliderInt("websocket/port", websocketPort);
  websocketPrefix = gui.text("websocket/prefix", websocketPrefix);
  useWebsocket = gui.toggle("websocket/enable", useWebsocket);
  if (gui.button("websocket/restart")) {
    initWebsocket();
  }

  oscTargetPort = gui.sliderInt("OSC/target port", oscTargetPort);
  oscListenPort = gui.sliderInt("OSC/listen port", oscListenPort);
  targetOscIp = gui.text("OSC/ip", targetOscIp);
  proxyEnabled =  gui.toggle("OSC/enable proxy", proxyEnabled);
  if ( gui.button("OSC/restart") ) {
    initOSCAPI();
  }

  convertNtpToUnix = gui.toggle("convert Ntp To Unix", convertNtpToUnix);

  boolean guirec = gui.toggle("record events", recordingEvents);
  if (guirec && !recordingEvents) {
    startRecEvent();
  }
  if (!guirec && recordingEvents) {
    stopRecEvent();
  }
  boolean guireplay = gui.toggle("replay file", false);
  if (guireplay && !replay.playing) {
    playAudio();
    println("PLAY");
    replay.playFile();
  }
  if (!guireplay && replay.playing) {
    stopAudio();
    println("STOP");
    replay.stopFile();
  }

  replay.loop = gui.toggle("loop replay", replay.loop);

  if ( gui.button("performance mode")) {
    switchPerformanceMode();
  }

  if ( gui.button("clear") ) {
    eventstatus.clear();
  }

  //trimFilesNames( replayFilesAvailable, 22 )

  if (replay!=null && replayFilesAvailable!=null) {
    String guiPlaybackFile = gui.radio("playback file", replayFilesAvailable );
    replay.filepath = guiPlaybackFile;
  }
}

void renderPerformanceModeHint() {
  background(0);
  PFont currFont = createFont("Arial", 36);
  fill(255);
  textFont(currFont);
  String userHint = "Rendering turned off\nPress 'F' to exit performance mode";
  text(userHint, width/2 - textWidth(userHint)/2, height/2 - 36);
}

void keyPressed () {
  if ( key == 'f' || key == 'F' ) {
    switchPerformanceMode();
  }

  if (key=='c') {
    oscConnect();
    println("connect request send");
  }
}

void switchPerformanceMode() {
  LayoutStore  mystore = new LayoutStore();
  performanceMode = !performanceMode;
  gui.toggleSet("performance mode", performanceMode);
  performanceModeSet = false;
  
  if (performanceMode) {  
    if ( !mystore.isGuiHidden()) {
      mystore.hideGuiToggle();
    }
  } else {
    if ( mystore.isGuiHidden()) {
      mystore.hideGuiToggle();
    }
  }
  
}

void toggleShowGui() {
  LayoutStore  mystore = new LayoutStore();
  mystore.hideGuiToggle();
  guiVisible = !guiVisible;
}
//-------------------------------------------
