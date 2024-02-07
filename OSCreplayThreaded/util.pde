import java.util.Arrays;
import java.util.List;
import java.util.ArrayList;

boolean fileExists(String fileName) {
  File dataFolder = new File(dataPath(""));
  for (File file : dataFolder.listFiles()) {
    if (file.getName().equals(fileName)) {
      return true;
    }
  }
  return false;
}
//----------------------------------------------
//exponential running average
//N=num samples you want to average over
float approxRollingAverage (float avg, float new_sample, int N) {
  avg -= avg / N;
  avg += new_sample / N;
  return avg;
}
//----------------------------------------------------
/*
float[] getMaxVectorIndex(PVector v, boolean absolute) {
 float[] vals = v.array(); //get components as array
 float max = Float.MIN_VALUE;
 int index = -1;
 
 for (int i = 0; i < vals.length; i ++) {
 
 float currval = vals[i];
 if (absolute) {
 currval = abs(currval);
 }
 
 if (max <currval || max == Float.MIN_VALUE ) {
 max = currval;
 index = i;
 }
 }
 float[] out = {max, (float)index};
 return out;
 }
 */
float[] getMaxVectorIndex(PVector v) {
  float[] vals = v.array(); //get components as array
  float mymax = -1*Float.MAX_VALUE;
  int myindex = -1;
  for (int i = 0; i < vals.length; i ++) {
    if (mymax <abs( vals[i] ) ) {
      mymax = abs(vals[i]);
      myindex = i;
      //println("run "+i+" : "+abs(vals[i]) );
    }
  }
  float[] out = {mymax, (float)myindex};
  return out;
}
//----------------------------------------------------
//clean exit - close output streams currently opened
void exit() {
  println("exiting");
  if (recordingEvents) {
    stopRecEvent();
  }
  /*
  if (midifile !=null) {
    if (midifile.synth !=null) {
      midifile.synth.close();
      println("synth closed");
    }
  }
  */
  super.stop();
  super.exit();
}

//-----------------------------------------------
public static boolean isInteger(String s) {
  return isInteger(s, 10);
}

public static boolean isInteger(String s, int radix) {
  if (s.isEmpty()) return false;
  for (int i = 0; i < s.length(); i++) {
    if (i == 0 && s.charAt(i) == '-') {
      if (s.length() == 1) return false;
      else continue;
    }
    if (Character.digit(s.charAt(i), radix) < 0) return false;
  }
  return true;
}
//--------------------------------------------------

ArrayList<String> listFiles(String extension) {
  ArrayList<String> filesPath = new ArrayList<String>(); //init path list
  java.io.File dir = new java.io.File(sketchPath("data")); //locate data folder
  File[] files= dir.listFiles();
  int filteredFilesCount=0;
  for (int i = 0; i <= files.length - 1; i++)
  {
    String path = files[i].getAbsolutePath();
    if (path.toLowerCase().endsWith(extension))
    {
      filesPath.add(filteredFilesCount, files[i].getName() );
      //println(files[i].getName());
      filteredFilesCount++;
    }
  }
  println(filesPath.size()+" files in data folder");
  println("From which "+filteredFilesCount+" is supported files");
  return filesPath;
}
//-----------------------------------------
ArrayList<String> trimFilesNames(ArrayList<String> inlist, int numChars) {
  ArrayList<String>trimmedList=new ArrayList<String>();
  for (int i=0; i<inlist.size(); i++) {
    String trimmedLine = inlist.get(i);
    if ( trimmedLine.length() >  numChars ) {
      trimmedLine = trimmedLine.substring(0, numChars);
    }
    trimmedList.add( trimmedLine );
  }
  return trimmedList;
}
//---------------------------------
//remap exponentionally -> non linear mapping...
float remapExp(float value, float start1, float stop1, float start2, float stop2, int exp) {
  float t = (value-start1)/(stop1-start1); //where the value is between min and max
  t = pow(t, exp);
  //println("t val: "+t);
  float outgoing = start2 + (stop2 - start2)*t;
  return outgoing;
}
//----------------------------------
color dimmColor(color c, float val) {
  float r = c >> 16 & 0xFF;
  float g = c >> 8 & 0xFF;
  float b = c  & 0xFF;

  color out = color( r*val, g*val, b*val );
  //color out = color(r,g,b,val);
  return out;
}
//-------------------------------------
int limitNumber(int val, int mymin, int mymax) {
  int out = max(mymin, val);
  out = min(out, mymax);
  return out;
}

float limitNumber(float val, float mymin, float mymax) {
  float out = max(mymin, val);
  out = min(out, mymax);
  return out;
}

public static long ntpToUnix(long ntpTimestamp) {
  final long NTP_EPOCH_OFFSET = 2208988800L; // Number of seconds between 1900-01-01 and 1970-01-01
  final long NTP_FRACTION_SCALE = 1L << 32; // 2^32
  // Extract seconds and fraction parts from NTP timestamp
  long ntpSeconds = ntpTimestamp >>> 32;
  long ntpFraction = ntpTimestamp & 0xFFFFFFFFL; // Treat as unsigned
  // Convert NTP timestamp to Unix timestamp
  long unixSeconds = ntpSeconds - NTP_EPOCH_OFFSET;
  long unixMillis = (long) ((double) ntpFraction / (double) NTP_FRACTION_SCALE * 1000.0);
  long unixTimestamp = unixSeconds * 1000L + unixMillis;
  return unixTimestamp+1; //+1 is arbitrary - but it seems missing somehow
}

public static long unixToNtp(long unixTimestamp) {
  final long NTP_EPOCH_OFFSET = 2208988800L; // Number of seconds between 1900-01-01 and 1970-01-01
  final long NTP_FRACTION_SCALE = 1L << 32; // 2^32
  // Convert Unix timestamp to NTP timestamp
  long ntpSeconds = unixTimestamp / 1000L + NTP_EPOCH_OFFSET;
  long ntpFraction = (long) ((double) (unixTimestamp % 1000L) / 1000.0 * (double) NTP_FRACTION_SCALE);
  // Combine seconds and fraction into a single long value
  long ntpTimestamp = (ntpSeconds << 32) | (ntpFraction & 0xFFFFFFFFL); // Treat as unsigned
  ntpTimestamp = ntpTimestamp & 0x7FFFFFFFFFFFFFFFL; // Mask out sign bit - treat as unsigned
  return ntpTimestamp;
}
