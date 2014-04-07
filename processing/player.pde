class Player {
  public int score = 0;
  public int element = (int)random(1,10);
  public color myColor;
  public color myBg;
  public boolean joined = true;
  
  public Player(color c) {
    myColor = c;
    myBg = color(red(c),green(c),blue(c),25);
  }
}
