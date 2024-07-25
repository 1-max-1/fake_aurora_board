class Hold {
  private int x;
  private int y;
  private int r;
  private int g;
  private int b;
  private boolean isBold;

  public Hold(int x, int y, int r, int g, int b, boolean isBold) {
    this.x = x;
    this.y = y;
    this.r = r;
    this.g = g;
    this.b = b;
    this.isBold = isBold;
  }

  public void Draw() {
    fill(r, g, b);
    if (isBold) {
      square(x * 40 + 15, y * 40 + 25, 25);
    } else {
       square(x * 40 + 40, y * 40 + 10, 15);
    }
  }
};
