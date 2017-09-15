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
Capture cam;
Box2DProcessing box2d;
Shadow shadow;
Solids particles;
ProjectorCorrection pc;
Controller ctrl;//別ウィンドウ1
Controller2 ctrl2;//別ウィンドウ2
float gravity=10;
boolean loadF, saveF, clearF;//save,load,clearの同期をとるためのフラグ
void settings() {//SecondAppletを使うので、sizeはsetupではなくこちらに記述
  fullScreen(2);
}
void setup() { 
  //cam=new Capture(this, 640, 480, "USB_Camera");
  cam=new Capture(this, 640, 480, 30);
  cam.start();
  mono=createGraphics(width, height);
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.setGravity(0, -gravity);
  shadow=new Shadow(this, cam);
  particles=new Solids();
  pc=new ProjectorCorrection();
  pc.setO_corner(0, 0, width, 0, width, height, 0, height);
  ctrl=new Controller(this, 500, 500, "Controller1");
  ctrl2=new Controller2(this, 500, 500, "Controller2");
  loadF=true;//最初に1度ロードする
  frameRate(50);
}
void draw() {
  box2d.step();
  if (newFrame) {//新しいフレームがあったら実行
    newFrame=false;
    if (pc.hasData()) {
      shadow.update();
    }
  }

  if (!pc.hasData()) {
    image(cam, 100, 100, cam.width, cam.height);
    noFill();
    stroke(255);
    strokeWeight(10);
    rect(0, 0, width, height);
  } else {
    background(255);
    shadow.display(mono);
    if (frameCount%particles.popstep==0) {
      particles.add();
    }
  }
  particles.display(mono);
  
  if (loadF) {
    pc.load();
    pc.setO_corner(0, 0, width, 0, width, height, 0, height);
    shadow.load();
    particles.load();
    load();
    delay(300);
    ctrl.update();
    loadF=false;
  }
  if (saveF) {
    pc.save();
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
    pc.clearI_corner();
    break;
  }
  if (key==CODED) {
    switch(keyCode) {
    case LEFT:
      pc.expand();
      break;
    case RIGHT:
      pc.contract();
      break;
    }
  }
}
void mousePressed() {
  if (mouseButton==RIGHT) {
    pc.addI_corner(mouseX, mouseY);
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