//display send and recieved messages for debug in rolling array

EventStatus eventstatus;

class EventStatus {
  Event[] events = new Event[10]; //hold events in array

  EventStatus() {
  }

  void clear() {
    events = new Event[10]; //reset array
  }

  void addEventStatus( boolean incoming, String address, String type ) {
    Event[] reorderEventParams = new Event[events.length];
    for (int i=events.length-1; i>-1; i--) {
      if ( i-1 >=0 ) {
        reorderEventParams[i] = events[i-1];
      }
    }
    System.arraycopy(reorderEventParams, 0, events, 0, events.length); // <- we need to copy to existing array...
    events[0] = new Event( incoming, address, type ); //store event to string for debug
  }

  void displayEvents() {
    pushStyle();
    textFont(mediumFont);
    for (int i=0; i < events.length; i++) {
      if ( events[i] != null ) {
        try {
          if ( events[i].in ) { // incoming message
            fill(204, 255, 204);
          } else {
            fill(255, 255, 204);
          }
          if ( events[i] != null ) {
            text(events[i].addr+" "+events[i].typetag, 250, 40+i*30);
          }
        }catch(Exception e) {
          println(e);
        }
      }
    }
    popStyle();
  }

  class Event {
    String addr = "";
    String typetag = "";
    boolean in = false;
    int timestamp = 0;
    String time = "";

    Event(boolean incoming, String address, String type) {
      in = incoming;
      addr = address;
      typetag = type;
      timestamp = millis();
      time = hour()+":"+minute()+":"+second(); //display incoming message current time
    }
  }
  /*
  // Helper class implementing Comparator interface - not used right now...
  class sortEvents implements Comparator<Event> {
    // Sorting in ascending order against timestamp
    public int compare(Event a, Event b)
    {
      return a.timestamp - b.timestamp;
    }
  }
  */
}
