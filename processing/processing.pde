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

void setup() {
  size(displayWidth, displayHeight);
  textAlign(LEFT, CENTER);
  //background(255,255,255);
  
  oscP5 = new OscP5(this,28000);
 
  myRemoteLocation = new NetAddress("127.0.0.1",28000);
  
  oscP5.plug(this,"newPlayer","/newPlayer");
  oscP5.plug(this, "playerElem", "/playerElement");
  oscP5.plug(this, "playerTouch", "/playerTouch");
  players.put(100, new Player(color(255,0,0)));
  players.put(101, new Player(color(0,0,0)));
}

void draw() {
  int size = players.size(), i = 0, pOffset;
  for(Player p : players.values()) {
    fill(p.myColor);
    pOffset = i*width/size;
    rect(pOffset,0,width/size,height);
    if(!p.joined) {
      drawText("Touch your kneed pad with your glove to join!",
        20,
        255,
        255,
        255,
        0,0,0,
        40+pOffset,
        400);
    }
    i++;
  }
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

void drawText(String s, int size, int rText, int gText, int bText, int rBorder, int gBorder, int bBorder, int x, int y) {
  textSize(size);
  fill(rBorder, gBorder, bBorder);
  text(s, x+1, y);
  text(s, x, y+1);
  text(s, x-1, y);
  text(s, x+1, y-1);
  fill(rText, gText, bText);
  text(s, x,y);
}
