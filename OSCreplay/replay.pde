import java.io.File;;

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
  long lineIndex = 0; //start on second line - ignore header

  String filename = null;
  boolean playing = false;
  boolean readNext = false;
  boolean eventred = false;

  String line;

  long timer=0;
  long timestamp = 0;
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
      if ( (millis() - timer) > timestamp) {

        readNext = true;
        eventred = false;

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
      }
    }
    //
  }

  boolean readLine() {
    line = readFromFile(dataPath(filepath));
    //line = readFromFile(dataPath(filepath), lineIndex);
    //this.lineIndex++;
    //println(line);
    if (line == null) {
      println("end of file");
      this.stopFile();
      if ( loop ) { //loop actovated
        this.playFile();//play again from start
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
        //if ( lineIndex == 0 ) {
        if ( !isNumeric(pieces[0]) ) {
          println("header skip");
          return false;
        }

        try {
          this.timestamp = Long.parseLong(pieces[0], 10);//timestamp
        }
        catch (NumberFormatException nfe) {
          //println(nfe);
          return false;
        }
        this.OSCaddress = pieces[1];//OSC address
        this.OSCtypetag = pieces[2];//OSC typetag

        //right now we are not using the timetag parameter
        //however this could be used to analyze difference between send time and recieve time
        //OSCtimetag = Long.parseLong(pieces[3]);//OSC timetag  present in OSC bundles

        this.myMessage = new OscMessage(OSCaddress); //reset
        //rest of the line should be values - check for them
        for (int i=0; i<OSCtypetag.length(); i++) {
          Character currType = OSCtypetag.charAt(i);
          //println("currr type: "+currType);
          if ( currType.equals('f') ) {
            this.myMessage.add( float(pieces[i+4]) );
          }
          if ( currType.equals('i') ) {
            this.myMessage.add( int(pieces[i+4]) );
          }
          if ( currType.equals('s') ) {
            this.myMessage.add( (String)pieces[i+4] );
          }
          if ( currType.equals('d') ) {
            this.myMessage.add( Double.valueOf(pieces[i+4]) ); //cast to double
          }
        }
        println("line typetag: "+OSCtypetag+" address: "+OSCaddress + " timestamp: "+timestamp);
        return true;
      }
    }
    return false;
  }

  //---------------------------------------------
  //read from file
  String readFromFile(String fileName) {
    try {
      RandomAccessFile raf = new RandomAccessFile(fileName, "r");
      //
      raf.seek(lineIndex);
      String currLine = raf.readLine();
      //println(currLine);
      this.lineIndex = raf.getFilePointer();
      println(this.lineIndex);
      raf.close();
      return currLine;
    }
    catch (IOException ex) {
      ex.printStackTrace();
      return null;
    }
  }
  //--------------------------------------------

  void playFile() {
    if (filepath != null) {
      if ( fileExists(filepath) ) {//init buffer reader
        playing = true;
        readNext = true;
        println("playback started from file "+filepath);
        //14220
        File file = new File(dataPath(filepath));
        println( "file size: "+file.length() ) ;//in bytes
        println( getFileSizeMegaBytes(file) +" MB");
        cp5.getController( "replayFile" ).setLabel("replaying...");
        timer = millis();
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
    lineIndex = 0; //start on second line - ignore header
    cp5.getController( "replayFile" ).setLabel("replay file");
    println("playback ended");
  }
}//END REPLAY CLASS
