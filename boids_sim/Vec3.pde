//Vector Library [2D]
//CSCI 5611 Vector 3 Library [Incomplete]

//Instructions: Add 3D versions of all of the 2D vector functions
//              Vec3 must also support the cross product.
public class Vec3 {
  public float x, y, z;
  
  public Vec3(float x, float y, float z){
    this.x = x;
    this.y = y;
    this.z = z;
  }
  
  public String toString(){
    return "(" + x+ ", " + y + ", " + z +")";
  }
  
  public float length(){
    return sqrt(sq(x) + sq(y) + sq(z));
  }
  
  public Vec3 plus(Vec3 rhs){
    return new Vec3(this.x + rhs.x,this.y + rhs.y, this.z + rhs.z);
  }
  
  public void add(Vec3 rhs){
    this.z += rhs.z;
    this.x += rhs.x;
    this.y += rhs.y;
  }
  
  public Vec3 minus(Vec3 rhs){
    return new Vec3(this.x - rhs.x, this.y - rhs.y, this.z - rhs.z);
  }
  
  public void subtract(Vec3 rhs){
    this.z -= rhs.z;
    this.x -= rhs.x;
    this.y -= rhs.y;
  }
  
  public Vec3 times(float rhs){
    return new Vec3(this.x * rhs, this.y * rhs, this.z * rhs);
  }
  
  public void mul(float rhs){
    this.z *= rhs;
    this.x *= rhs;
    this.y *= rhs;
  }
  
  public void normalize(){
    float mag = this.length();
    this.z /= mag;
    this.x /= mag;
    this.y /= mag;
  }
  
  public Vec3 normalized(){
    float mag = this.length();
    return new Vec3(this.x/mag,this.y/mag,this.z/mag);
  }
  
  public float distanceTo(Vec3 rhs){
    Vec3 vec = this.minus(rhs);
    return vec.length();
  }
}

Vec3 interpolate(Vec3 a, Vec3 b, float t){
  return new Vec3(a.x * t + b.x * ( 1.0f -t ),a.y * t + b.y * ( 1.0f -t ),a.z * t + b.z * ( 1.0f -t )); 
}

float dot(Vec3 a, Vec3 b){
  return a.x * b.x + a.y * b.y + a.z * b.z;
}

Vec3 cross(Vec3 a, Vec3 b){
  return new Vec3(a.y * b.z - a.z * b.y,a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x);
}

Vec3 projAB(Vec3 a, Vec3 b){
  return new Vec3(a.x * b.x, a.y * b.y, a.z * b.z);
}
