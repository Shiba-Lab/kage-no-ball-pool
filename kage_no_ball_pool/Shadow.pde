class Shadow {
  private BlobDetector bd;
  private List<Body> bodies;
  private int resolution=3;
  private boolean modeView;
  private int br=80;
  Shadow(PApplet parent, Capture cam) {
    bd=new BlobDetector(cam.width, cam.height);
    bd.setResolution(resolution);
    bd.computeContours(true);
    bd.computeBlobPixels(false);
    bd.setMinMaxPixels(10*10, cam.width*cam.height);
    bd.setBLOBable(new BLOBable_SHADOW(parent, cam, this));
    //bd.setBLOBable(new BLOBable_SHADOW(parent, new PImage(width,height), this));
    bd.setDetectingArea(new BoundingBox(0, 0, cam.width, cam.height));
    bodies=new ArrayList<Body>();
    modeView=true;
  }
  //輪郭などの更新
  void update() {
    killBody();
    bd.update();
    ArrayList<Blob> blob_list = bd.getBlobs();
    //for (int blob_idx = 0; blob_idx < blob_list.size(); blob_idx++ ) {
    //  Blob blob = blob_list.get(blob_idx);
    //  ArrayList<Contour> contour_list = blob.getContours();
    //  for (int contour_idx = 0; contour_idx < contour_list.size(); contour_idx++ ) {
    //    Contour contour = contour_list.get(contour_idx);
    //    if ( contour_idx == 0) {
    //      addBody(contour.getPixels());
    //    }
    //  }
    //}
  }
  //輪郭などの表示
  void display(PGraphics pg, PGraphics mono) {
    mono.beginDraw();
    mono.background(255);
    ArrayList<Blob> blob_list = bd.getBlobs();
    for (int blob_idx = 0; blob_idx < blob_list.size(); blob_idx++ ) {
      Blob blob = blob_list.get(blob_idx);
      ArrayList<Contour> contour_list = blob.getContours();
      for (int contour_idx = 0; contour_idx < contour_list.size(); contour_idx++ ) {
        Contour contour = contour_list.get(contour_idx);
        if ( contour_idx == 0) {
          pg.fill(0, 200, 200);
          if (modeView) {
            drawContour(contour.getPixels(), color(255, 0, 0), color(255, 0, 255, 100), true, 1, pg);//表示用画像の生成
          }
          drawMono(contour.getPixels(), mono);//particleの判定用の2極画像を生成
        }
      }
    }
    mono.endDraw();
  }

  void addBody(List<Pixel> points) {
    ChainShape chain = new ChainShape();
    //approximate(points,10);
    Vec2[] vertices = new Vec2[points.size()];
    for (int i = 0; i < vertices.length; i++) {
      PVector p=pt.adapt(points.get(i).x_, points.get(i).y_);
      Vec2 edge = box2d.coordPixelsToWorld(p.x, p.y);
      vertices[i] = edge;
    }
    chain.createChain(vertices, vertices.length);
    BodyDef bd = new BodyDef();
    bd.position.set(0.0f, 0.0f);
    Body body = box2d.createBody(bd);
    body.createFixture(chain, 1);
    bodies.add(body);
  }
  void killBody() {
    for (Body body : bodies) {
      box2d.destroyBody(body);
    }
    bodies.clear();
  }

  void setResolution(int resolution) {
    this.resolution=resolution;
    bd.setResolution(resolution);
  }
  int getResolution() {
    return resolution;
  }
  void setBr(int br) {
    this.br=br;
  }
  int getBr() {
    return br;
  }
  void setView(boolean b) {
    modeView=b;
  }
  void load(String filename) {
    XML root=loadXML(filename);
    XML reso=root.getChild("resolution");
    XML brig=root.getChild("brightness");
    resolution=reso.getInt("value");
    br=brig.getInt("value");
  }
  void load() {
    load("shadow_data.xml");
    println("shadow_data.xml "+"loaded!");
    bd.setResolution(resolution);
  }

  void save(String filename) {
    XML root=new XML("data");
    XML reso=new XML("resolution");
    XML brig=new XML("brightness");
    reso.setInt("value", resolution);
    brig.setInt("value", br);
    root.addChild(reso);
    root.addChild(brig);
    saveXML(root, filename);
  }
  void save() {
    save("shadow_data.xml");
    println("shadow_data.xml "+"saved!");
  }
}
