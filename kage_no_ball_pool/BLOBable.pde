public final class BLOBable_SHADOW implements BLOBable {//blobの判定を行うためのクラス
  int width_, height_;
  private String name_; 
  private Shadow shadow;
  private PImage img;
  public BLOBable_SHADOW(PApplet papplet, PImage img, Shadow shadow) {
    this.shadow=shadow;
    this.img=img;
  }

  //@Override
  public final void init() {//初期化処理
    name_ = this.getClass().getSimpleName();
  }

  //@Override
  public final void updateOnFrame( int width, int height) {//毎フレーム処理
  }
  //@Override
  public final boolean isBLOBable(int pixel_index, int x_, int y_) {//各ドットがblobに属するかの判定
    PVector p=pc.adapt(x_, y_);
    if(!(p.x>0&&p.x<pg.width&&p.y>0&&p.y<pg.height))return false;//ドットの位置がスクリーン外部だった場合に外枠ができてしまうため判定から外す
    color c=img.get((int)x_, (int)y_);//色の取得
    if (red(c)<shadow.getBr()&&green(c)<shadow.getBr()&&blue(c)<shadow.getBr()) {//色がしきい値以下だった場合にblobに属するように判定
      return true;
    } else {
      return false;
    }
  }
}
