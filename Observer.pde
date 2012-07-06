class Observer
{
  Camera camera;
  Scene scene;
  InteractiveAvatarFrame avatar;
  int mode,targetIdx1, targetIdx2;
  float t0;
  boolean targetTransitioning;
  Trajectory boidAzimuth, boidDistance, boidInclination;

  Observer(PApplet applet)
  {    
    // set up scene
    scene = new Scene(applet);
    scene.registerCameraProfile( new CameraProfile(scene, "THIRD_PERSON", CameraProfile.Mode.THIRD_PERSON ) );
    scene.setAxisIsDrawn(false);
    scene.setGridIsDrawn(false);
    scene.setBoundingBox(new PVector(0, 0, 0), new PVector(boxWidth, boxHeight, boxDepth));
    scene.showAll();
    scene.startAnimation();

    // create camera
    camera = new Camera(scene);
    scene.setCamera(camera);
    mode = 1;

    // create tracking avatar
    avatar = new InteractiveAvatarFrame(scene);
    avatar.setTrackingDistance(300);
    avatar.setAzimuth(PI/12);
    avatar.setInclination(avatar.inclination() - PI/16);
    avatar.setPosition(boxWidth/2, boxHeight/2, 500);
    avatar.setFlySpeed(0.1);
    scene.setInteractiveFrame(avatar);    
    
    // initialize trajectories
    boidAzimuth = new Trajectory(0); 
    boidDistance = new Trajectory(3000);
    boidInclination = new Trajectory(0);
  }
  
  void update()
  {        
    // update target's position
    if (targetTransitioning) {
      PVector position = tweenFollow(targetIdx1, targetIdx2, t0);
      avatar.setPosition(position.x, position.y, position.z);
      t0 += 0.005;
      if (t0 >= 1.0) {
        this.targetIdx1 = targetIdx2;    
        t0 = 1.0;
        targetTransitioning = false;
      }      
    } else {
      if (mode==1) { 
        Boid b = (Boid) flock.get(targetIdx1);
        avatar.setPosition(boidCentroid.x, boidCentroid.y, boidCentroid.z);
      } else if (mode==2) {
        Boid b = (Boid) flock.get(targetIdx1);
        avatar.setPosition(b.pos.x, b.pos.y, b.pos.z);
      }
    }
    // update azimuth, inclination, and distance
    avatar.setAzimuth(boidAzimuth.next());
    avatar.setInclination(boidInclination.next());
    avatar.setTrackingDistance(boidDistance.next());        
  }
    
  void setFollowingBoid() {
    mode = 2;
    targetIdx2 = (int) random(flock.size());
    targetTransitioning = true;
    t0 = 0.0;
  }

  void setFollowingCentroid() {
    mode = 1;
    targetIdx2 = 0;
    targetTransitioning = true;
    t0 = 0.0;
  }

  void zoomInToCentroid() {
    boidDistance.set(avatar.trackingDistance(), 1100, 540);
  }
  
  void arcAroundCentroid1() {
    boidAzimuth.set(avatar.azimuth(), avatar.azimuth() + 3*HALF_PI, avatar.azimuth() + PI/4, 700);
    boidInclination.set(avatar.inclination(), avatar.inclination() + PI/3, avatar.inclination() + PI/6, 700);
    boidDistance.set(avatar.trackingDistance(), 500, 1100, 700);
  }
    
  void arcAroundCentroid2() {
    boidAzimuth.set(avatar.azimuth(), avatar.azimuth() - 5*PI/4, avatar.azimuth() - HALF_PI, 850);
    boidInclination.set(avatar.inclination(), avatar.inclination() + PI/4, avatar.inclination() + PI/8, 800);
    boidDistance.set(avatar.trackingDistance(), 1600, 500, 900);
  }

  void arcAroundBoid1() {
    boidAzimuth.set(avatar.azimuth(), avatar.azimuth() + 3*HALF_PI, avatar.azimuth() + PI/3, 750);
    boidInclination.set(avatar.inclination(), avatar.inclination() + PI/5, avatar.inclination() + PI/8, 650);
    boidDistance.set(avatar.trackingDistance(), 300, 75, 900);
  }

  void arcAroundBoid2() {
    boidAzimuth.set(avatar.azimuth(), avatar.azimuth() - HALF_PI, avatar.azimuth() - PI/4, 300);
    boidInclination.set(avatar.inclination(), avatar.inclination() - PI/3, avatar.inclination() - PI/4, 250);
    boidDistance.set(avatar.trackingDistance(), 1000, 550, 500);
  }
  
  void zoomOutFromBoid() {
    boidAzimuth.set(avatar.azimuth(), avatar.azimuth() + PI/4, 500);
    boidDistance.set(avatar.trackingDistance(), 1400, 600);
  }
  
  void zoomOutFromCentroid() {
    boidAzimuth.set(avatar.azimuth(), avatar.azimuth() - HALF_PI, 900);
    boidDistance.set(avatar.trackingDistance(), 4000, 900);
  }

  PVector tweenFollow(int idxfollow1, int idxfollow2, float t)
  {
    float t2 = 0.5 * (1 + cos(PI*t));
    PVector tween1 = new PVector(0, 0, 0);
    if (idxfollow1==0)
      tween1 = boidCentroid;
    else {
      Boid b = (Boid) flock.get(idxfollow1);
      tween1 = new PVector(b.pos.x, b.pos.y, b.pos.z);
    }
    PVector tween2 = new PVector(0, 0, 0);
    if (idxfollow2==0)
      tween2 = boidCentroid;
    else {
      Boid b = (Boid) flock.get(idxfollow2);
      tween2 = new PVector(b.pos.x, b.pos.y, b.pos.z);
    }
    return new PVector(lerp(tween2.x, tween1.x, t2), lerp(tween2.y, tween1.y, t2), lerp(tween2.z, tween1.z, t2));
  }

  private class Trajectory 
  {
    float value;
    float minValue, maxValue, midValue;
    int numFrames, n;
    boolean hasMidValue, active;
    
    Trajectory(float value) {
      this.value = value;
      numFrames = 0;
    }
    
    void set(float minValue, float maxValue, int numFrames) 
    {
      this.minValue = minValue;
      this.maxValue = maxValue;
      this.numFrames = numFrames;
      n = 0;
      hasMidValue = false;
      value = minValue;
    } 
    
    void set(float minValue, float midValue, float maxValue, int numFrames) 
    {
      this.minValue = minValue;
      this.midValue = midValue;
      this.maxValue = maxValue;
      this.numFrames = numFrames;
      n = 0;
      hasMidValue = true;
      value = minValue;
    } 
    
    float next() 
    {
      if (n < numFrames) { 
        float t0 = (float) n / (numFrames-1);
        if (!hasMidValue) {      
          float t = 0.5 * (1.0 - cos(PI * t0));
          value = lerp(minValue, maxValue, t);
        } else {
          float t = 0.5 * (1.0 - cos(TWO_PI * t0));
          if (t0 < 0.5) {
            value = lerp(minValue, midValue, t);        
          } else {
            value = lerp(maxValue, midValue, t);
          }
        }    
        n++;
      }
      return value;  
    } 
  }
}
