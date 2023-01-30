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
