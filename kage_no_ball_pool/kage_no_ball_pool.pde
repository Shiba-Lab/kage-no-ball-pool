import java.util.Locale;
import java.util.List;
import processing.video.*;
import diewald_CV_kit.blobdetection.*;
import diewald_CV_kit.libraryinfo.*;
import diewald_CV_kit.utility.*;
import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;

boolean newFrame=false;
PGraphics mono;//particleの判定用の白黒画像
PGraphics pg;
PImage camImg;
Capture cam;
Box2DProcessing box2d;
Shadow shadow;
Solids particles;
PerspectiveTransformer pt;
Controller ctrl;//別ウィンドウ1
Controller2 ctrl2;//別ウィンドウ2
float gravity=10;
boolean loadF, saveF, clearF;//save,load,clearの同期をとるためのフラグ
int process_width = 1280;
int process_height = 720;
float controller_size = 1;
void settings() {//SecondAppletを使うので、sizeはsetupではなくこちらに記述
  fullScreen(P3D, 2);
}
void setup() { 
  //cam=new Capture(this, 640, 480, "USB_Camera");
  cam=new Capture(this, 640, 480, 30);
  cam.start();
  pg=createGraphics(process_width, process_height, P3D);
  mono=createGraphics(process_width, process_height);
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.setGravity(0, -gravity);
  shadow=new Shadow(this, cam);
  particles=new Solids();
  pt=new PerspectiveTransformer();
  pt.setO_corner(0, 0, pg.width, 0, pg.width, pg.height, 0, pg.height);
  ctrl=new Controller(this, int(500 * controller_size), int(500 * controller_size), "Controller1");
  ctrl2=new Controller2(this, int(500 * controller_size), int(500 * controller_size), "Controller2");
  loadF=true;//最初に1度ロードする
  frameRate(50);
}
void draw() {
  box2d.step();
  pg.beginDraw();
  pg.background(255);
  if (newFrame) {//新しいフレームがあったら実行
    camImg=cam.copy();
    if(camImg==null)return;
    newFrame=false;
    if (pt.hasData()) {
      shadow.update();
    }
  }

  if (!pt.hasData()) {
    image(cam, 100, 100, cam.width, cam.height);
    noFill();
    stroke(255);
    strokeWeight(10);
    rect(0, 0, width, height);
  } else {
    background(255);
    shadow.display(pg, mono);
    if (frameCount%particles.popstep==0) {
      particles.add();
    }
  }
  particles.display(pg, mono);

  pg.endDraw();
  image(pg, 0, 0,width,height);
  if (loadF) {
    pt.load();
    pt.setO_corner(0, 0, pg.width, 0, pg.width, pg.height, 0, pg.height);
    shadow.load();
    particles.load();
    load();
    delay(300);
    ctrl.update();
    loadF=false;
  }
  if (saveF) {
    pt.save();
    shadow.save();
    particles.save();
    save();
    saveF=false;
  }
  if (clearF) {
    particles.clear();
    clearF=false;
  }
}

void captureEvent(Capture cam) {
  cam.read();
  newFrame = true;
}
void keyPressed() {
  switch(key) {
  case ' ':
    pt.clearI_corner();
    break;
  }
  if (key==CODED) {
    switch(keyCode) {
    case LEFT:
      pt.expand();
      break;
    case RIGHT:
      pt.contract();
      break;
    }
  }
}
void mousePressed() {
  if (mouseButton==RIGHT) {
    pt.addI_corner(mouseX, mouseY);
  }
}
void saveData() {
  saveF=true;
}
void loadData() {
  loadF=true;
}
void clearP() {
  clearF=true;
}


void load(String filename) {
  XML root=loadXML(filename);
  XML setting=root.getChild("setting");
  gravity=setting.getFloat("gravity");
}
void load() {
  load("setting.xml");
  println("ssetting.xml "+"loaded!");
}
void save(String filename) {
  XML root=new XML("data");
  XML setting=new XML("setting");
  setting.setFloat("gravity", gravity);
  root.addChild(setting);
  saveXML(root, filename);
}
void save() {
  save("setting.xml");
  println("setting.xml "+"saved!");
}
