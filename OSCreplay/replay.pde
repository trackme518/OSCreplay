Replay replay;
ArrayList<String>replayFilesAvailable = new ArrayList<String>();
boolean resaveOnReplay = false; //this for dev purposes only - update variables in files....DELETE IN PRODUCTION!!!

void initReplay() {
  replay = new Replay();
  replayFilesAvailable = listFiles(".csv");
}

class Replay {
  //OscMessage
  boolean loop = false;

  String filepath = null;

  String filename = null;
  boolean playing = false;
  boolean readNext = false;
  boolean eventred = false;

  BufferedReader reader;
  String line;
  //int lineIndex = 1; //start on second line - ignore header

  int timer=0;
  int timestamp = 0;
  OscMessage myMessage = null;
  String OSCaddress = "";
  String OSCtypetag = "";
  long OSCtimetag = 1;
  //---------------------------------------------------------------
  Replay() {
  }

  //main function to read from file, checks against current time and exucte events
  void updateReplay() {
    //read from file---
    if (playing) {
      if (readNext) {
        eventred = readLine();
        if ( eventred ) {
          readNext = false;
        }
      }
    }
    //--------
    if (playing && eventred) {
      if ( millis() - timer > timestamp) {

        String currAdd = OSCaddress;
        if (currAdd.length()>30) {
          currAdd = OSCaddress.substring(0, 30); //trimm to 30 characters
        }

        if (!performanceModeSet) {
          eventstatus.addEventStatus( false, currAdd, OSCtypetag ); //add to debug messages
        }

        //SEND EVENTS OVER OSC :-------
        oscP5.send(myMessage, otherServerLocation);
        //println(myMessage);
        //OscP5.flush(myMessage, otherServerLocation); //send without triggering onOSC event listener
        //------------------------------------------
        readNext = true;
        eventred = false;
      }
    }
    //
  }

  boolean readLine() {
    try {
      line = reader.readLine();
    }
    catch (IOException e) {
      e.printStackTrace();
      line = null;
      return false;
    }
    if (line == null) {
      println("end of file");
      stopFile();
      if ( loop ) { //loop actovated
        playFile();//play again from start
      } else {
        controlP5.Controller currController =  cp5.getController( "replayFile" );
        currController.setValue(0);
        currController.setLabel("replay file");
      }
      return false;
    } else {
      //prepare parts of the message
      String[] pieces = split(line, ',');
      if ( pieces.length > 3 ) {
        //skip header - non integer type
        if ( !isInteger( pieces[0], 10 ) ) {
          return false;
        }

        timestamp = int(pieces[0]);//timestamp
        OSCaddress = pieces[1];//OSC address
        OSCtypetag = pieces[2];//OSC typetag

        //right now we are not using the timetag parameter
        //however this could be used to analyze difference between send time and recieve time
        //OSCtimetag = Long.parseLong(pieces[3]);//OSC timetag  present in OSC bundles

        myMessage = new OscMessage(OSCaddress); //reset
        //rest of the line should be values - check for them
        for (int i=0; i<OSCtypetag.length(); i++) {
          Character currType = OSCtypetag.charAt(i);
          //println("currr type: "+currType);
          if ( currType.equals('f') ) {
            myMessage.add( float(pieces[i+4]) );
          }
          if ( currType.equals('i') ) {
            myMessage.add( int(pieces[i+4]) );
          }
          if ( currType.equals('s') ) {
            myMessage.add( (String)pieces[i+4] );
          }
          if ( currType.equals('d') ) {
            myMessage.add( Double.valueOf(pieces[i+4]) ); //cast to double
          }
        }
        //println("line typetag: "+OSCtypetag+" address: "+OSCaddress);
        return true;
      }
    }
    return false;
  }

  boolean openFile() {
    boolean pathSet = fileExists(filepath);
    if (pathSet) {
      reader = createReader(filepath);
    }
    return pathSet;
  }

  void playFile() {
    if (filepath != null) {
      if ( openFile() ) {//init buffer reader
        playing = true;
        readNext = true;
        timer = millis();
        println("playback started from file "+filepath);
        cp5.getController( "replayFile" ).setLabel("replaying...");
        return;
      } else {
        println("error during opening file "+filepath);
      }
    } else {
      println("filepath to playback file is null");
    }
    controlP5.Controller currController =  cp5.getController( "replayFile" );
    currController.setValue(0);
  }

  void stopFile() {
    playing = false;
    reader = null;
    cp5.getController( "replayFile" ).setLabel("replay file");
    println("playback ended");
  }
}//END REPLAY CLASS
