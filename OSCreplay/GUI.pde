import controlP5.*;
import java.util.*;

ControlP5 cp5;
Slider freqSliders;

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
  cp5 = new ControlP5(this);
  cp5.setBroadcast(false);
  cp5.setAutoDraw(false);

  smallFont = createFont("Arial", 12);
  mediumFont = createFont("Arial", 18);
  textFont(smallFont, 12);
  cp5.setFont(smallFont, 12);


  int offsetX = 30;
  int offsetY = 40;
  int z = 0;
  //cp5.setBroadcast(false);

  Group g1 = cp5.addGroup("g1") //toggles
    .setSize(200, height)
    .setLabel("GUI")
    .setBarHeight(15)
    .setPosition(offsetX, offsetY)
    ;

  CallbackListener toFront = new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      controlP5.Controller currController = theEvent.getController();
      String controlName = currController.getName();

      if ( controlName.equals("playbackFileList") ) {
        replayFilesAvailable = listFiles(".csv"); //update avaliable files in data folder
        cp5.get(ScrollableList.class, controlName).setItems( trimFilesNames( replayFilesAvailable, 22 ) );
      }

      currController.bringToFront();
      currController.setColorForeground(lightblue);
      currController.setColorBackground(darkblue);
      currController.setColorValue(white);
      currController.setColorLabel(white);
      ((ScrollableList)currController).open();
    }
  };

  CallbackListener close = new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      controlP5.Controller currController = theEvent.getController();
      //currController.bringToFront();
      currController.setColorBackground(yellow);
      currController.setColorValue(black);
      currController.setColorLabel(black);
      ((ScrollableList)currController).close();
    }
  };

  cp5.addToggle( "recordevents" )
    .setLabel( "record events" )
    .setPosition(0, offsetY*z)
    .setSize(50, 20)
    .setValue(recordingEvents)
    .setMode(ControlP5.SWITCH)
    .setColorActive(pink)
    .setGroup(g1)
    ;
  z++;

  /*
  cp5.addTextfield("midiDevice")
   .setLabel( "midi device name - press enter" )
   .setPosition(0, offsetY*z)
   .setSize(195, 20)
   .setGroup(g1)
   ;
   z++;
   
   cp5.addTextlabel("midiDeviceLabel")
   .setText(midiDeviceNameString)
   .setPosition(0, offsetY*z)
   .setGroup(g1)
   ;
   z++;
   */

  List listfils = trimFilesNames( replayFilesAvailable, 22 ); //shorten the names to fit inside the box
  cp5.addScrollableList("playbackFileList")
    .setLabel( "playback file ")
    .setPosition(0, offsetY*z)
    .setSize(200, 300)
    .setColorLabel(black)
    .setColorBackground(yellow)
    .setBarHeight(20)
    .setItemHeight(20)
    .addItems( listfils )
    //.setValue( (float)0 )
    .onEnter(toFront)
    .onLeave(close)
    .onRelease(close)
    .close()
    .setGroup(g1)
    ;
  z++;

  cp5.addToggle( "replayFile" )
    .setLabel( "replay file" )
    .setPosition(0, offsetY*z)
    .setSize(50, 20)
    .setValue(false)
    .setMode(ControlP5.SWITCH)
    .setColorActive(pink)
    .setGroup(g1)
    ;
  z++;

  cp5.addToggle( "loopReplay" )
    .setLabel( "loop replay" )
    .setPosition(0, offsetY*z)
    .setSize(50, 20)
    .setValue(false)
    .setMode(ControlP5.SWITCH)
    .setColorActive(pink)
    .setGroup(g1)
    ;
  z++;

  cp5.addBang( "clear" )
    .setLabel( "clear" )
    .setPosition(0, offsetY*z)
    .setSize(50, 20)
    .setTriggerEvent(Bang.RELEASE)
    .setColorActive(lightblue)
    .setGroup(g1)
    ;
  z++;

  cp5.addToggle( "performance" )
    .setLabel( "performance mode" )
    .setPosition(0, offsetY*z)
    .setSize(50, 20)
    .setValue(performanceMode)
    .setMode(ControlP5.SWITCH)
    .setColorActive(lightblue)
    .setGroup(g1)
    ;
  z++;

  cp5.setBroadcast(true);
}
//========================================================================================

void controlEvent(ControlEvent theEvent) {
  //println(theEvent.getController().getName());
  controlP5.Controller currController = theEvent.getController();
  String controlName = currController.getName();

  if ( controlName.equals("playbackFileList") ) {
    //Map item = cp5.get(ScrollableList.class, controlName).getItem( (int)currController.getValue() );
    int currVal = (int)currController.getValue();
    if (replay!=null) {
      replay.filepath = replayFilesAvailable.get(currVal);
    }
    println("selected file "+currVal);
  }

  saveData();
  println("changes saved");
}

void performance(boolean val) {
  performanceMode = val;
  println("performance mode: "+performanceMode);
}

void renderPerformanceModeHint() {
  background(0);
  PFont currFont = createFont("Arial", 36);
  fill(255);
  textFont(currFont);
  String userHint = "Rendering turned off\nPress 'F' to exit performance mode";
  text(userHint, width/2 - textWidth(userHint)/2, height/2 - 36);
}

void recordevents(boolean val) {
  if (val) {
    startRecEvent();
    cp5.getController("recordevents").setLabel("recording...");// = "";
  } else {
    stopRecEvent();
    cp5.getController("recordevents").setLabel("record events");
  }
}

void replayFile(boolean val) {
  if (replay!=null) {
    if (val) {
      replay.playFile();
    } else {
      replay.stopFile();
    }
  } else {
    println("replay instance of class Replay is null");
  }
}

void loopReplay(boolean val) {
  if (replay!=null) {
    replay.loop = val;
  }
}

void clear() {
  eventstatus.clear();
  //addEventStatus( true, currAddTrimmed, theOscMessage.typetag() );
  //eventParams = new String[10];
}

void keyPressed () {
  if ( key == 'f' || key == 'F' ) {
    //performance(false);
    cp5.getController("performance").setValue( int( !performanceMode ) );
  }
}
//-------------------------------------------
