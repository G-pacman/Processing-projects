PShape tree1;
PShape tree2;
PShape lantern;
PImage lampimg;
PImage tree2img;
PImage tree1img;

static int numBoids = 50;

float radius = .2;
float dt = .1;


//Inital positions and velocities of masses
Vec3 pos[] = new Vec3[numBoids];
Vec3 col[] = new Vec3[numBoids];
Vec3 vel[] = new Vec3[numBoids];
Vec3 acc[] = new Vec3[numBoids];
Vec3 boxpos = new Vec3(10, 10, 10);
Vec3 boxvel = new Vec3(0, 0, 0);


Camera camera;


void setup() {
  size(800, 600, P3D);
  
  surface.setTitle("3D Boids by Greg");
  
  for( int i = 0; i < numBoids; i++) {
    pos[i] = new Vec3( random(20), random(20), random(20));
    vel[i] = new Vec3(-1+random(2),-1+random(2),-1+random(2));  //TODO: Better random angle
    vel[i].normalize();
    vel[i] = new Vec3( 0, 0, 0);
    //vel[i].mul(1);
    col[i] = new Vec3( 200 + random(55), 200 + random(55), 0 );
  }
  
  camera = new Camera();
  
  //image/model loading
  lampimg = loadImage("lamp.jpg");
  lantern = createShape(BOX, 2);
  lantern.setTexture(lampimg);
  tree1 = loadShape("PineTree_3.obj");
  tree1.scale(50);
  tree1img = loadImage("PineTree_3.mtl");
  tree1.setTexture(tree1img);
  tree2 = loadShape("PineTree_5.obj");
  tree2.scale(50);
  tree2img = loadImage("PineTree_5.mtl");
  tree2.setTexture(tree2img);
}

void draw() {
  //noStroke();
  background(10);
  noLights();
  
  camera.Update(1.0/frameRate);
  
  drawshapes();
  updateballs();
  
  println(frameRate);// prints fps
}

void updateballs() {

  for (int i = 0; i < numBoids; i++){
    
    Vec3 ruleone = ruleone(i);
    Vec3 ruletwo = ruletwo(i);
    Vec3 rulethree = rulethree(i);
    Vec3 tend = tend_to_box(i);
      
    //Update Position & Velocity
    //vel[i].normalize();
    vel[i] = vel[i].plus(ruleone);
    vel[i].normalize();
    vel[i] = vel[i].plus(ruletwo);
    vel[i].normalize();
    vel[i] = vel[i].plus(rulethree);
    vel[i].normalize();
    vel[i] = vel[i].plus(tend);
    vel[i].normalize();
    pos[i] = pos[i].plus(vel[i].times(dt) );
    
    if (vel[i].length() > 1){
      vel[i] = vel[i].normalized().times(1);
    }
    
    boxpos = boxpos.plus(boxvel.times(dt) );

    
    // boids that hit the edge of the box bounce of
    /*
    if (pos[i].x < 0.1 || pos[i].x > 19.9) vel[i].x *= -1.0;
    if (pos[i].y < 0.1 || pos[i].y > 19.9) vel[i].y *= -1.0;
    if (pos[i].z < 0.1 || pos[i].z > 19.9) vel[i].z *= -1.0;
    */
  }
  
}

Vec3 ruleone(int b) { // Boids try to fly towards the centre of mass of neighbouring boid
  Vec3 pc = new Vec3(0, 0, 0);
  for( int i = 0; i < numBoids; i++ ) {
    if( i != b ) pc.add(pos[i]);
  }
  pc.mul( 1/(numBoids-1) );
  
  return new Vec3( (pc.x - pos[b].x)/1000 , (pc.y - pos[b].y)/1000, (pc.z - pos[b].z)/1000);
}

Vec3 ruletwo( int b) { // Boids try to keep a small distance away from other objects (including other boids).
  float dis = 0.2;
  Vec3 c = new Vec3( 0, 0, 0);
  for( int i = 0; i < numBoids; i++ ) {
    if ( b != i ) {
      if ( abs( pos[i].x - pos[b].x ) < dis) c.x = c.x - (pos[i].x - pos[b].x);
      if ( abs( pos[i].y - pos[b].y ) < dis) c.y = c.y - (pos[i].y - pos[b].y);
      if ( abs( pos[i].z - pos[b].z ) < dis) c.z = c.z - (pos[i].z - pos[b].z);
    }
  }
  return c;
}

Vec3 rulethree( int b ) { // Boids try to match velocity with near boids.
  float val = 200;
  Vec3 pc = new Vec3(0, 0, 0);
  for( int i = 0; i < numBoids; i++ ) {
    if( i != b ) pc.add(vel[i]);
  }
  pc.mul( 1/(numBoids-1) );
  
  return new Vec3( (pc.x - vel[b].x)/val , (pc.y - vel[b].y)/val, (pc.z - vel[b].z)/val);
}

Vec3 tend_to_box( int b){
  return new Vec3( (boxpos.x - pos[b].x)/100, (boxpos.y - pos[b].y)/100, (boxpos.z - pos[b].z)/100 );
}

void limitspeed( int b ) {
  float maxSpeed = 0.5;
  if( vel[b].x > maxSpeed ) vel[b].x = (vel[b].x / abs(vel[b].x) ) * maxSpeed ;
  if( vel[b].y > maxSpeed ) vel[b].y = (vel[b].y / abs(vel[b].y) ) * maxSpeed ;
  if( vel[b].z > maxSpeed ) vel[b].z = (vel[b].z / abs(vel[b].z) ) * maxSpeed ;
}

void drawshapes() {
  // draw boids
  for (int i = 0; i < numBoids; i++){
    fill( col[i].x, col[i].y, col[i].z );
    pushMatrix();
    noStroke();
    translate(pos[i].x, pos[i].y, pos[i].z);
    sphere(radius);
    stroke(1);
    popMatrix();
  }
  
  // draw lantern box
  pushMatrix();
  //fill(0);
  translate(boxpos.x, boxpos.y, boxpos.z);
  //box(2);  
  shape(lantern);
  popMatrix();
  
  // draw ground
  pushMatrix();
  fill(0, 100, 0);//green
  translate(-100, 20, -100);
  box(400,1,400);
  fill(0, 0, 0);
  popMatrix();
  
  // draw ground
  pushMatrix();
  fill(0, 50, 0);//green
  translate(-100, 20, -100);
  //box(400,1,400);
  rotateZ(PI);
  shape(tree1);
  fill(0, 0, 0);
  popMatrix();
  
  // draw ground
  pushMatrix();
  fill(50, 50, 0);//green
  translate(0, 20, -100);
  //box(400,1,400);
  rotateZ(PI);
  shape(tree2);
  fill(0, 0, 0);
  popMatrix();
}


void keyPressed()
{
  camera.HandleKeyPressed();
  
  float boxSpeed = 0.2;
      if ( key == 'u' ) boxvel.y = boxSpeed;
      if ( key == 'j' ) boxvel.x = -boxSpeed;
      if ( key == 'k' ) boxvel.z = boxSpeed;
      if ( key == 'i' ) boxvel.z = -boxSpeed;
      if ( key == 'o' ) boxvel.y = -boxSpeed;
      if ( key == 'l' ) boxvel.x = boxSpeed;

}

void keyReleased()
{
  camera.HandleKeyReleased();
      if ( key == 'u' ) boxvel.y = 0;
      if ( key == 'j' ) boxvel.x = 0;
      if ( key == 'i' ) boxvel.z = 0;
      if ( key == 'k' ) boxvel.z = 0;
      if ( key == 'o' ) boxvel.y = 0;
      if ( key == 'l' ) boxvel.x = 0;

}

void moveBox() {
    boxpos = boxpos.plus(boxvel.times(dt) );
}
