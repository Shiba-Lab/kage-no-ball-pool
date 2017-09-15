float getAngle(Pixel p1, Pixel p2, Pixel p3) {
  float angle=abs(PVector.sub(new PVector(p1.x_,p1.y_), new PVector(p2.x_,p2.y_)).heading()-PVector.sub(new PVector(p3.x_,p3.y_), new PVector(p2.x_,p2.y_)).heading());
  return (angle<PI)?angle:2*PI-angle;
}

void approximate(List<Pixel> points, int angle) {
  Pixel p1, p2, p3;
  for (int i=0; i<points.size(); i++) {
    p1=(i==0)?points.get(points.size()-1):points.get(i-1);
    p2=points.get(i);
    p3=(i==points.size()-1)?points.get(0):points.get(i+1);
    if (abs(degrees(getAngle(p1, p2, p3))-180)<angle) {
      points.remove(i);
      i--;
    }
  }
}