import oscP5.*;
import netP5.*;

ArrayList<Player> players = new ArrayList<Player>();
OscP5 oscP5;
NetAddress myRemoteLocation;
int gameStatus = 0; //0 = not started, 1 = choosing elem, 2 = fighting

void setup() {
  size(400, 400);
  
  oscP5 = new OscP5(this,28000);
 
  myRemoteLocation = new NetAddress("127.0.0.1",28000);
  
  oscP5.plug(this,"newPlayer","/newPlayer");
  oscP5.plug(this, "playerElem", "/playerElement");
  oscP5.plug(this, "playerTouch", "/playerTouch");
}

void draw() {
}

void newPlayer(int val){
  players.add(new Player(val));
  println("new player!");
}

void playerElem(int playerCode, int elem) {
  if(gameStatus == 1) {
    Player p = getByCode(playerCode);
    if(p != null) p.element = elem;
  }
}

void playerTouch(int who, int by) {
  if(gameStatus == 2 && who != by) {
    Player pWho = getByCode(who);
    Player pBy = getByCode(by);
    if(pWho != null && pBy != null) {
      pBy.score++;
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

Player getByCode(int code) {
  for(Player p : players) {
    if (p.code == code) return p;
  }
  return null;
}
