class Vector {
  double x;
  double y;
  double z;

  Vector({
    this.x = 0,
    this.y = 0,
    this.z = 0,
  });
}

class VectorSize extends Vector {
  double w;
  double h;

  VectorSize({
    super.x,
    super.y,
    this.w = 0,
    this.h = 0,
  });
}
