class Entity {

  PVector origin = new PVector(0, 0, 0);
  PVector loc = new PVector(random(-10, 10), random(-10, 10), random(-10, 10));
  PVector vec = new PVector(0, 0, 0);
  PVector vec2 = new PVector();
  PVector rollVec = new PVector();

  float xoff = random(100);
  float yoff = random(100);
  float zoff = random(100);
  float sX, sY;
  float sX_Label, sY_Label;
  float burstIn;

  float orbLine;
  float orbPoint;
  float orbLineAlpha;
  float starAlpha;

  Entity (float _orbLine, float _orbLineAlpha, float _orbPoint) {
    orbLine = _orbLine;
    orbLineAlpha = _orbLineAlpha;
    orbPoint = _orbPoint;
  }

  void display(float orbLine, float orbLineAlpha, float orbPoint) {

    float xNoise = map(noise(xoff), 0, 1, 2, 8);
    vec = PVector.sub(loc, origin);
    vec.normalize();
    vec2 = vec.get();
    
    if (getMillis() < 6000) burstIn = 800; 
    if (burstIn > 100) burstIn-=xNoise;
    vec.mult(burstIn);
    rollVec = vec.get();
    vec2.mult(burstIn+spikeOut);
    strokeWeight(orbPoint);
    stroke(245, starAlpha);
    point(vec.x, vec.y, vec.z);

    sX = screenX(rollVec.x, rollVec.y, rollVec.z);
    sY = screenY(rollVec.x, rollVec.y, rollVec.z);
    sX_Label = screenX(vec2.x, vec2.y, vec2.z);
    sY_Label = screenY(vec2.x, vec2.y, vec2.z);

    for (int i = 0; i < total; i += 2) 
    {
      float d = dist(entity[i].vec.x, entity[i].vec.y, entity[i].vec.z, vec.x, vec.y, vec.z);

      if (d < 20 && getMillis() > 7500) 
      {
        strokeWeight(orbLine);
        stroke(230, orbLineAlpha);
        line(entity[i].vec.x, entity[i].vec.y, entity[i].vec.z, vec.x, vec.y, vec.z);
      }
    }
    xoff+=.0003;
    if (getMillis() >8000) {
      starAlpha+=.5;
    }
  }
}

