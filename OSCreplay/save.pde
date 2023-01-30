//save recorded events for later
import java.io.FileWriter;
import java.io.BufferedWriter;

//boolean recevents = false; //flag to save the incoming events to text file
boolean recordingEvents = false; //flag to save the incoming events to text file
String recpath; // = dataPath("recordedEvents_"+day()+"_"+month()+"_"+year()+"-"+ int( random(0,1)*1000 )+".csv");
int recTimeOffset = 0;
boolean firtEventSaved = false; //first event was saved
PrintWriter output;

//save incoming events to text file with timestamp
void saveEvent( OscMessage msg ) {

  if (output != null && recordingEvents) {
    int currtime = millis();
    if (!firtEventSaved) {
      recTimeOffset = millis();
      firtEventSaved = true;
    }

    String addr = msg.addrPattern();
    String typetag = msg.typetag();
    String record = str(currtime-recTimeOffset)+","+addr+","+typetag+",";

    for (int i=0; i< typetag.length(); i++) {
      Character currType = typetag.charAt(i);
      if ( currType.equals('f') ) {
        record+=str( msg.get(i).floatValue() )+",";
      }
      if ( currType.equals('i') ) {
        record+=str( msg.get(i).intValue() )+",";
      }
      if ( currType.equals('s') ) {
        record+= msg.get(i).stringValue() +",";
      }
    }

    record = record.substring(0, record.length()-1);//trim last comma
    //println( record );
    output.println( record );//output to buffered writer
  }
}
//init output file strea
void startRecEvent() {
  recpath = dataPath("rec_"+day()+"_"+month()+"_"+year()+"-"+ int( random(0, 1)*1000 )+".csv"); //reset record path
  output = createWriter(recpath);
  recordingEvents = true;
  String header ="timestamp,OSCaddress,typetag";
  output.println( header ); //write header to the file
  println("recording started to "+recpath);
}
//close and flush file output stream
void stopRecEvent() {
  if (output != null) {
    output.flush();
    output.close();
  }
  recordingEvents = false;
  firtEventSaved = false;
  recTimeOffset = 0;
  println("recording stoped");
}

//----------------------------------------------------------------------------------------------------------------------------
//save genral settings
void saveData() {
  JSONObject json = new JSONObject();
  //OSC
  json.setString("myOscIp", myOscIp);
  json.setInt("oscListenPort", oscListenPort);
  json.setString("targetOscIp", targetOscIp);
  json.setInt("oscTargetPort", oscTargetPort);
  //Websocket
  json.setInt("oscTargetPort", websocketPort);
  json.setString("websocketPrefix", websocketPrefix);
  json.setBoolean("useWebsocket", useWebsocket);
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
  myOscIp = json.getString("myOscIp");
  oscListenPort = json.getInt("oscListenPort");
  targetOscIp = json.getString("targetOscIp");
  oscTargetPort = json.getInt("oscTargetPort");
  maxFrameRate = json.getInt("maxFrameRate");
  //Websocket
  websocketPort = json.getInt("oscTargetPort");
  websocketPrefix = json.getString("websocketPrefix");
  useWebsocket = json.getBoolean("useWebsocket");

  println("settings loaded");
}