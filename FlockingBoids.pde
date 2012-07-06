// Flocking boids -- Gene Kogan, March 2012
//
// A simulation of flocking based on Craig Reynolds' Boids program.  Press
// spacebar twice to toggle between first person and third person mode
// (following a single boid). In first person mode (the default), you can
// fly the camera around the scene by click dragging the mouse, and zoom
// using two-finger scroll. While in third person, pressing different number
// keys will trigger presets which move the camera around the scene in various ways.
//
// If it's running slowly, try reduing the boid count (variable numBoids).
//
// DEPENDENCIES
// To run this code, you must have GLGraphics, Toxiclibs, and Proscene libraries installed:
// GLGraphics : http://glgraphics.sourceforge.net/
// Toxiclibs : http://toxiclibs.org/
// Proscene : http://code.google.com/p/proscene/
//

import processing.opengl.*;
import codeanticode.glgraphics.*;
import remixlab.proscene.*;
import javax.media.opengl.*;
import toxi.geom.*;

// initial parameters
int boxWidth = 2400;
int boxHeight = 2400;
int boxDepth = 2400;
int numBoids = 2000;          // <-- boid count
boolean avoidWalls = true;

GLGraphics renderer;
Observer observer;
ArrayList flock;
BoidModel boidModel;
Vec3D[] bverts;
GLModel model;
Zone zones;
float[] verts, rateWing, rateTail;
PVector boidCentroid;

void setup() 
{
  size(screenWidth, screenHeight, GLConstants.GLGRAPHICS);
 
  // create boids
  flock = new ArrayList();
  for (int i = 0; i < numBoids; i++)
    flock.add(new Boid(new PVector(random(0.33*boxWidth, 0.66*boxWidth), 
                                    random(0.33*boxHeight, 0.66*boxHeight), 
                                    random(0.33*boxDepth, 0.66*boxDepth))));

  // set up zones
  zones = new Zone(boxWidth,boxHeight,boxDepth,100);

  // boid 3d model
  boidModel = new BoidModel();
  verts = new float[ flock.size() * boidModel.indexTri.length * 12 ];  

  // set up GLModel for boids  
  model = new GLModel(this, 66*flock.size(), TRIANGLES, GLModel.DYNAMIC);
  initializeColors();
  
  // rate of wing flapping and tail flapping
  rateWing = new float[flock.size()];
  rateTail = new float[flock.size()];
  for (int j=0; j<flock.size(); j++) {
    rateWing[j] = random(0.1, 0.25);
    rateTail[j] = random(0.2);
  }
  
  // set view and render
  observer = new Observer(this);    
  renderer = (GLGraphics) g;  
}

void draw() 
{
  computeBoids();
  updateGLModel();
  observer.update();  

  // render model  
  renderer.beginGL();
  renderer.background(255);
  renderer.model(model);
  renderer.endGL();   
}

void computeBoids()
{
  // determine zones that all the individual boids belong to (for efficiency)
  zones.update();
  
  // compare boids to other boids in neighboring zones, and calculate centroid
  boidCentroid = new PVector(0,0,0);
  for (int i=0; i < zones.nx; i++) {      
    for (int j=0; j < zones.ny; j++) {
      for (int k=0; k < zones.nz; k++) {
        ArrayList<Boid> neighbors = zones.getNeighbors(i,j,k);
        for (Boid b : zones.get(i,j,k)) {
          boidCentroid.add(b.pos.x, b.pos.y, b.pos.z);
          b.run(neighbors);
        }
      }
    }
  }
  boidCentroid.mult(1.0 / numBoids);
}

void updateGLModel()
{
  int[][] idx = boidModel.getTriangleIndexes();        // merge index tri and bverts
  for (int j = 0; j < flock.size(); j++) 
  { 
    // get each boid, and rotate it in direction of its velocity
    Boid b = (Boid) flock.get(j);    
    float angz = atan(b.vel.y / b.vel.x);
    float angx = atan(b.vel.y / b.vel.z);
    float angy = atan(-b.vel.z / b.vel.x);
      if (b.vel.x <0) angy+=PI;
    
    // flap wings and tails
    boidModel.flapWings(rateWing[j] * frameCount);
    boidModel.flapTail(rateTail[j] * frameCount);
    
    // update GLModel's vertices
    bverts = boidModel.getVertices(b.pos, angx, angy, angz);
    for (int i = 0; i < idx.length; i++)
    {
      verts[ 264*j + 12*i      ] = bverts[idx[i][0]].x;
      verts[ 264*j + 12*i +  1 ] = bverts[idx[i][0]].y;
      verts[ 264*j + 12*i +  2 ] = bverts[idx[i][0]].z;
      verts[ 264*j + 12*i +  3 ] = 1.0;      
      verts[ 264*j + 12*i +  4 ] = bverts[idx[i][1]].x;
      verts[ 264*j + 12*i +  5 ] = bverts[idx[i][1]].y;
      verts[ 264*j + 12*i +  6 ] = bverts[idx[i][1]].z;
      verts[ 264*j + 12*i +  7 ] = 1.0;
      verts[ 264*j + 12*i +  8 ] = bverts[idx[i][2]].x;
      verts[ 264*j + 12*i +  9 ] = bverts[idx[i][2]].y;
      verts[ 264*j + 12*i + 10 ] = bverts[idx[i][2]].z;
      verts[ 264*j + 12*i + 11 ] = 1.0;      
    }  
  }
  model.updateVertices(verts);
}

void initializeColors() {
  model.initColors();
  model.beginUpdateColors();
  for (int i=0; i<flock.size(); i++) {
    float r = random(140, 235);
    float g = random( 50, 140);
    float b = random( 50, 140);
    for (int j = 0; j < 66; j++) {
      model.updateColor(66*i + j, r + random(-30, 30), g + random(-30, 30), b + random(-30, 30));
    }
  }
  model.endUpdateColors();  
}

void keyPressed() 
{
  switch (key) {
    case '1':    observer.zoomInToCentroid();     break;
    case '2':    observer.arcAroundCentroid1();   break;
    case '3':    observer.setFollowingBoid();     break;
    case '4':    observer.arcAroundBoid1();       break;
    case '5':    observer.setFollowingBoid();     break;
    case '6':    observer.zoomOutFromBoid();      break;
    case '7':    observer.arcAroundBoid2();       break;
    case '8':    observer.setFollowingCentroid(); break;
    case '9':    observer.arcAroundCentroid2();   break;  
    case '0':    observer.zoomOutFromCentroid();  break;      
    case 'x':
      observer.scene.setAnimationPeriod(observer.scene.animationPeriod()-2, false);
      observer.scene.setFrameRate(60);
      break;
    case 'y':
      observer.scene.setAnimationPeriod(observer.scene.animationPeriod()+2, false);
      observer.scene.setFrameRate(60);
      break;

  }    
}
