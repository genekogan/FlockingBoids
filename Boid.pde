// Boids calculation adapted from Proscene boids example, which itself is adapted
// from Craig Reynolds' boids program: http://www.red3d.com/cwr/boids/

class Boid 
{
  PVector pos, vel, acc, ali, coh, sep;
  float neighborhoodRadius;
  float maxSpeed = 4;
  float maxSteerForce = .1f;
  float sc = 3;
  float flap = 0;
  float t = 0;

  // constructors
  Boid(PVector inPos) 
  {
    pos = new PVector();
    pos.set(inPos);
    vel = new PVector(random(-1, 1), random(-1, 1), random(1, -1));
    acc = new PVector(0, 0, 0);
    neighborhoodRadius = 100;
  }
  
  void run(ArrayList bl)
  {
    t += .1;
    if (avoidWalls) {
      acc.add(PVector.mult(avoid(new PVector(pos.x, boxHeight, pos.z), true), 5));
      acc.add(PVector.mult(avoid(new PVector(pos.x, 0, pos.z), true), 5));
      acc.add(PVector.mult(avoid(new PVector(boxWidth, pos.y, pos.z),	true), 5));
      acc.add(PVector.mult(avoid(new PVector(0, pos.y, pos.z), true), 5));
      acc.add(PVector.mult(avoid(new PVector(pos.x, pos.y, 0), true), 5));
      acc.add(PVector.mult(avoid(new PVector(pos.x, pos.y, boxDepth), true), 5));
    }
    flockOptimized(bl);
    move();
    checkBounds();
  }

  void flock(ArrayList bl,int idx) 
  {
    ali = alignment(bl);
    coh = cohesion(bl);
    sep = seperation(bl);
    acc.add(PVector.mult(ali, 1));
    acc.add(PVector.mult(coh, 3));
    acc.add(PVector.mult(sep, 1));
  }
  
  void flockOptimized(ArrayList boids) 
  {
    PVector velSum = new PVector(0, 0, 0);
    PVector posSum = new PVector(0, 0, 0);
    PVector posSum2 = new PVector(0, 0, 0);
    PVector steer = new PVector(0, 0, 0);
    PVector repulse;

    int count = 0;
    for (int i = 0; i < boids.size(); i++) {
      Boid b = (Boid) boids.get(i);
      float d = PVector.dist(pos, b.pos);
      if (d > 0 && d <= neighborhoodRadius) {
        velSum.add(b.vel);
        posSum.add(b.pos);
        repulse = PVector.sub(pos, b.pos);
        repulse.normalize();
        repulse.div(d);
        posSum2.add(repulse);
        count++;
      }
    }
    if (count > 0) {
      velSum.div((float) count);
      velSum.limit(maxSteerForce);
      posSum.div((float) count);
    }
    ali = velSum;  
    steer = PVector.sub(posSum, pos);
    steer.limit(maxSteerForce);
    coh = steer;
    sep = posSum2;
    acc.add(PVector.mult(ali, 1));
    acc.add(PVector.mult(coh, 3));
    acc.add(PVector.mult(sep, 1));    
  }

  void move() {
    vel.add(acc); // add acceleration to velocity
    vel.limit(maxSpeed); // make sure the velocity vector magnitude does not exceed maxSpeed
    pos.add(vel); // add velocity to position
    acc.mult(0); // reset acceleration
  }

  void checkBounds() {
    if (pos.x > boxWidth) pos.x = 0;
    if (pos.x < 0) pos.x = boxWidth;
    if (pos.y > boxHeight) pos.y = 0;
    if (pos.y < 0) pos.y = boxHeight;
    if (pos.z > boxDepth) pos.z = 0;
    if (pos.z < 0) pos.z = boxDepth;
  }  

  // steering. If arrival==true, the boid slows to meet the target. Credit to Craig Reynolds
  PVector steer(PVector target, boolean arrival) {
    PVector steer = new PVector(); // creates vector for steering
    if (!arrival) {
      steer.set(PVector.sub(target, pos)); // steering vector points towards target (switch target and pos for avoiding)
      steer.limit(maxSteerForce); // limits the steering force to maxSteerForce
    } 
    else {
      PVector targetOffset = PVector.sub(target, pos);
      float distance = targetOffset.mag();
      float rampedSpeed = maxSpeed * (distance / 100);
      float clippedSpeed = min(rampedSpeed, maxSpeed);
      PVector desiredVelocity = PVector.mult(targetOffset, (clippedSpeed / distance));
      steer.set(PVector.sub(desiredVelocity, vel));
    }
    return steer;
  }

  // avoid. If weight == true avoidance vector is larger the closer the boid is to the target
  PVector avoid(PVector target, boolean weight) {
    PVector steer = new PVector(); // creates vector for steering
    steer.set(PVector.sub(pos, target)); // steering vector points away from
    // target
    if (weight)
      steer.mult(1 / sq(PVector.dist(pos, target)));
    // steer.limit(maxSteerForce); //limits the steering force to
    // maxSteerForce
    return steer;
  }

  PVector seperation(ArrayList boids) {
    PVector posSum = new PVector(0, 0, 0);
    PVector repulse;
    for (int i = 0; i < boids.size(); i++) {
      Boid b = (Boid) boids.get(i);
      float d = PVector.dist(pos, b.pos);
      if (d > 0 && d <= neighborhoodRadius) {
        repulse = PVector.sub(pos, b.pos);
        repulse.normalize();
        repulse.div(d);
        posSum.add(repulse);
      }
    }
    return posSum;
  }

  PVector alignment(ArrayList boids) {
    PVector velSum = new PVector(0, 0, 0);
    int count = 0;
    for (int i = 0; i < boids.size(); i++) {
      Boid b = (Boid) boids.get(i);
      float d = PVector.dist(pos, b.pos);
      if (d > 0 && d <= neighborhoodRadius) {
        velSum.add(b.vel);
        count++;
      }
    }
    if (count > 0) {
      velSum.div((float) count);
      velSum.limit(maxSteerForce);
    }
    return velSum;
  }

  PVector cohesion(ArrayList boids) {
    PVector posSum = new PVector(0, 0, 0);
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    for (int i = 0; i < boids.size(); i++) {
      Boid b = (Boid) boids.get(i);
      float d = dist(pos.x, pos.y, b.pos.x, b.pos.y);
      if (d > 0 && d <= neighborhoodRadius) {
        posSum.add(b.pos);
        count++;
      }
    }
    if (count > 0) {
      posSum.div((float) count);
    }
    steer = PVector.sub(posSum, pos);
    steer.limit(maxSteerForce);
    return steer;
  }
}
