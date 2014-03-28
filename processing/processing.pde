import oscP5.*;
import netP5.*;

ArrayList<Player> players = new ArrayList<Player>();
OscP5 oscP5;
NetAddress myRemoteLocation;

void setup() {
  size(400, 400);
  
  oscP5 = new OscP5(this,28000);
 
  myRemoteLocation = new NetAddress("127.0.0.1",28000);
  
  oscP5.plug(this,"newPlayer","/newPlayer");
}

void draw() {
}

void newPlayer(int val){
  println("new player!");
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
