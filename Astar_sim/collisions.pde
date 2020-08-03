boolean pointInSphere(Vec3 spherePos, float r, Vec3 pointPos) {
  if(pointPos.distanceTo(spherePos) < r+2)
    return true; 
  return false;
}

boolean pointInSphereList(Vec3[] spherePos, float[] sphereRad, int numObstacles, Vec3 pointPos) {
  for(int i = 0; i < numObstacles; i++) {
    if(pointInSphere(spherePos[i], sphereRad[i], pointPos))
      return true;
  }
  
  return false;
}

ArrayList<Integer>[] neighborNodes(Vec3[] nodes, int numNodes, float[] sphereRad, Vec3[] spherePos, int numSphere, float agentRad) {
  ArrayList<Integer>[] neighbors = new ArrayList[numNodes];
  
  for(int i = 0; i < numNodes; i++) {
    neighbors[i] = new ArrayList<Integer>();
    for(int j = 0; j<numNodes; j++) {
      if(i==j) continue;
      if( !sphereIntersectList(spherePos, sphereRad, numSphere, nodes[i], nodes[j], agentRad) )
        neighbors[i].add(j);
    }
  }
  
  return neighbors;
}

boolean sphereIntersect(Vec3 center, float r, float agentRad, Vec3 pointOne, Vec3 pointTwo) {
  Vec3 direction = pointTwo.minus(pointOne).normalized();
  float omcd = dot(pointOne.minus(center), pointOne.minus(center));
  // https://en.wikipedia.org/wiki/Line%E2%80%93sphere_intersection
  float delta = sq(dot(direction, pointOne.minus(center))) - (omcd - sq(r+agentRad));
  if(delta < 0)
    return false;
  return true;
}

boolean sphereIntersectList(Vec3[] centers, float[] radii, int numObstacles, Vec3 pointOne, Vec3 pointTwo, float agentRad) {
  for(int i=0; i<numObstacles; i++) {
    if( sphereIntersect( centers[i], radii[i], agentRad, pointOne, pointTwo) ) {
      return true;
    }
  }
  return false;
}
