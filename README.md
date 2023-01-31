# OSCreplay

## What is this good for?
Ever needed to record OSC events and replay them later? Want to send OSC from client side vanilla JavaSctipt via websockets? Now you can.

![Encoder screenshot](./assets/screenshot1.jpg)

## Download - OSC replay
* [MacOS Intelx64](PLACEHOLDER) TBD
* [Windows64bit](https://github.com/trackme518/OSCreplay/releases/download/v1.1_winX64/v1.1_winX64.7z)
* [Linux64bit](PLACEHOLDER) TBD

MacOS and Linux builds will be added later.

Download links provide zipped archive with the tool. You don't need to install anything - just unzip it and run "OSCReplay.exe" file.

## How to use it?
After unzipping simply double click the executable to run the app. You will see a window with GUI. 
 
* RECORD EVENTS - when toggled it will start to record incoming OSC or websockets events and save them into .CSV file in data folder. Make sure to click the toggle again to stop the recording and properly close the file.
* PLAYBACK FILE - dropdown list of avaliable files to replay. All files need to be placed inside "data" folder. Data folder is located inside the downloaded app.
* REPLAY FILE - start playing OSC events saved in .CSV file. You need to select which file to use first.
* LOOP - toggle to loop the replay so it will never stop.
* CLEAR - clear the status messages
* PERFORMANCE MODE - disable rendering GUI to speed up the program.

Displayed status messages are for debug - yellow ones are outgoing messages from replay. Green messages are incoming messages. Address pattern and typetag are printed. You can see last 10 messages. In performance mode no messages are being displayed to increase performance. 

## Setting OSC/Websocket IP, ports & more
Beside GUI there are more settings. Go into the data folder inside the OSCReplay App. Open "settings.json" in notepad.
```JSON
{
  "oscListenPort": 12000,
  "targetOscIp": "127.0.0.1",
  "useWebsocket": true,
  "myOscIp": "127.0.0.1",
  "websocketPrefix": "/oscutil",
  "websocketPort": 9999,
  "oscTargetPort": 16000,
  "maxFrameRate": 1000
}
```
* "oscListenPort": Integer - port where the App is listening for OSC commands (to control GUI remotely)
* "targetOscIp": String - IP where to send OSC commands
* "useWebsocket": Boolean - whether to use Websocket proxy
* "websocketPort": Integer - Websocket port - please note that firewall or your web browser might allow only certain ranges of ports, also some Apps such as TeamViewer might be already using some ports
* "oscTargetPort": Integer - where to send OSC commands, note that some apps might be already using some ports
* "maxFrameRate": Integer - set max framerate at which the App will try to run - 120 should be enough. This will influence performance and your PC reasources.

## OSC
ReplayOSC App supports only single messages (no bundles) and Integer, Float, String, Double variable types. App supports multiple variables in a single message. 

## .CSV file format
OSC/Websocket events are saved in .CSV file in data folder inside OSCreplay App. I am using buffered writer and reader so the file is written or red one line at a time. This is important to avoid out of memory error when reading / writing large files. CSV files uses ',' comma delimeter. First collumn is "timestamp" in milliseconds (Integer). First event is always timestamped as 0 - time before the first event arrive is ignored. Second collumn is "OSCaddress" - it should always start with "/" to comply with OSC protocol. Third collumn is "typetag". Typetag is used to determine how many variables are in the message data - each character represents one variable. Order matters. You can also have empty typetag in case there are no data in the message. Subsequent collumns are individual variables - number of variables must correspond to length of the typetag. 

| timestamp | OSCaddress | typetag | var1 | var2 | var3 | var4 |
| --------- | ---------- | ------- | ---- |----- |----- |----- |
|0 | /someaddress | ifsd | 16 | 16.666 | some text | 16.666 |


## How does it work?
Under the hood the tool is programmed in Processing Java to run GUI and OSC and Websocket server. 

## Websocket
You can send vanilla websocket messages to the app and it will proxy them as proper OSC messages to the target. You can also save them into .CSV file and send them as OSC later. Websocket messages need to be encoded in JSON format and send as plain String like so:

```JSON
{
  "address": "/sometarget",
  "data": [
    {
      "type": "d",
      "value": 16
    },
    {
      "type": "f",
      "value": 16
    },
    {
      "type": "s",
      "value": "sometext"
    },
    {
      "type": "i",
      "value": 16
    }
  ]
}
```
In HTML + JavaScript:
```HTML
<html>
<body>
<button onclick="sendMessage()">Send Message</button>

<script>
var ws = null;

function connectWebsocket() {
	if ("WebSocket" in window) {
		ws = new WebSocket("ws://127.0.0.1:9999/oscutil");
		ws.onopen = function () {
			console.log("Connection opened");
		};
		
		ws.onmessage = function (event) {
		    console.log("Message received: " + event.data);
		};
		
		ws.onclose = function () {
			console.log("Connection closed");
		};
	}
}

connectWebsocket(); //establish connection to OScreplay App

function sendMessage() {
  //Prepare Websocket message
  var obj = { "address":"/someoscaddress", "data":[] };
  obj['data'].push({"type":"i","value":16});
  obj['data'].push({"type":"f","value":16.333});
  obj['data'].push({"type":"s","value":"some text"});
  obj['data'].push({"type":"d","value":16.333});
  var myJSON = JSON.stringify(obj);
  if(ws == null){
  	console.log("Webscoket connection not established");
  }else{
  	ws.send(myJSON); //send via websocket
  }
}
</script>

</body>
</html>
```

Permissible types:
* i Integer
* f Float
* s String
* d Double

### Control OSCReplay remotely without GUI
You can also control the OSCReplay App with OSC or Websockets messages. Below see the list of "address pattern" - permissible value and type - description.
* "/oscutil_recording" - Integer 0 or 1 - trigger or end recording incoming messages into .CSV file.
* "/oscutil_play" - Integer 0 or 1 - start or stop replay from .CSV file (select the file to play first)
* "/oscutil_loop" - Integer 0 or 1 - set the replay to loop or play once
* "/oscutil_performance" - Integer 0 or 1 - enter or end performance mode
* "/oscutil_file" - Integer 0 to Infinity - select index of the file for replay
* "/oscutil_listfiles" - no values - This will return names of avaliable replay files as String with ';' delimeter
* "/oscutil_countfiles" - no values - This will return Integer with count of avaliable .CSV replay files.

### Windows
Tested on Windows 10. It should work out of the box. Just double click the "create_multichannel_audio2.exe" file. If you are using antivirus such as Windows Defender it will show warning - you can safely click "More info" and choose "Run anyway". Next time it should run without warning.

### MacOS
Tested on Catalina OS. On MacOs you need to allow installation from unknown sources. Open the Apple menu > System Preferences > Security & Privacy > General tab. Under Allow apps downloaded from select App Store and identified developers. To launch the app simply Ctrl-click on its icon > Open.

### Linux
Tested on Ubuntu 64bit. You can always run the app from the terminal. If using GUI and the app does not run when you double click the "create_multichannel_audio2" file icon you need to change the settings of your file explorer. In Nautilus file explorer click the hamburger menu (three lines icon next to minimise icon ), select "preferences". Click on "behaviour" tab, in the "Executable Text Files" option select "Run them". Close the dialogue and double click the "create_multichannel_audio2" file icon (bash script) - now it should start.

## Known bugs
If you are using websockets you need to close the connection from the client properly on exit otherwise there will websocket timeout error in the OSCReplay App and you will need to restart it.

## License
Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International. Please refer to the [license](https://creativecommons.org/licenses/by-nc-nd/4.0/). Author is not liable for any damage caused by the software. Usage of the software is completely at your own risk. For commercial licensing please [https://tricktheear.eu/contact/](contact) us.   
