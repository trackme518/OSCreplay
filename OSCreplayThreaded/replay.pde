import java.util.stream.*;

Replay replay;
ArrayList<String>replayFilesAvailable = new ArrayList<String>();
boolean resaveOnReplay = false; //this for dev purposes only - update variables in files....DELETE IN PRODUCTION!!!

void initReplay() {
  replay = new Replay();
  replayFilesAvailable = listFiles(".csv");
}

class Replay implements Runnable {
      BufferedReader reader;
   // String line;
    
  ArrayList<OscMessage>messages = new ArrayList<OscMessage>();
  //OscBundle bundle = new OscBundle();
  //ArrayList<Thread>threads = new ArrayList<Thread>();
  //Thread localThread;
  //OscMessage
  boolean loop = false;

  String filepath = null;

  String filename = null;
  boolean playing = false;
  int threadsRunning = 0;

  //int lineIndex = 1; //start on second line - ignore header

  int timer=0;
  //int timestamp = 0;
  //OscMessage myMessage = null;
  //String OSCaddress = "";
  //String OSCtypetag = "";
  //long OSCtimetag = 1;
  //---------------------------------------------------------------
  Replay() {
  }

  void run() {
    readTableLine();
  }

  //main function to read from file, checks against current time and exucte events
  void updateReplay() {
    //read from file---
    if (playing) {

      //bundle = new OscBundle();
      if ( threadsRunning < 100 ) {
        for (int i=0; i<10; i++) {
          Thread newThread = new Thread(this);
          threadsRunning++;
          newThread.start();
        }
        //oscP5.send(otherServerLocation, bundle);
        for (int i=0; i<messages.size(); i++) {
          oscP5.send(messages.get(i), otherServerLocation);
          println(threadsRunning);
        }
        messages.clear();
        //osc.send(addr, bundle);
        //println(threadsRunning);
      } else {
        println("exceeded 100 threads running");
      }
    }
    //--------
  }

  boolean readTableLine() {
    BufferedReader treader = createReader(filepath);
    String line;

    int timestamp = 0;
    OscMessage myMessage = null;
    String OSCaddress = "";
    String OSCtypetag = "";


try (Stream<String> lines = Files.lines(Paths.get("file.txt"))) {
    line32 = lines.skip(31).findFirst().get();
}

    try {
      line = treader.readLine();
    }
    catch (IOException e) {
      e.printStackTrace();
      line = null;
      threadsRunning--;
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
      threadsRunning--;
      return false;
    } else {
      //prepare parts of the message
      String[] pieces = split(line, ',');
      if ( pieces.length > 3 ) {
        //skip header - non integer type
        if ( !isInteger( pieces[0], 10 ) ) {
          threadsRunning--;
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

        if ( millis() - timer > timestamp) {

          //if (!performanceModeSet) {
          //  String currAdd = OSCaddress;
          //  if (currAdd.length()>30) {
          //    currAdd = OSCaddress.substring(0, 30); //trimm to 30 characters
          //  }
          //  eventstatus.addEventStatus( false, currAdd, OSCtypetag ); //add to debug messages
          //}

          //SEND EVENTS OVER OSC :-------
          messages.add(myMessage);
          //bundle.add(myMessage);
          //oscP5.send(myMessage, otherServerLocation);
          //OscP5.flush(myMessage, otherServerLocation); //send without triggering onOSC event listener
          //------------------------------------------
        }
        //println("line typetag: "+OSCtypetag+" address: "+OSCaddress);
        threadsRunning--;
        return true;
      }
    }
    threadsRunning--;
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
        //readNext = true;
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
