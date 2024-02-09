import java.nio.channels.FileChannel;
import java.io.RandomAccessFile;
import java.nio.ByteBuffer;
import java.io.FileNotFoundException;

boolean recordingEvents = false; //flag to save the incoming events to text file
boolean convertNtpToUnix = false; //whether to convert timetag of the incoming OSC msg to UNIX format (easier format)
String recpath;

long recTimeOffset = 0;

//threaded async process for writing to the file line by line
class SaveEvent implements Runnable {
  OscMessage msg;
  String csvString;
  long bufferPosition = 0;
  byte[] csvBytes;

  SaveEvent(OscMessage _msg, long _pos) {
    this.msg = _msg;
    this.bufferPosition = _pos;
    this.csvString = oscMsgToCsvString();
    this.csvBytes = this.csvString.getBytes();
    //this.lineLengthBytes = this.csvString.length()*2; //every char is 2 bytes - 16bit
  }

  String oscMsgToCsvString() {
    String addr = msg.addrPattern();
    String typetag = msg.typetag();

    //get timetag - this is only present in OSC bundle messages otherwise equals to 1
    //convert to unix because NTP is stupid
    long timetag = msg.timetag();
    if (convertNtpToUnix) {
      if ( timetag != 1) {
        timetag = ntpToUnix( timetag );
      }
    }

    long currtime =  (millis()-recTimeOffset);

    String record = currtime+","+addr+","+typetag+","+timetag+",";

    for (int i=0; i< typetag.length(); i++) {
      Character currType = typetag.charAt(i);
      if ( currType.equals('f') ) {
        record+=msg.get(i).floatValue()+",";
      }
      if ( currType.equals('i') ) {
        record+= msg.get(i).intValue() +",";
      }
      if ( currType.equals('s') ) {
        record+= msg.get(i).stringValue() +",";
      }
      if ( currType.equals('d') ) {
        record+= msg.get(i).doubleValue() +","; //cast double to string
      }
    }

    record = record.substring(0, record.length()-1)+ '\n' ;//trim last comma, add line break
    return record;
  }

  void write() {
    Thread newThread = new Thread(this);
    newThread.start();
  }

  void run() {
    this.saveEvent();
  }

  //save incoming events to text file with timestamp
  void saveEvent() {
    if (!recordingEvents) {
      return;
    }
    if (recordingEvents) {
      //SLOW
      //output.println( record );//output to buffered writer
      //FASTER
      writeToFile(recpath, this.csvString, true, this.bufferPosition);
    }
  }
  //-----
}

//init output file strea
void startRecEvent() {
  try {
    recpath = dataPath("rec_"+day()+"_"+month()+"_"+year()+"-"+ int( random(0, 1)*1000 )+".csv"); //reset record path
    File yourFile = new File(recpath);
    yourFile.createNewFile(); // if file already exists will do nothing
    recordingEvents = true;
    String header ="timestamp,OSCaddress,typetag,timetag"+"\n";
    bufferPosition = writeToFile(recpath, header, false, 0);
    recTimeOffset = millis();
    println("recording started to "+recpath);
  }
  catch (IOException ioe) {
    ioe.printStackTrace();
  }
}
//close and flush file output stream
void stopRecEvent() {
  recordingEvents = false;
  recTimeOffset = 0;
  println("recording stoped");
}

//----------------------------------------------------------------------------------------------------------------------------
//save genral settings
void saveData() {
  JSONObject json = new JSONObject();
  //OSC

  json.setInt("oscListenPort", oscListenPort);
  json.setString("targetOscIp", targetOscIp);
  json.setInt("oscTargetPort", oscTargetPort);
  //Websocket
  json.setInt("websocketPort", websocketPort);
  json.setString("websocketPrefix", websocketPrefix);
  json.setBoolean("useWebsocket", useWebsocket);
  json.setBoolean("proxyEnabled", proxyEnabled);

  json.setBoolean("convertNtpToUnix", convertNtpToUnix);

  //GUI
  json.setInt("maxFrameRate", maxFrameRate);
  saveJSONObject(json, dataPath("settings.json") );
}

//-------------------------------------------------------------------
//saves & loads how much distance all motors travelled in total - count in full revolutions


//------------------------------------------------------------------------
void loadData() {
  String fileName = "settings.json";
  if ( fileExists(fileName) != true ) {
    println("settings.json is missing in data folder");
    println("creating new default settings for you as a template to modify...");
    saveData();
    println("modify the file settings.json in data folder to change motors count and IP adresses");
  }
  JSONObject json = loadJSONObject( dataPath(fileName) );
  //OSC
  oscListenPort = json.getInt("oscListenPort");
  targetOscIp = json.getString("targetOscIp");
  oscTargetPort = json.getInt("oscTargetPort");
  maxFrameRate = json.getInt("maxFrameRate");
  //Websocket
  websocketPort = json.getInt("websocketPort");
  websocketPrefix = json.getString("websocketPrefix");
  useWebsocket = json.getBoolean("useWebsocket");
  proxyEnabled = json.getBoolean("proxyEnabled");

  convertNtpToUnix = json.getBoolean("convertNtpToUnix");
  println("settings loaded");
}
