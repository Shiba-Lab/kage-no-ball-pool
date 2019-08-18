class Corners {
  PApplet pa;
  int n;
  PVector corner[];
  int hold=-1;
  Action action;
  Corners(PApplet pa, int n, Action action, PVector... p) {
    this.pa=pa;
    this.n=n;
    this.action=action;
    corner=new PVector[n];
    for (int i=0; i<n; i++) {
      corner[i]=p[i];
    }
  }
  void display() {
    pa.fill(255);
    for (int i=0; i<n; i++) {
      if (hold==i)pa.noFill();
      pa.ellipse(corner[i].x, corner[i].y, 10, 10);
    }
    pa.beginShape();
    pa.stroke(255);
    pa.strokeWeight(1);
    for (int i=0; i<n; i++) {
      pa.noFill();
      pa.vertex(corner[i].x, corner[i].y);
    }
    pa.endShape(CLOSE);
  }
  void setCorners(int n, PVector... p) {
    for (int i=0; i<n; i++) {
      corner[i].set(p[i]);
    }
  }
  void setCorner(int n, PVector p) {
    corner[n].set(p);
  }
  void pressed(float x, float y) {
    int nearest=-1;
    float min=100000000;
    for (int i=0; i<n; i++) {
      float d=dist(x, y, corner[i].x, corner[i].y);
      if (d<min) {
        min=d;
        nearest=i;
      }
    }
    if (dist(x, y, corner[nearest].x, corner[nearest].y)<10) {
      hold=nearest;
      corner[hold].set(x, y);
    }
  }
  void dragged(float x, float y) {
    if (hold!=-1) {
      corner[hold].set(x, y);
    }
  }
  void released() {
    if (hold!=-1) {
      action.run(n, corner);
      hold=-1;
    }
  }
}

interface Action {
  void run(int n, PVector... corner);
}
