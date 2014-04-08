class Player {
  public int score = 0;
  public int element = -1;
  public color myColor;
  public color myBg;
  public boolean joined = false;
  
  public Player(color c) {
    myColor = c;
    myBg = color(red(c),green(c),blue(c),25);
  }
}
