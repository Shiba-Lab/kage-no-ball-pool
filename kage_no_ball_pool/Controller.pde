import controlP5.*;
class Controller extends PApplet {//PC上で当日調整をしやすくするためのコントローラー
  int w, h;
  PApplet parent;
  ControlP5 cp5;
  PImage bg;
  float imgw, imgh;
  PVector gp;
  Corners corners;
  Controller(PApplet parent, int w, int h, String _name) {
    super();   
    this.parent = parent;
    this.w=w;
    this.h=h;
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }
  public void settings() {
    size(w, h);
  }
  public void setup() {
    surface.setLocation(10, 10);
    cp5 = new ControlP5(this);

    cp5.addButton("saveD")//saveするためのボタン
      .setLabel("save")
      .setPosition(width*0.1, height*0.1)
      .setSize((int)(width*0.2), (int)(height*0.05))
      .plugTo(parent, "saveData");

    cp5.addButton("load")//loadするためのボタン
      .setLabel("load")
      .setPosition(width*0.1, height*0.15)
      .setSize((int)(width*0.2), (int)(height*0.05))
      .plugTo(parent, "loadData");

    cp5.addToggle("view")//影部分の可視化のスイッチ
      .setLabel("view")
      .setPosition(width*0.4, height*0.1)
      .setSize((int)(width*0.1), (int)(height*0.05))
      .plugTo(shadow, "setView")
      .setValue(true)
      .setMode(ControlP5.SWITCH);

    cp5.addSlider("brightness")//影判定のしきい値を変更するスライダー
      .setLabel("brightness")
      .setPosition(width*0.6, height*0.1)
      .setSize((int)(width*0.2), (int)(height*0.05))
      .setValue(80)
      .setRange(0, 255)
      .plugTo(shadow, "setBr");

    cp5.addSlider("resolution")//影の判定の解像度を変更するスライダー
      .setLabel("resolution")
      .setPosition(width*0.6, height*0.15)
      .setSize((int)(width*0.2), (int)(height*0.05))
      .setValue(4)
      .setRange(1, 20)
      .plugTo(shadow, "setResolution");

    cp5.addSlider("particle_size")//出現する物体の大きさを変更するスライダー
      .setLabel("particle_size")
      .setPosition(width*0.1, height*0.3)
      .setSize((int)(width*0.2), (int)(height*0.05))
      .setValue(particles.getDefsize())
      .setRange(10, 80)
      .plugTo(particles, "setDefsize");

    cp5.addSlider("particle_pop")//物体の出現頻度
      .setLabel("particle_pop")
      .setPosition(width*0.1, height*0.35)
      .setSize((int)(width*0.2), (int)(height*0.05))
      .setValue(particles.getPopstep())
      .setRange(1, 20)
      .plugTo(particles, "setPopstep")
      .setNumberOfTickMarks(10);

    cp5.addButton("clear_particles")//画面上の物体の一括消去
      .setLabel("clear_particles")
      .setPosition(width*0.1, height*0.4)
      .setSize((int)(width*0.2), (int)(height*0.05))
      .plugTo(parent, "clearP");

    cp5.addFrameRate()
      .setInterval(10)
      .setPosition(0, height - 10);

    cp5.addButton("exp")//四隅のポイントの拡大
      .setLabel("expand")
      .setPosition(width*0.6, height*0.3)
      .setSize((int)(width*0.2), (int)(height*0.05))
      .plugTo(pc, "expand");

    cp5.addButton("con")//四隅のポイントの縮小
      .setLabel("contract")
      .setPosition(width*0.6, height*0.35)
      .setSize((int)(width*0.2), (int)(height*0.05))
      .plugTo(pc, "contract");

    cp5.addButton("clear_corner")//四隅のポイントの消去
      .setLabel("clear_corner")
      .setPosition(width*0.6, height*0.4)
      .setSize((int)(width*0.2), (int)(height*0.05))
      .plugTo(pc, "clearI_corner");
    //.plugTo(particles, "clear");


    cp5.addSlider("gravity")
      .setLabel("gravity")
      .setPosition(width*0.1, height*0.5)
      .setSize((int)(width*0.2), (int)(height*0.05))
      .setValue(10)
      .setRange(0, 500)
      .plugTo(this, "setGravity");
    PGraphics pg=createGraphics(width, height);//背景画像の設定
    pg.beginDraw();
    pg.background(0, 15, 30);
    pg.stroke(10, 115, 130);
    for (int i=0; i<width; i+=width/10) {
      pg.line(0, i, width, i);
      pg.line(i, 0, i, height);
    }
    pg.endDraw();
    bg=pg.copy();
    imageMode(CENTER);
    imgw=height*0.4/cam.height*cam.width;
    imgh=height*0.4;
    corners=new Corners(this, 4, new Action() {
      public void run(int n, PVector... corner) {
        println(corner);
        PVector[] temp=new PVector[n];
        for (int i=0; i<n; i++) {
          temp[i]=new PVector(map(corner[i].x, width*0.5-imgw*0.5, width*0.5-imgw*0.5+imgw, 0, cam.width), map(corner[i].y, height*0.8-imgh*0.5, height*0.8-imgh*0.5+imgh, 0, cam.height));
        }
        pc.setI_corner(temp);
      }
    }
    , 
      new PVector(width*0.5-imgw*0.5, height*0.8-imgh*0.5), 
      new PVector(width*0.5+imgw*0.5, height*0.8-imgh*0.5), 
      new PVector(width*0.5+imgw*0.5, height*0.8+imgh*0.5), 
      new PVector(width*0.5-imgw*0.5, height*0.8+imgh*0.5)
      );
  }
  void setGravity(float g) {
    gravity=g;
    box2d.setGravity(0, -g);
  }
  void ellipse(PVector p, float w, float h) {
    ellipse(p.x, p.y, w, h);
  }
  void draw() {
    image(bg, width*0.5, height*0.5);
    image(cam, width*0.5, height*0.8, imgw, imgh);
    fill(255, 200);
    if (gp!=null) {
      fill(0, 0, 255);
      ellipse(gp.x, gp.y, 10, 10);
    }
    corners.display();
    if (width*0.5-imgw*0.5<mouseX&&mouseX<width*0.5+imgw*0.5&&height*0.8-imgh*0.5<mouseY&&mouseY<height*0.8+imgh*0.5) {
      fill(0, 0, 255);
      noFill();
      ellipse(mouseX, mouseY, 10, 10);
      color c=cam.get((int)map(mouseX, width*0.5-imgw*0.5, width*0.5+imgw*0.5, 0, cam.width), (int)map(mouseY, height*0.8-imgh*0.5, height*0.8+imgh*0.5, 0, cam.height));
      fill(c);//マウス位置のカメラ画像の色を取得して表示
      rectMode(CORNER);
      rect(0, height*0.6, width*0.1, height*0.1);
      fill(255);
      text(String.format("%3d,%3d,%3d", (int)red(c), (int)green(c), (int)blue(c)), 0, height*0.75);
    }
  }
  void mousePressed() {
    if (width*0.5-imgw*0.5<mouseX&&mouseX<width*0.5+imgw*0.5&&height*0.8-imgh*0.5<mouseY&&mouseY<height*0.8+imgh*0.5) {
      if (mousePressed) {
        if (mouseButton==CENTER) {//発生地点の設定
          particles.setGp(pc.adapt(map(mouseX, width*0.5-imgw*0.5, width*0.5+imgw*0.5, 0, cam.width), map(mouseY, height*0.8-imgh*0.5, height*0.8+imgh*0.5, 0, cam.height)));
          gp=new PVector(mouseX, mouseY);
        } else if (mouseButton==RIGHT) {//四隅のポイントの設定
          if (width*0.5-imgw*0.5<mouseX&&mouseX<width*0.5+imgw*0.5&&height*0.8-imgh*0.5<mouseY&&mouseY<height*0.8+imgh*0.5) {
            pc.addI_corner(map(mouseX, width*0.5-imgw*0.5, width*0.5+imgw*0.5, 0, cam.width), map(mouseY, height*0.8-imgh*0.5, height*0.8+imgh*0.5, 0, cam.height));
          }
        }
      }
    }
    if (mouseButton==LEFT)
      corners.pressed(mouseX, mouseY);
  }
  void mouseDragged() {
    corners.dragged(mouseX, mouseY);
  }
  void mouseReleased() {
    corners.released();
  }
  void update() {//loadなどの呼び出しの時に、スライダーなどにも数値を反映するための処理
    cp5.getController("brightness").setValue(shadow.getBr());
    cp5.getController("resolution").setValue(shadow.getResolution());
    cp5.getController("particle_size").setValue(particles.getDefsize());
    cp5.getController("particle_pop").setValue(particles.getPopstep());
    cp5.getController("gravity").setValue(gravity);
    PVector[] corner=pc.getI_corner();
    if (corner!=null) {
      int n=pc.inum;
      for (int i=0; i<n; i++) {
        corners.setCorner(i, new PVector(map(corner[i].x, 0, cam.width, width*0.5-imgw*0.5, width*0.5-imgw*0.5+imgw), map(corner[i].y, 0, cam.height, height*0.8-imgh*0.5, height*0.8-imgh*0.5+imgh)));
      }
    }
  }
}
class Controller2 extends PApplet {//フレームレートとコンソールを表示する別画面
  int w, h;
  PApplet parent;
  ControlP5 cp5;
  Textarea myTextarea;
  Println console;
  Chart myChart;
  PImage bg;
  Controller2(PApplet parent, int w, int h, String _name) {
    super();   
    this.parent = parent;
    this.w=w;
    this.h=h;
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }

  public void settings() {
    size(w, h);
  }

  public void setup() {
    cp5 = new ControlP5(this);
    cp5.enableShortcuts();
    myTextarea = cp5.addTextarea("txt")
      .setPosition(width*0.1, height*0.7)
      .setSize((int)(width*0.8), (int)(height*0.3))
      .setFont(createFont("", 14))
      .setLineHeight(14)
      .setColor(color(200))
      .setColorBackground(color(0, 100))
      .setColorForeground(color(255, 100));
    console = cp5.addConsole(myTextarea);

    cp5.addFrameRate()
      .setInterval(10)
      .setPosition(0, height - 10);

    myChart = cp5.addChart("fps")
      .setPosition(width*0.1, height*0.1)
      .setSize((int)(width*0.8), (int)(height*0.4))
      .setRange(0, 60)
      .setView(Chart.LINE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
      .setStrokeWeight(1.5)
      .setColorCaptionLabel(color(255));

    myChart.addDataSet("incoming");
    myChart.setData("incoming", new float[100]);
    PGraphics pg=createGraphics(width, height);
    pg.beginDraw();
    pg.background(0, 15, 30);
    pg.stroke(10, 115, 130);
    for (int i=0; i<width; i+=width/10) {
      pg.line(0, i, width, i);
      pg.line(i, 0, i, height);
    }
    pg.endDraw();
    bg=pg.copy();
  }
  void draw() {
    image(bg, 0, 0);
    text(parent.frameRate, 30, 30);
    if (parent.frameRate<20) {
      stroke(255, 0, 0);
      strokeWeight(10);
      rect(width*0.1, height*0.1, width*0.8, height*0.4);
    }
    if (frameCount%10==0)
      myChart.push("incoming", (parent.frameRate));
  }
}