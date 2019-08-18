//描画用の各種関数
public void printlnFPS() {
  String frame_rate = String.format(Locale.ENGLISH, "speed: %6.2f fps%n", frameRate);
  text(frame_rate, 10, 20);
}

public void printlnNumberOfBlobs(BlobDetector blob_detector) {
  fill(100, 200, 255);
  text("number of blobs: "+blob_detector.getBlobs().size(), 10, 40);
}

public void drawContour(ArrayList<Pixel> pixel_list, int stroke_color, int fill_color, boolean fill, float stroke_weight, PGraphics pg) {
  if (!fill)pg.noFill();
  else pg.fill(fill_color);
  pg.stroke(stroke_color);
  pg.strokeWeight(stroke_weight);
  pg.beginShape();
  for (int idx = 0; idx < pixel_list.size(); idx++) {
    PVector p = pt.adapt(pixel_list.get(idx).x_, pixel_list.get(idx).y_);
    pg.vertex(p.x, p.y);
  }
  pg.endShape();
}
public void drawMono(ArrayList<Pixel> pixel_list, PGraphics pg) {
  pg.fill(0);
  pg.beginShape();
  for (int idx = 0; idx < pixel_list.size(); idx++) {
    PVector p = pt.adapt(pixel_list.get(idx).x_, pixel_list.get(idx).y_);
    pg.vertex(p.x, p.y);
  }
  pg.endShape();
}
