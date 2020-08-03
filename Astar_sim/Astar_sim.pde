Camera camera;

boolean paused = true;
boolean drawNodes = false;
boolean drawPath = true;

int numObstacles = 80;
int numNodes = 200;
int numAgents = 5;

PShape ship; 
PShape asteroid;


Vec3 spherePos[] = new Vec3[numObstacles];
float sphereRad[] = new float[numObstacles];

Vec3 nodePos[] = new Vec3[numNodes];
ArrayList<Integer> neighborList[] = new ArrayList[numNodes];

Vec3 startPos[] = new Vec3[numAgents];
Vec3 goalPos[] = new Vec3[numAgents];

Vec3 agentPos[] = new Vec3[numAgents];
Vec3 agentVel[] = new Vec3[numAgents];
float agentX[] = new float[numAgents];
float agentY[] = new float[numAgents];
float agentRad = 10;
float maxSpeed = 70;

Vec3 agentLooking[] = new Vec3[numAgents];

ArrayList<Integer> path[] = new ArrayList[numAgents];
int curPathIndex[] = new int[numAgents];

Vec3 saveCamPos = new Vec3(0, 0, 0);
float saveCamPhi = 0;
float saveCamTheta = 0;

int randomSphere = 0;

void setup() {
  size(1280, 720, P3D);

  camera = new Camera();
  camera.position = new PVector(250,0,0);
  camera.phi = -.60;
  
  // laod space ship
  // https://free3d.com/3d-model/wraith-raider-starship-22193.html
  ship = loadShape("Starship/Wraith_Raider_Starship.obj");
  ship.scale(0.05);
  
  //https://www.cgtrader.com/free-3d-models/space/planet/low-poly-micro-planet-2
  asteroid = loadShape("asteroid/planet3.obj");
  
  for(int i=0; i<numAgents; i++) {  
    if(random(100) > 50) {
      startPos[i] = new Vec3(random(0,500), 250, -180);
      goalPos[i] = new Vec3(random(0,500), 250, -820);
      agentY[i] = 0;
      agentLooking[i] = new Vec3(1,0,0);

    } else {
      startPos[i] = new Vec3(-20, 250, -1*random(180,820));
      goalPos[i] = new Vec3(520, 250, -1*random(180,820));
      agentY[i] = 90;
      agentLooking[i] = new Vec3(0,1,0);

    }

    agentPos[i] = new Vec3(startPos[i].x, startPos[i].y, startPos[i].z);
    agentVel[i] = new Vec3(0,0,0);
    agentX[i] = 180; 
  }
  
  // generate random spheres and radii
  for (int i = 0; i < numObstacles; i++){
    spherePos[i] = new Vec3(random(0,500), 200 + random(0,100), -1*random(200,800) );
    sphereRad[i] = (10+20*pow(random(1),3));
  }
  
  //generate node locations
  for(int i=0; i<numNodes-(numAgents*2); i++) {
    Vec3 randPos = new Vec3(random(0,500), 200 + random(0,100), -1*random(200,800));
    boolean insideSphere = pointInSphereList(spherePos, sphereRad, numObstacles, randPos);
    while (insideSphere) {
      randPos = new Vec3(random(0,500), 200 + random(0,100), -1*random(200,800));
      insideSphere = pointInSphereList(spherePos, sphereRad, numObstacles, randPos);
    }
    //print(randPos + "\n");
    nodePos[i] = randPos;
  }
  
  for(int i =numNodes-(numAgents*2), j =0; i< numNodes-(numAgents); i++, j++) {
    nodePos[i] = startPos[j];
    nodePos[i+numAgents] = goalPos[j];
  }
  
  //connect nodes with other visible nodes
  neighborList = neighborNodes(nodePos, numNodes, sphereRad, spherePos, numObstacles, agentRad);
  
  for(int i = 0; i <numAgents; i++) {
    path[i] = runAstar(nodePos, numNodes, numNodes-(numAgents*2)+i, numNodes-(numAgents)+i, neighborList);
  }
  
  randomSphere = floor(random(0, numObstacles));
}


void draw() {
  background(0);
  lights();
  noStroke();
  
  camera.Update(1.0/frameRate);
  
  for(int i=0; i<numAgents; i++) {
  fill(0, 255, 0);
  pushMatrix();
  translate( startPos[i].x, startPos[i].y, startPos[i].z);
  box( 20 );
  popMatrix();
  
  fill(255, 0, 0);
  pushMatrix();
  translate( goalPos[i].x, goalPos[i].y, goalPos[i].z);
  box( 20 );
  popMatrix();
  }
  
  for(int i = 0; i < numObstacles; i++) {
    fill( 100, 100, 100 );
    /*pushMatrix();
    translate( spherePos[i].x, spherePos[i].y, spherePos[i].z );
    sphere( sphereRad[i] );
    popMatrix();*/
    pushMatrix();
    translate( spherePos[i].x+6*sphereRad[i], spherePos[i].y, spherePos[i].z );
    asteroid.scale(sphereRad[i]);
    shape(asteroid);
    asteroid.scale(1/(sphereRad[i]));
    popMatrix();
  }
  
  if(drawNodes) drawNodes();
  if(drawPath) drawPath();
  if (!paused) moveAgentList(1.0/frameRate);
  
  for(int i =0; i < numAgents; i++) {
  // draw agent  
  fill(0, 0, 255);
  pushMatrix();
  translate( agentPos[i].x, agentPos[i].y, agentPos[i].z);
  //box(agentRad);
  //if(agentY[i] > 0) ship.rotateY(radians(agentY[i]));
  shape(ship );
  popMatrix();
  }
  
  moveAsteroid();
}

void moveAgentList(float dt) {
  for(int i =0;  i< numAgents; i++){
    moveAgent(i, dt);
  }
}

void moveAgent(int numA, float dt) {
  agentVel[numA] = computeAgentVel(numA, path[numA], dt);
  agentPos[numA].add(agentVel[numA].times(dt));
}

Vec3 computeAgentVel(int numA, ArrayList<Integer> path, float dt) {
  if(path.get(0) == -1 ) return new Vec3(0,0,0);
  Vec3 curNode = nodePos[path.get(curPathIndex[numA])];
  if( agentPos[numA].distanceTo(curNode) < 5 && path.size()-1 > curPathIndex[numA] ) {
    curPathIndex[numA]++;
    
    //float dotprod = dot(agentVel[numA], curNode);
    //float theta = dotprod / (agentVel[numA].length() * curNode.length() );
    //agentY[numA] += acos(theta);
    //agentY[numA] = 40;
    //print(acos(theta)+"\n");
    //ship.rotateY(radians(agentY[numA]));
  }
  /*float dotprod = dot(agentLooking[numA],agentVel[numA]);
  float theta = acos(dotprod/( agentVel[numA].length() * agentLooking[numA].length() ));
  float phi = asin(dotprod/( agentVel[numA].length() * agentLooking[numA].length() ));
  print("phi:"+phi + " theta:" + theta + "\n");
  if(phi > PI/2) agentX[numA] = -0.5;
  if(phi < PI/2) agentX[numA] = 0.5;
  if(theta > PI/2) agentY[numA] = -0.5;
  if(theta < PI/2) agentY[numA] = 0.5;*/
  Vec3 diff = nodePos[path.get(curPathIndex[numA])].minus(agentPos[numA]);
  diff.normalize();
  diff.mul(maxSpeed);
  return diff;
}

void drawNodes() {
  stroke(200);
  for(int i = 0; i < numNodes; i++) {
    for(int j=0; j< neighborList[i].size(); j++) {
      pushMatrix();
      line(nodePos[i].x, nodePos[i].y, nodePos[i].z, nodePos[neighborList[i].get(j)].x, nodePos[neighborList[i].get(j)].y, nodePos[neighborList[i].get(j)].z);
      popMatrix();
    }
  }
  stroke(0);
}

void drawPath() {
  stroke(200, 0, 0);
  for(int j = 0; j< numAgents; j++) {
  for(int i = 0; i < path[j].size()-1; i++) {
    pushMatrix();
    line(nodePos[path[j].get(i)].x, nodePos[path[j].get(i)].y, nodePos[path[j].get(i)].z, 
      nodePos[path[j].get(i+1)].x, nodePos[path[j].get(i+1)].y, nodePos[path[j].get(i+1)].z);
    popMatrix();
  }
  }
  stroke(0);
}

/*
void mouseClicked() {
  
  
}

int s = -1;

void mousePressed() {
  int mx = mouseX;
  int mz = mouseY;
  for(int i = 0; i < numObstacles; i++) {
    if( abs(mx - spherePos[i].x) < sphereRad[i]+10 && abs(mz - spherePos[i].z) < sphereRad[i]+10 ) {
      s = i;
      break;
    }
  }
  
}

void mouseReleased() {
  if( s != -1) {
    print(mouseX +" "+ mouseY + "\n");
    spherePos[s].x = mouseX;
    spherePos[s].z = mouseY;
  }
  getPaths();
}*/

Vec3 boxvel = new Vec3(0,0,0);
void keyPressed()
{
  if (key == ' ') paused = !paused;
  if (key == 'n') drawNodes = !drawNodes;
  if (key == 'p') drawPath = !drawPath;
  
   float boxSpeed = 20;
      if ( key == 'u' ) boxvel.y = boxSpeed;
      if ( key == 'j' ) boxvel.x = -boxSpeed;
      if ( key == 'k' ) boxvel.z = boxSpeed;
      if ( key == 'i' ) boxvel.z = -boxSpeed;
      if ( key == 'o' ) boxvel.y = -boxSpeed;
      if ( key == 'l' ) boxvel.x = boxSpeed;

  camera.HandleKeyPressed();
  if( key == 'u' ||  key == 'j' || key == 'k' || key == 'i' || key == 'o' || key == 'l') {
  for(int i =numNodes-(numAgents*2), j =0; i< numNodes-(numAgents); i++, j++) {
    nodePos[i] = agentPos[j];
    nodePos[i+numAgents] = goalPos[j];
  }
  
   //with other visible nodes
  neighborList = neighborNodes(nodePos, numNodes, sphereRad, spherePos, numObstacles, agentRad);
  
  for(int i = 0; i <numAgents; i++) {
    path[i] = runAstar(nodePos, numNodes, numNodes-(numAgents*2)+i, numNodes-(numAgents)+i, neighborList);
  }
  
  }
}

void keyReleased()
{
  if ( key == 'u' ) boxvel.y = 0;
      if ( key == 'j' ) boxvel.x = 0;
      if ( key == 'i' ) boxvel.z = 0;
      if ( key == 'k' ) boxvel.z = 0;
      if ( key == 'o' ) boxvel.y = 0;
      if ( key == 'l' ) boxvel.x = 0;
  
  
  camera.HandleKeyReleased();
  
  
}

void moveAsteroid() {
    spherePos[randomSphere] = spherePos[randomSphere].plus(boxvel.times(1/frameRate) );
}
