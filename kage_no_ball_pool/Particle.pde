abstract class Solid {//オブジェクトを定義する抽象クラス
  Body body;
  PVector pos;
  float n;
  color c;
  Solid(float x, float y, float n) {
    makeBody(x, y, n);
    this.n=n;
    pos=new PVector();
    colorMode(HSB);
    c=color(random(0, 255), 160, 255);
    colorMode(RGB);
  }
  void killBody() {
    box2d.destroyBody(body);
  }
  abstract boolean done();
  abstract void display() ;
  void makeBody(float x, float y, float n) {
    BodyDef bd = new BodyDef();
    bd.position = box2d.coordPixelsToWorld(x, y);
    bd.type = BodyType.DYNAMIC;
    body = box2d.world.createBody(bd);
    FixtureDef fd = new FixtureDef();
    fd.shape=getShape(n);
    fd.density = 1;
    fd.friction = 0.01;
    fd.restitution = 0.3;
    body.createFixture(fd);
    body.setLinearVelocity(new Vec2(random(-20f, 20f), random(15f, 20f)));
    body.setAngularVelocity(random(-10, 10));
    body.setBullet(false);
  }

  PVector getPosition() {
    return box2d.coordWorldToPixelsPVector(body.getPosition());
  }
  void setPosition(PVector p) {
    body.setTransform(box2d.coordPixelsToWorld(p), body.getAngle());
  }
  void setVelocity(PVector p) {
    body.setLinearVelocity(box2d.vectorPixelsToWorld(p));
  }
  PVector getVelocity() {
    return box2d.vectorWorldToPixelsPVector(body.getLinearVelocity());
  }
  float getSize() {
    return n;
  }
  abstract Shape getShape(float n);
}
class Box extends Solid {
  Box(float x, float y, float d_) {
    super(x, y, d_*2);
  }
  boolean done() {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    if (pos.y > height+getSize()*1.14) {
      killBody();
      return true;
    }
    return false;
  }
  void display() {
    pos=getPosition();
    fill(c);
    stroke(0);
    strokeWeight(0);
    rectMode(CENTER);
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(-body.getAngle());
    rect(0, 0, getSize(), getSize());
    popMatrix();
  }

  Shape getShape(float d) {
    PolygonShape sd = new PolygonShape();
    float box2dW = box2d.scalarPixelsToWorld(d/2);
    float box2dH = box2d.scalarPixelsToWorld(d/2);
    sd.setAsBox(box2dW, box2dH);
    return sd;
  }
}
class Particle extends Solid {
  Particle(float x, float y, float r_) {
    super(x, y, r_);
  }
  boolean done() {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    if (pos.y > height+getSize()) {
      killBody();
      return true;
    }
    return false;
  }
  void display() {
    pos=getPosition();
    fill(c);
    stroke(0);
    strokeWeight(0);
    ellipse(pos.x, pos.y, getSize()*2, getSize()*2);
  }
  Shape getShape(float r) {
    CircleShape cs = new CircleShape();
    cs.m_radius = box2d.scalarPixelsToWorld(r);
    return cs;
  }
}

class Solids {
  private List<Solid> particles;
  private int defsize=10;
  private int popstep=3;
  private PVector gp;
  private PVector gp2;
  Solids() {
    particles=new ArrayList<Solid>();
    gp=new PVector(width/2, 10);
    gp2=gp.copy().add(100,0);
  }
  void display(PImage img) {
    for (int i=0; i<particles.size(); i++) {
      Solid p=particles.get(i);
      PVector pos=p.getPosition();
      int x=0, y=0, d=0;
      while (pos.x+x<width&&pos.x+x>0&&pos.y+y<height&&pos.y+y>0) {//影の部分に入っていたら一番近い白い部分に跳ぶ 判定は影を黒で塗った2極画像で行う
        if (img.get((int)pos.x+x, (int)pos.y+y)==color(255)) {
          pos.add(x, y);
          if (x!=0||y!=0) {
            p.setVelocity(PVector.add(p.getVelocity(), (new PVector(x, y))));//一応飛んだ方向に速度を与えてるつもり
          }
          break;
        }
        switch(d) {
        case 0:
          x++;
          if (y<x)d++;
          break;
        case 1:
          y--;
          if (x+y==0)d++;
          break;
        case 2:
          x--;
          if (x==y)d++;
          break;
        case 3:
          y++;
          if (x+y==0)d=0;
          break;
        }
      }
      p.setPosition(pos);
      if (p.done()) {//画面外に出たら削除
        particles.remove(i);
        i--;
        continue;
      }
      p.display();
    }
  }
  void add() {
    float x,y;
    if (random(0, 1)<0.5) {//50%の確率で丸と四角を生成する
      x=gp.x;
      y=gp.y;
      particles.add(new Particle(x, y, random(defsize*0.7, defsize*1.3)));
    } else {
      x=gp2.x;
      y=gp2.y;
      particles.add(new Box(x, y, random(defsize*0.7, defsize*1.3)));
    }
  }
  void clear() {
    while (particles.size()!=0) {
      particles.get(0).killBody();
      particles.remove(0);
    }
  }
  //ゲッターセッターたち
  int getPopstep() {
    return popstep;
  }
  void setPopstep(int popstep) {
    this.popstep=popstep;
  }
  int getDefsize() {
    return defsize;
  }
  PVector getGp() {
    return gp;
  }
  void setGp(PVector p) {
    gp=p.copy();
    gp2=gp.copy().add(700,0);
  }
  void setGp(float x, float y) {
    setGp2(new PVector(x, y));
  }
  
  PVector getGp2() {
    return gp2;
  }
  void setGp2(PVector p) {
    gp2=p.copy();
  }
  void setGp2(float x, float y) {
    setGp(new PVector(x, y));
  }
  void setDefsize(int defsize) {
    this.defsize=defsize;
  }
  //各種数値をsave, loadする関数
  void load(String filename) {
    XML root=loadXML(filename);
    XML gene=root.getChild("generate_point");
    XML defs=root.getChild("default_size");
    XML pop=root.getChild("pop_step");
    setGp(new PVector(gene.getFloat("x"), gene.getFloat("y")));
    setDefsize(defs.getInt("value"));
    setPopstep(pop.getInt("value"));
  }
  void load() {
    load("particles_data.xml");
    println("particles_data.xml "+"loaded!");
  }
  void save(String filename) {
    XML root=new XML("data");
    XML gene=new XML("generate_point");
    XML defs=new XML("default_size");
    XML pop=new XML("pop_step");
    gene.setFloat("x", gp.x);
    gene.setFloat("y", gp.y);
    defs.setInt("value", defsize);
    pop.setInt("value",popstep);
    root.addChild(gene);
    root.addChild(defs);
    root.addChild(pop);
    saveXML(root, filename);
  }
  void save() {
    save("particles_data.xml");
    println("particles_data.xml "+"saved!");
  }
}