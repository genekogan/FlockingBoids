class BoidModel 
{  
  Vec3D xaxis = new Vec3D(1,0,0);
  Vec3D yaxis = new Vec3D(0,1,0);
  Vec3D zaxis = new Vec3D(0,0,1);

  Vec3D[] vertices = new Vec3D[17];
  int[][] indexTri = new int[22][3];
  Vec3D[] transposedVertices = new Vec3D[vertices.length];
  int tail, nose, span, head, wing, flapWing, flapTail;
  
  BoidModel(int tail, int nose, int span, int head, int wing, int flapWing, int flapTail) 
  {   
    this.tail = tail;
    this.nose = nose;
    this.span = span;
    this.head = head;
    this.wing = wing;
    this.flapWing = flapWing;
    this.flapTail = flapTail;
    
    // create vertices
    vertices[ 0] = new Vec3D(     -tail,         0, -1.5*span );      // tail left
    vertices[ 1] = new Vec3D(     -tail,         0,  1.5*span );      // tail right
    vertices[ 2] = new Vec3D( -0.7*tail,         0, -0.6*span );      // waist left
    vertices[ 3] = new Vec3D( -0.7*tail,         0,  0.6*span );      // waist right
    vertices[ 4] = new Vec3D( -0.5*tail,  0.5*head,         0 );      // waist top
    vertices[ 5] = new Vec3D( -0.5*tail, -0.5*head,         0 );      // waist bottom
    vertices[ 6] = new Vec3D(         0,         0,     -span );      // left ear
    vertices[ 7] = new Vec3D(         0,         0,      span );      // right ear
    vertices[ 8] = new Vec3D(         0,      head,         0 );      // head
    vertices[ 9] = new Vec3D(         0,     -head,         0 );      // chin    
    vertices[10] = new Vec3D(      nose,         0,         0 );      // nose
    vertices[11] = new Vec3D( -0.1*tail,         0,         0 );      // wing base front
    vertices[12] = new Vec3D( -0.4*tail,         0,         0 );      // wing base back
    vertices[13] = new Vec3D( -0.7*tail,         0, -0.8*wing );      // wing tip back left
    vertices[14] = new Vec3D( -0.7*tail,         0,  0.8*wing );      // wing tip back right    
    vertices[15] = new Vec3D( -0.2*tail,         0,     -wing );      // wing tip front left
    vertices[16] = new Vec3D( -0.2*tail,         0,      wing );      // wing tip front right
    
    // indexes for GLmodel triangles
    indexTri = new int[][]{ 
        // tail
        new int[]{  4,  3,  1 },
        new int[]{  4,  1,  0 },
        new int[]{  4,  2,  0 },
        new int[]{  5,  3,  1 },
        new int[]{  5,  1,  0 },
        new int[]{  5,  2,  0 },

        // torso
        new int[]{  4,  3,  7 },
        new int[]{  4,  7,  8 },
        new int[]{  4,  2,  6 },
        new int[]{  4,  6,  8 },
        new int[]{  5,  3,  7 },
        new int[]{  5,  7,  9 },
        new int[]{  5,  2,  6 },
        new int[]{  5,  6,  9 },

        // head
        new int[]{  7,  8, 10 },
        new int[]{  6,  8, 10 },
        new int[]{  7,  9, 10 },
        new int[]{  6,  9, 10 },
      
        // wings
        new int[]{ 11, 12, 13 },
        new int[]{ 11, 13, 15 },
        new int[]{ 11, 12, 14 },
        new int[]{ 11, 14, 16 }
        };
  }

  BoidModel() {
    this(15, 6, 2, 2, 8, 7, 4);
  }
    
  void flapWings(float angle) {
    float y = flapWing * sin(angle);
    vertices[13] = new Vec3D( -0.7*tail,      y,  -0.8*wing);      // wing tip back left
    vertices[14] = new Vec3D( -0.7*tail,      y,   0.8*wing);      // wing tip back right    
    vertices[15] = new Vec3D( -0.2*tail,      y,      -wing);      // wing tip front left
    vertices[16] = new Vec3D( -0.2*tail,      y,       wing);      // wing tip front right
  }

  void flapTail(float angle) {
    float y = flapTail * cos(angle);
    vertices[ 0] = new Vec3D(     -tail,      y, -1.5*span );      // tail left
    vertices[ 1] = new Vec3D(     -tail,      y,  1.5*span );      // tail right
  }
  
  Vec3D[] getVertices(PVector center, float anglex, float angley, float anglez)
  {
    for (int i = 0; i < vertices.length; i++) 
    {
      transposedVertices[i] = vertices[i].getRotatedAroundAxis(xaxis, anglex);
      transposedVertices[i] = transposedVertices[i].getRotatedAroundAxis(yaxis, angley);
      transposedVertices[i] = transposedVertices[i].getRotatedAroundAxis(zaxis, anglez);
      transposedVertices[i].addSelf(new Vec3D(center.x, center.y, center.z));
    }
    return transposedVertices;
  }
  
  int[][] getTriangleIndexes() {
    return indexTri;
  } 
  
}
