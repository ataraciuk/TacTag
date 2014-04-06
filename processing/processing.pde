/*
100 = red
101 = black
*/

import oscP5.*;
import netP5.*;
import java.util.Map;
import java.util.Map.Entry;

HashMap<Integer,Player> players = new HashMap<Integer,Player>();
OscP5 oscP5;
NetAddress myRemoteLocation;
int gameStatus = 0; //0 = not started, 1 = choosing elem, 2 = fighting
int timeToChoose = 3000, timeToTouch = 5000, chooseBegin = -1, touchBegin = -1;

void setup() {
  size(displayWidth, displayHeight);
  textAlign(CENTER, CENTER);
  background(192,192,192);
  textFont(createFont("Arial", 100, true));
  
  oscP5 = new OscP5(this,28000);
 
  myRemoteLocation = new NetAddress("127.0.0.1",28000);
  
  oscP5.plug(this,"newPlayer","/newPlayer");
  oscP5.plug(this, "playerElem", "/playerElement");
  oscP5.plug(this, "playerTouch", "/playerTouch");
  players.put(100, new Player(color(255,0,0)));
  players.put(101, new Player(color(0,0,0)));
}

void draw() {
  int time = millis();
  if(gameStatus == 0 && !playerWithoutElem()) {
    setChoosing();
  }
  if(gameStatus == 1 && time > timeToChoose + chooseBegin) {
    setTouching();
  }
  if(gameStatus == 2 && time > timeToTouch + touchBegin) {
    setChoosing();
  }
  
  int size = players.size(), i = 0, pOffset;
  for(Player p : players.values()) {
    pOffset = i*width/size;
    stroke(0,0,0);
    fill(map(i,0,size,160,255));
    rect(pOffset,0,width/size,height);
    fill(p.myColor);
    drawTextShadows("Player "+(i+1),
      40,
      p.myColor,
      color(255),
      pOffset+20,
      0, width/size-40, 200, 3);
    if(!p.joined) {
      drawTextShadows("Touch your knee pad with your glove to join.",
        25,
        p.myColor,
        color(255),
        pOffset+20,
        0, width/size-40, 400, 1);
    }
    else {
      if(p.element == -1) {
        drawTextShadows("Joined!",
          25,
          p.myColor,
          color(255),
          pOffset+20,
          0, width/size-40, 400, 1);
      }
      drawTextShadows("Choose an element",
        25,
        p.myColor,
        color(255),
        pOffset+20,
        0, width/size-40, 500, 1);
    }
    i++;
  }
  displayTimer();
}

void setChoosing() {
  gameStatus = 1;
  chooseBegin = millis();
}

void setTouching() {
  gameStatus = 2;
  touchBegin = millis();
}

void displayTimer() {
  if(gameStatus > 0)
    drawTextOutline(""+ ((gameStatus == 1 ? (timeToChoose -millis() + chooseBegin) : (timeToTouch - millis() + touchBegin)) / 1000 + 1), 100, color(255,255,0), color(0), 0,0, width, height);
}

boolean playerWithoutElem() {
  for(Player p : players.values()) {
    if(p.element == -1) return true;
  }
  return false;
}

void newPlayer(int val){
  Player p = players.get(val);
  if(p != null) p.joined = true;
  println("new player!");
}

void playerElem(int playerCode, int elem) {
  if(gameStatus == 1 || gameStatus == 0) {
    Player p = players.get(playerCode);
    if(p != null) p.element = elem;
  }
}

void playerTouch(int who, int by) {
  if(gameStatus == 2 && who != by) {
    Player pWho = players.get(who);
    Player pBy = players.get(by);
    if(pWho != null && pBy != null) {
      int stronger = checkStronger(pWho, pBy);
      if(stronger != 0) {
        oscP5.send(new OscMessage("/endRound", stronger == 1 ? new Object[]{ who, by} : new Object[]{by, who}), myRemoteLocation);
        setChoosing();
      }
    }
  }
}


/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* with theOscMessage.isPlugged() you check if the osc message has already been
   * forwarded to a plugged method. if theOscMessage.isPlugged()==true, it has already 
   * been forwared to another method in your sketch. theOscMessage.isPlugged() can 
   * be used for double posting but is not required.
  */  
  if(theOscMessage.isPlugged()==false) {
  /* print the address pattern and the typetag of the received OscMessage */
    println("### received an osc message.");
    println("### addrpattern\t"+theOscMessage.addrPattern());
    println("### typetag\t"+theOscMessage.typetag());
  }
}

/*
Player getByCode(int code) {
  for(Player p : players) {
    if (p.code == code) return p;
  }
  return null;
}
*/

void sendSetColors() {
  for(Entry<Integer,Player> e : players.entrySet()) {
    OscMessage m = new OscMessage("/setColor", new Object[]{e.getKey(), e.getValue().element});
    oscP5.send(m, myRemoteLocation);
  }
}

int checkStronger(Player p1, Player p2) {
  if(p1.element == p2.element) return 0;
  else if(p1.element > p2.element) return p1.element == p2.element + 1 ? 1 : -1;
  else return p1.element + 1 == p2.element ? -1 : 1;
}

boolean sketchFullScreen() {
  return true;
}

void drawTextOutline(String s, int size, color cText, color cBorder, int x, int y, int w, int h) {
  textSize(size);
  fill(cBorder);
  text(s, x+1, y, w, h);
  text(s, x, y+1, w, h);
  text(s, x-1, y, w, h);
  text(s, x, y-1, w, h);
  fill(cText);
  text(s, x,y, w, h);
}

void drawTextShadows(String s, int size, color cText, color cBorder, int x, int y, int w, int h, int amount) {
  textSize(size);
  fill(cBorder);
  for(int i = 0; i <= amount; i++) text(s, x+i, y+i, w, h);
  fill(cText);
  text(s, x,y, w, h);
}
