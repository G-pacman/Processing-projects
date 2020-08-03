Camera camera;

int numH = 15;
int numL = 15;
float ks = 10;
float kd = 9;
int sphereRadius = 10;
float dt = 0.1;
boolean throwBall = false;
boolean fastball = false;


Vec3 pos[][] = new Vec3[numL][numH];
Vec3 vel[][] = new Vec3[numL][numH];
Vec3 vn[][] = new Vec3[numL][numH];

Vec3 boxpos = new Vec3(0,20,-50);
Vec3 boxvel = new Vec3(0, 0, 0);

Vec3 tballpos = new Vec3(0,0,50);
Vec3 tballvel = new Vec3(0,0,0);


void setup()
{
  size(1280, 720, P3D);
  camera = new Camera();
  
  for(int i=0; i<numL; i++) {
    for(int j=0; j<numH; j++) {
      pos[i][j]=new Vec3(i*3,-10,j*3-50);
      vel[i][j]=new Vec3(0,0,0);      
      vn[i][j]=new Vec3(0,0,0);
    }
  }
  
}

void update() {
  vn = vel;
  // length
  for(int i=0; i<numL-1; i++) {
    for(int j=0; j<numH; j++) {
      Vec3 e = pos[i+1][j].minus(pos[i][j]);
      float l = e.length();
      e.normalize();
      float v1=dot(e,vel[i][j]);
      float v2=dot(e,vel[i+1][j]);
      float force=-ks*(3-l)-kd*(v1-v2);
      if(force<140) {
      vn[i][j].add(e.times(force*dt));
      vn[i+1][j].subtract(e.times(force*dt));
      }
    }
  }  
  // height
  for(int i=0; i<numL; i++) {
    for(int j=0; j<numH-1; j++) {
      Vec3 e = pos[i][j+1].minus(pos[i][j]);
      float l = e.length();
      e.normalize();
      float v1=dot(e,vel[i][j]);
      float v2=dot(e,vel[i][j+1]);
      float force=-ks*(3-l)-kd*(v1-v2)+10;
      if(force<140) {
      vn[i][j].add(e.times(force*dt));
      vn[i][j+1].subtract(e.times(force*dt));
      }
    }
  }
  vel = vn;
  
  //"air resistance" f=-1/2*density*|v|^2c_d*a*n
  float airforce = 0;
  for(int i=0; i<numL-1; i++) {
    for(int j=0; j<numH-1; j++) {
      Vec3 ve = (vel[i][j].plus(vel[i+1][j]).plus(vel[i][j+1])).times(1/3);
      Vec3 nstar = cross(pos[i][j+1].minus(pos[i][j]), pos[i+1][j].minus(pos[i][j]));
      float van = ve.length()*(dot(ve,nstar))/(2*nstar.length());
      Vec3 vanvec = new Vec3(van,van,van);
      float v2an = dot(nstar, vanvec)*-1/2*0.00001;
      airforce = v2an/3;
      vel[i][j].x += airforce;   vel[i][j].y += airforce;   vel[i][j].z += airforce;
      vel[i][j+1].x += airforce; vel[i][j+1].y += airforce; vel[i][j+1].z += airforce;
      vel[i+1][j].x += airforce; vel[i+1][j].y += airforce; vel[i+1][j].z += airforce;
    }
  }
  
  //collision detection
  for(int i=0; i<numL; i++) {
    for(int j=0; j<numH; j++) {  
      float d= boxpos.distanceTo(pos[i][j]);
      if(d<sphereRadius+0.79) {
        Vec3 n = (boxpos.minus(pos[i][j])).times(-1);
        n.normalize();
        Vec3 bounce = n.times(dot(vel[i][j],n));
        vel[i][j].subtract(bounce.times(1.5));
        pos[i][j].add(n.times(0.8+sphereRadius-d));
      }
      
      d= tballpos.distanceTo(pos[i][j]);
      if(d<1+0.79) {
        Vec3 n = (tballpos.minus(pos[i][j])).times(-1);
        n.normalize();
        Vec3 bounce = n.times(dot(vel[i][j],n));
        vel[i][j].subtract(bounce.times(120));
        pos[i][j].add(n.times(0.8+1-d));
      }
    }
  }

  // setting final values
  for(int i=0; i<numL; i++) {
    for(int j=0; j<numH; j++) {
      vel[i][j].y += .2;
      vel[i][0].mul(0);
      pos[i][j].add(vel[i][j].times(dt));
    }
  }
}

void draw() {
  background(255);
  noLights();
  noStroke();

  camera.Update(1.0/frameRate);
  
  update();
  
  boxpos = boxpos.plus(boxvel.times(dt) ); //update box location
  fill( 0, 0, 255 );
  pushMatrix();
  translate(boxpos.x, boxpos.y, boxpos.z);
  sphere( sphereRadius );
  popMatrix();
  
  if(throwBall) throwBall();
  
  tballpos.add(tballvel);
  pushMatrix();
  translate(tballpos.x,tballpos.y,tballpos.z);
  sphere( 1 );
  popMatrix();
  
  for(int i=0; i<numL; i++) {
    for(int j=0; j<numH; j++) {
      fill( 0, 0, 255 );
      pushMatrix();
      beginShape();
      fill(j*10+50);
      if(j<numH-1 && i<numL-1 && pos[i][j].distanceTo(pos[i][j+1])<30 &&
         pos[i][j].distanceTo(pos[i+1][j+1])<30 && pos[i][j].distanceTo(pos[i+1][j])<30) {
        if(j<numH-1 && i<numL-1)vertex(pos[i][j].x,pos[i][j].y,pos[i][j].z);
        if(j<numH-1 && i<numL-1)vertex(pos[i][j+1].x,pos[i][j+1].y,pos[i][j+1].z);
        if(j<numH-1 && i<numL-1)vertex(pos[i+1][j+1].x,pos[i+1][j+1].y,pos[i+1][j+1].z);
        if(j<numH-1 && i<numL-1)vertex(pos[i+1][j].x,pos[i+1][j].y,pos[i+1][j].z);
      }
      endShape();
      //translate(pos[i][j].x,pos[i][j].y,pos[i][j].z);
      //sphere(0.5);
      popMatrix();
    }
  }
  
}

void throwBall() {
  tballpos = new Vec3(camera.position.x, camera.position.y+2, camera.position.z);
  tballvel.mul(0);
  tballvel.add(new Vec3(0, 0, -1));
  if(fastball) tballvel.add(new Vec3(0, 0, -2));
  throwBall = false;
  fastball = false;
}

void keyPressed() {
  camera.HandleKeyPressed();
  float boxSpeed = 5;
  if ( key == 'u' ) boxvel.y = boxSpeed;
  if ( key == 'j' ) boxvel.x = -boxSpeed;     
  if ( key == 'k' ) boxvel.z = boxSpeed;
  if ( key == 'i' ) boxvel.z = -boxSpeed;
  if ( key == 'o' ) boxvel.y = -boxSpeed;
  if ( key == 'l' ) boxvel.x = boxSpeed;
  if ( key == 'p' ) throwBall = true;
  if ( key == '[' ) {throwBall = true; fastball = true;}
}

void keyReleased() {
  camera.HandleKeyReleased();
  if ( key == 'u' ) boxvel.y = 0;
  if ( key == 'j' ) boxvel.x = 0;
  if ( key == 'i' ) boxvel.z = 0;
  if ( key == 'k' ) boxvel.z = 0;
  if ( key == 'o' ) boxvel.y = 0;
  if ( key == 'l' ) boxvel.x = 0;
}
