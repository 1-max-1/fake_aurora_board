DataDecoder decoder;
CommsHandler comms = new CommsHandler();

PImage bolds;
PImage screws;

long timeOfLastPortCheck = 0;

void setup() {
  size(700, 785);
  decoder = new DataDecoder(this);
  drawCOMPorts();
  bolds = loadImage("45-1.png");
  screws = loadImage("46-1.png");
}

// Draws all of the active COM ports on the screen with a number mapped to each of them.
// Currently only displays the first 10 COM ports.
void drawCOMPorts() {
  background(255);
  fill(0);
  
  textAlign(CENTER);
  textSize(21);
  text("Please select a serial port by pressing the corresponding number key:", width / 2, 30);
  textSize(14);
  textAlign(LEFT);
  
  comms.refreshPorts();
  String[] ports = comms.getPorts();
  for (int i = 0; i < min(ports.length, 10); i++) {
    text(String.valueOf(i) + ":  " + ports[i], 30, i * 25 + 70);
  }
  text("r: Refresh port list", 30, ports.length * 25 + 70);
}

void keyPressed() {
  // If we are on any screen except the main menu, then only accept key presses on the 'q' q( for quit) key.
  // In which case we abort and go back to main COM port menu.
  if (comms.currentState != BoardState.IDLE) {
    if (key == 'q') {
      comms.closePort();
      drawCOMPorts();
    }
    return;
  }
  
  // 'R' key is refresh COM ports
  if (key == 'r') {
    drawCOMPorts();
    return;
  }
  
  int index = 0;
  try {
    index = Integer.parseInt(Character.toString(key));
  } catch (NumberFormatException nfe) {
    return;
  }
  
  // Otherwise the key press will be for selecting a COM port
  if (index < comms.getPorts().length) {
    background(255);
    textAlign(CENTER);
    textSize(21);
    text("Connecting...\n\nPress 'q' to cancel.", width / 2, height / 2);
    
    if (!comms.openPort(this, comms.getPorts()[index])) {
      drawCOMPorts();
      fill(255, 0, 0);
      textSize(20);
      text("Failed to open port", width - 230, 75);
    }
  }
}

// Draws the 17x19 fake aurora board as empty white squares (black outline).
void drawEmptyBackground() {
  background(255, 255, 255);
  
  textSize(14);
  textAlign(LEFT);
  fill(0);
  text("Press 'q' to go back to COM port menu", 5, 13);
  
  image(bolds, -15, 15, width + 25, height);
  image(screws, -15, 15, width + 25, height);
  
  stroke(0, 63);
  noFill();
  
  // Add bold holds
  for (int x = 0; x < 17; x++) {
    for (int y = 0; y < 19; y++) {
      square(x * 40 + 15, y * 40 + 25, 25);
    }
  }
  // Add screw holds
  for (int x = 0; x < 9; x++) {
    for (int y = 0; y < 8; y++) {
      square(x * 80, y * 80 + 130, 15);
    }
  }
  for (int x = 0; x < 9; x++) {
    for (int y = 0; y < 7; y++) {
      square(x * 80 + 40, y * 80 + 170, 15);
    }
  }
  for (int x = 0; x < 18; x++) {
      square(x * 40, 1 * 770, 15);
  }
}

void draw() {
  if (comms.currentState == BoardState.IDLE)
    return;
    
  if (millis() - timeOfLastPortCheck > 3000) {
    // If this returns false then the serial port has been closed - maybe someone pulled the usb cable out. In any case, we go back to main menu.
    if (!comms.portOK())
      drawCOMPorts();
    timeOfLastPortCheck = millis();
  }
  
  if (comms.currentState == BoardState.CONNECTING || comms.currentState == BoardState.BOOTING) {
    // If we have a valid API level then the boot has completed succesfully - we are connected.
    int apiLevel = comms.checkForAPILevel();
    if (apiLevel > -1) {
      decoder.setAPILevel(apiLevel);
      drawEmptyBackground();
    }
  }
  
  // If we have connected, then just wait until the decoder recevies all packets for a message, then draw the holds
  while (comms.currentState == BoardState.CONNECTED && comms.bytesAvailable() > 0) {
    decoder.newByteIn(comms.read());
    if (decoder.allPacketsReceived) {
      drawEmptyBackground();
      for(Hold h : decoder.getCurrentPlacements()) {
        h.Draw();
      }
    }
  }
}
