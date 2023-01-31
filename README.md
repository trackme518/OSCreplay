# OSCreplay

## What is this good for?
Ever needed to record OSC events and replay them later? Want to send OSC from client side vanilla JavaSctipt via websockets? Now you can.

![Encoder screenshot](./assets/GUI_thin.jpg)

## Download - OSC replay
* [MacOS Intelx64](PLACEHOLDER) TBD
* [Windows64bit](https://github.com/trackme518/Sonification-of-a-juggling-performance-using-spatial-audio---Physical-based-rhytm-generator/releases/download/v3.0win64/lightbetas_v30_windows-amd64.7z)
* [Linux64bit](PLACEHOLDER) TBD

Download links provide zipped archive with the tool. You don't need to install anything - just unzip it and run "create_multichannel_audio2.exe" file. In case the links are not working you can also download the encoder directly from Github (click green "Code" button on upper left and select download ZIP).

## How to use it?
After unzipping simply double click the executable to run the app. You will see a window with GUI. 
 
* RECORD EVENTS - when toggled it will start to record incoming OSC or websockets events and save them into .CSV file in data folder. Make sure to click the toggle again to stop the recording and properly close the file.
* PLAYBACK FILE - dropdown list of avaliable files to replay. All files need to be placed inside "data" folder. Data folder is located inside the downloaded app.
* REPLAY FILE - start playing OSC events saved in .CSV file. You need to select which file to use first.
* LOOP - toggle to loop the replay so it will never stop.
* CLEAR - clear the status messages
* PERFORMANCE MODE - disable rendering GUI to speed up the program.

## .CSV file format
OSC/Websocket events are saved in .CSV file in data folder inside OSCreplay App. I am using buffered writer and reader so the file is written or red one line at a time. This is important to avoid out of memory error when reading / wring latge files. CSV files uses ',' comma delimeter. First collumn is "timestamp" in milliseconds (Integer). First event is always timestamped as 0 - time before the first event arrive is ignored. Second collumn is "OSCaddress" - it should always start with "/" to comply with OSC protocol. Third collumn is "typetag". Typetag is used to determine how many variables are in the message data - each character represents one variable. Order matters. Subsequent collumns are individual variables. 

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
  ws.send(myJSON); //send via websocket
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

### Windows
Tested on Windows 10. It should work out of the box. Just double click the "create_multichannel_audio2.exe" file. If you are using antivirus such as Windows Defender it will show warning - you can safely click "More info" and choose "Run anyway". Next time it should run without warning.

### MacOS
Tested on Catalina OS. On MacOs you need to allow installation from unknown sources. Open the Apple menu > System Preferences > Security & Privacy > General tab. Under Allow apps downloaded from select App Store and identified developers. To launch the app simply Ctrl-click on its icon > Open.

### Linux
Tested on Ubuntu 64bit. You can always run the app from the terminal. If using GUI and the app does not run when you double click the "create_multichannel_audio2" file icon you need to change the settings of your file explorer. In Nautilus file explorer click the hamburger menu (three lines icon next to minimise icon ), select "preferences". Click on "behaviour" tab, in the "Executable Text Files" option select "Run them". Close the dialogue and double click the "create_multichannel_audio2" file icon (bash script) - now it should start. The encoder is using [static builds](https://johnvansickle.com/ffmpeg/) of FFmpeg inside the "data" folder. You can swap that for your own ffmpeg build if needed.    

## License
Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International. Please refer to the [license](./license/by-nc-sa.md). Author is not liable for any damage caused by the software. Usage of the software is completely at your own risk. For commercial licensing please [https://tricktheear.eu/contact/](contact) us.   
