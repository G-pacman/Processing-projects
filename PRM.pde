


ArrayList<Integer> runAstar(Vec3[] nodePos, int numNodes, int startID, int goalID, ArrayList<Integer>[] neighbors){
  Boolean[] visited = new Boolean[numNodes]; //A list which store if a given node has been visited
  int[] parent = new int[numNodes]; //A list which stores the best previous node on the optimal path to reach this node
  
  ArrayList<Integer> fringe = new ArrayList();  //New empty fringe
  ArrayList<Integer> path = new ArrayList();
  
  float gScore[] = new float[numNodes];
  float fScore[] = new float[numNodes];
  
  for(int i = 0; i < numNodes; i++) {
    gScore[i] = 1000000000;
    fScore[i] = 1000000000;
  }
  
  gScore[startID] = 0;
  fScore[startID] = 0;
  
  for (int i = 0; i < numNodes; i++) { //Clear visit tags and parent pointers
    visited[i] = false;
    parent[i] = -1; //No parent yet
  }

  //println("\nBeginning Search");
  visited[startID] = true;
  fringe.add(startID);
  //println("Adding node", startID, "(start) to the fringe.");
  //println(" Current Fringe: ", fringe);
  
  while (fringe.size() > 0) {
    int currentNode = fringe.get(0);
    fringe.remove(0);
    
    if (currentNode == goalID){
      //println("Goal found!");
      break;
    }
    for (int i = 0; i < neighbors[currentNode].size(); i++){
      int neighborNode = neighbors[currentNode].get(i);
      float t_gScore = gScore[currentNode] + nodePos[neighborNode].distanceTo(nodePos[currentNode]);
      
      if (t_gScore < gScore[neighborNode] || gScore[neighborNode] == -1){
        gScore[neighborNode] = t_gScore;
        fScore[neighborNode] = gScore[neighborNode] + nodePos[neighborNode].distanceTo(nodePos[goalID]);
        
        if( !(fringe.contains(neighborNode)) && !visited[neighborNode] ) {
          int loc = 0;
          for (int j=0; j<fringe.size(); j++) {
            if (fScore[neighborNode] > fScore[fringe.get(j)]) loc = j;
          }
          fringe.add(loc, neighborNode);
          visited[neighborNode] = true;
          parent[neighborNode] = currentNode;
          
          //println("Added node", neighborNode, "to the fringe.");
          //println(" Current Fringe: ", fringe);
        }
      }
    } 
  }
  
  if (fringe.size() == 0){
    //println("No Path");
    path.add(0,-1);
    return path;
  }
    
  //print("\nReverse path: ");
  int prevNode = parent[goalID];
  path.add(0,goalID);
  //print(goalID, " ");
  while (prevNode >= 0){
    //print(prevNode," ");
    path.add(0,prevNode);
    prevNode = parent[prevNode];
  }
  //print("\n");
  
  return path;
}
