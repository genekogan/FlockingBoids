// class for optimizing boids computation
// complete space is divided into nx x ny x nz cubes of length of boids radius
// every frame, boids are assigned to the cube they are located in, and instead of 
// comparing all boids to each other (O(n^2)), boids in each cube are compared 
// only to boids in neighbors (and own cube)

class Zone
{  
  ArrayList[][][] zones;
  ArrayList[][][] neighbors;
  int nx, ny, nz, sizex, sizey, sizez, rad;
  
  Zone(int sizex, int sizey, int sizez, int rad)
  {
    this.sizex = sizex;
    this.sizey = sizey;
    this.sizez = sizez;
    this.rad = rad;
    
    // number of zones
    nx = floor(sizex / rad);
    ny = floor(sizey / rad);
    nz = floor(sizez / rad);
    
    // zone array and neighbors
    zones = new ArrayList[nx][ny][nz];
    neighbors = new ArrayList[nx][ny][nz];

    // initialize    
    for (int x=0; x<nx; x++) {
      for (int y=0; y<ny; y++) {
        for (int z=0; z<nz; z++) {
          zones[x][y][z] = new ArrayList<Boid>();
        }
      }
    }
    
    for (int x=0; x<nx; x++) {
      for (int y=0; y<ny; y++) {
        for (int z=0; z<nz; z++) {
          neighbors[x][y][z] = new ArrayList<ArrayList>();
        }
      }
    }
  }
    
  ArrayList<Boid> get(int i, int j, int k) {
    return zones[i][j][k];
  }
  
  ArrayList<Boid> getNeighbors(int i, int j, int k) {
    return neighbors[i][j][k];
  }

  void update() 
  {
    // clear all zones first
    for (int x=0; x<nx; x++) {
      for (int y=0; y<ny; y++) {
        for (int z=0; z<nz; z++) {
          zones[x][y][z].clear();
          neighbors[x][y][z].clear();
        }
      }
    }    
    // assign each boid to correct zone
    for (int i=0; i<flock.size(); i++) {
      assign((Boid) flock.get(i));
    }
  }

  void assign(Boid boid) 
  {
    // determine which zone the boid belongs to
    int ix = (int) (boid.pos.x / rad);
    int iy = (int) (boid.pos.y / rad);
    int iz = (int) (boid.pos.z / rad);
    zones[ix][iy][iz].add(boid);    
    
    // add boid to all neighboring cells
    for (int i=max(0,ix-1); i<min(nx,ix+1); i++) {
      for (int j=max(0,iy-1); j<min(ny,iy+1); j++) {
        for (int k=max(0,iz-1); k<min(nz,iz+1); k++) {
          neighbors[i][j][k].add(boid);
        }
      }
    }    
  }  
}
