// SWS3005_02 gluttonous snake by Android6 - https://www.shadertoy.com/view/McscRB - CC BY-NC-SA 3.0
// Creative Commons BY-NC-SA 3.0: share it credited, not for sale; a changed one on the same terms (https://creativecommons.org/licenses/by-nc-sa/3.0/)
// WLED Effects Studio: the beat and the bass added at the end of the Image pass (marked)
// NAME: SWS3005_02 gluttonous snake (Android6)
// SWS3005_02 gluttonous snake by Android6
// https://www.shadertoy.com/view/McscRB
// imported from its JSON - the author's (CC BY-NC-SA 3.0 unless the code says otherwise)
// 新国立暑期实时渲染课程作业五，小组二
//@ image
//@ iChannel0 = none
//@ iChannel1 = none
//@ iChannel2 = none
//@ iChannel3 = none
//============================================================================
// PROJECT ID:
//
// GROUP NUMBER: 02
//
// STUDENT NAME:
// NUS User ID.:
//
// STUDENT NAME:
// NUS User ID.:
//
// STUDENT NAME:
// NUS User ID.:
//
// STUDENT NAME:
// NUS User ID.:
//
// COMMENTS TO GRADER:
//
//============================================================================
#define mainImage vj_inner   // WLED Effects Studio: the shader's own, wrapped at the end

// FRAGMENT SHADER FOR SHADERTOY
// Run this at https://www.shadertoy.com/view/McscRB
// See documentation at https://www.shadertoy.com/howto

// Your browser must support WebGL 2.0.
// Check your browser at https://webglreport.com/?v=2

//============================================================================
// Constants.
//============================================================================

const float PI = 3.1415926536;

const vec3 BACKGROUND_COLOR = vec3( 0.1, 0.2, 0.6 );

// Vertical field-of-view angle of camera. In radians.
const float FOVY = 50.0 * PI / 180.0;

// Use this for avoiding the "epsilon problem" or the shadow acne problem.
const float DEFAULT_TMIN = 10.0e-4;

// Use this for tmax for non-shadow ray intersection test.
const float DEFAULT_TMAX = 10.0e6;

// Equivalent to number of recursion levels (0 means ray-casting only).
// We are using iterations to replace recursions.
const int NUM_ITERATIONS = 2;

// Constants for the scene objects.
const int NUM_LIGHTS = 2;
const int NUM_MATERIALS = 19;
const int NUM_PLANES = 5;
const int NUM_SPHERES = 9;

//============================================================================
// Define new struct types.
//============================================================================
struct Ray_t {
    vec3 o; // Ray Origin.
    vec3 d; // Ray Direction. A unit vector.
};

struct Plane_t {
    // The plane equation is Ax + By + Cz + D = 0.
    float A, B, C, D;
    int materialID;
};

struct Sphere_t {
    vec3 center;
    float radius;
    int materialID;
    int dirrection;
};

struct Light_t {
    vec3 position; // Point light 3D position.
    vec3 I_a;      // For Ambient.
    vec3 I_source; // For Diffuse and Specular.
};

struct Material_t {
    vec3 k_a;  // Ambient coefficient.
    vec3 k_d;  // Diffuse coefficient.
    vec3 k_r;  // Reflected specular coefficient.
    vec3 k_rg; // Global reflection coefficient.
    float n;   // The specular reflection exponent. Ranges from 0.0 to 128.0.
};

//============================================================================
// Global scene data.
//============================================================================
Plane_t Plane[NUM_PLANES];
Sphere_t Sphere[NUM_SPHERES];
Light_t Light[NUM_LIGHTS];
Material_t Material[NUM_MATERIALS];

// 自定义的全局变量
int SphereLevel[10];
const float SNAKE_RADIUS = 0.4;
int DirectionX[4];
int DirectionY[4];
int SnakeNum = 5;
const int TotalTime = 36;
const int StepNum = 18;
const float TimeScale = 2.0f;
const float ScaleSizeSpeed = 10.0f;
const int MaxAddNum = 4;
int BlackMaterial = 10;

ivec2 moveForward[StepNum];
int startPos[NUM_SPHERES];
float addTime[MaxAddNum];
float removeTime[MaxAddNum];
vec2 scaleTime[MaxAddNum];



int CheckInScaleTime(float nowTime) {
    for (int i = 0; i < MaxAddNum; i++) {
        if (scaleTime[i].x <= nowTime && nowTime <= scaleTime[i].y) return i;
    } return -1;
}

//Adjust all the parameters of the balls, including animations
void SetUpBalls() {
    float nowTime = iTime * TimeScale;
    nowTime = fract(nowTime / float(TotalTime)) * float(TotalTime);
    int nowFrameTime = int(nowTime) % TotalTime;
    int cnt = nowFrameTime % StepNum;
    int flag = int(nowFrameTime / StepNum);

    for (int i = 0; i < NUM_SPHERES; i++) {
        Sphere[i].radius = SNAKE_RADIUS;
        float sphereY =
            abs(sin(8.0 * iTime + float(SphereLevel[i]))) + SNAKE_RADIUS;
        Sphere[i].center.y = sphereY;
        Sphere[i].materialID = i;
    }

    Sphere[0].radius = 1.3 * SNAKE_RADIUS;

    for (int i = 0; i < SnakeNum; i++) {
        float sphereX = 0.0;
        float sphereZ = float(i);
        Sphere[i].center.xz = vec3(sphereX, 0, sphereZ).xz;
    }
    //snake body moving
    if (flag == 0) {
        SnakeNum = 5;
        for (int i = 0; i < MaxAddNum; i++) 
            if (nowTime >= addTime[i]) SnakeNum++;
            
        int ScaleTimeFlag = CheckInScaleTime(nowTime);

        //Swelling after eating the ball
        if (ScaleTimeFlag != -1) {
            float nowScaleTime = nowTime - scaleTime[ScaleTimeFlag].x;
            Sphere[0].radius = Sphere[0].radius + 0.1 * sin(nowScaleTime * ScaleSizeSpeed * PI);
        }

        if (SnakeNum <= 5) {
            Sphere[5].center.xz = vec2(1.0, 2.0);
        } else {
            Sphere[5].center.xz = vec2(1.0, 4.0);
        }
        if (SnakeNum <= 6) {
            Sphere[6].center.xz = vec2(3.0, 1.0);
        } else {
            Sphere[6].center.xz = vec2(2.0, 4.0);
        }
        if (SnakeNum <= 7) {
            Sphere[7].center.xz = vec2(4.0, 3.0);
        } else {
            Sphere[7].center.xz = vec2(3.0, 4.0);
        }
        if (SnakeNum <= 8) {
            Sphere[8].center.xz = vec2(2.0, 4.0);
        } else {
            Sphere[8].center.xz = vec2(4.0, 4.0);
        }
    } else if (flag == 1) {
        SnakeNum = 9;
        for (int i = 0; i < MaxAddNum; i++)
            if (float(cnt) >= removeTime[i]) SnakeNum--;

        if (SnakeNum <= 5) {
            Sphere[5].center.xz = vec2(2.0, 4.0);
        } else {
            Sphere[5].center.xz = vec2(1.0, 4.0);
        }
        if (SnakeNum <= 6) {
            Sphere[6].center.xz = vec2(4.0, 3.0);
        } else {
            Sphere[6].center.xz = vec2(2.0, 4.0);
        }
        if (SnakeNum <= 7) {
            Sphere[7].center.xz = vec2(3.0, 1.0);
        } else {
            Sphere[7].center.xz = vec2(3.0, 4.0);
        }
        if (SnakeNum <= 8) {
            Sphere[8].center.xz = vec2(1.0, 2.0);
        } else {
            Sphere[8].center.xz = vec2(4.0, 4.0);
        }
    }

    
    for (int i = 0; i < SnakeNum; i++) {
        int start = startPos[i];
        for (int j = 0; j < cnt; j++, start = (start + 1) % StepNum) {
            Sphere[i].center.xz += vec2(moveForward[start]);
        }
        Sphere[i].center.xz += vec2(moveForward[start]) * fract(nowTime);
    }
}

vec3 convertColor(int r, int g, int b) {
    return vec3(float(r) / 255.0, float(g) / 255.0, float(b) / 255.0);
}

// define eight basic colors
vec3 greatColors[8];
void initializeColors() {
    greatColors[0] = convertColor(138, 43, 226);  // 紫罗兰
    greatColors[1] = convertColor(227, 23, 13);   // 朱红
    greatColors[2] = convertColor(255, 128, 0);   // 橘黄
    greatColors[3] = convertColor(218, 112, 205); // 杏色
    greatColors[4] = convertColor(255, 153, 18);  // 铬黄
    greatColors[5] = convertColor(61, 89, 171);   // 深蓝色
    greatColors[6] = convertColor(0, 201, 187);   // 翠绿色
    greatColors[7] = convertColor(128, 42, 42);   // 棕色

}

// mix now color and next color
vec3 getTransitionColor(int seed) {

    int currentIndex = (seed) % 8;
    int nextIndex = (currentIndex + 1) % 8;

    float transitionDuration = 10.0; // 过渡时间长度
    float t = mod(iTime * 3.0, transitionDuration) / transitionDuration;

    vec3 currentColor = greatColors[currentIndex];
    vec3 nextColor = greatColors[nextIndex];

    return mix(currentColor, nextColor, 1. - t);
}

void SetUpMaterial() {
    // materials for balls
    for (int i = 0; i < NUM_SPHERES; i++) {
        Material[i].k_d = greatColors[i % 8];
        Material[i].k_r = vec3(0.2, 0.2, 0.2);
        Material[i].k_rg = 4.0 * vec3(0.1, 0.1, 0.1);
        Material[i].n = 64.0;
    }

    Material[9].k_d = vec3(0.5, 0.5, 0.5);
    Material[9].k_a = 0.2 * Material[9].k_d;
    Material[9].k_r = 2.0 * Material[9].k_d;
    Material[9].k_rg = 0.5 * Material[9].k_r;
    Material[9].n = 64.0;

    //materials for walls

    for(int i = 11; i <= 18; i++){
        Material[i].k_d = getTransitionColor(i);
        Material[i].k_a = 0.2 * Material[i].k_d;
        Material[i].k_r = 2.0 * Material[i].k_d;
        Material[i].k_rg = 0.5 * Material[i].k_r;
        Material[i].n = 128.0;
    }


    // Black material.
    Material[BlackMaterial].k_d = vec3(0.0, 0.0, 0.0);
    Material[BlackMaterial].k_a = vec3(0.11, 0.06, 0.09);
    Material[BlackMaterial].k_r = vec3(0.33, 0.33, 0.52);
    Material[BlackMaterial].k_rg = 0.4 * Material[8].k_r;
    Material[BlackMaterial].n = 128.0;
}

void SetUpLight() {
    Light[0].position = vec3(2.0, 8.0, 2.0);
    Light[0].I_a = vec3(0.1, 0.1, 0.1);
    Light[0].I_source = 0.5 * vec3(1.0, 1.0, 1.0);

    Light[1].position = vec3(6.0, 8.0, 6.0);
    Light[1].I_a = vec3(0.9, 0.9, 0.9);
    Light[1].I_source = 0.5 * vec3(1.0, 1.0, 1.0);
}

/////////////////////////////////////////////////////////////////////////////
// Initializes the scene.
/////////////////////////////////////////////////////////////////////////////
void InitScene() {
    moveForward[0] = ivec2(1, 0);
    moveForward[1] = ivec2(0, 1);
    moveForward[2] = ivec2(0, 1);
    moveForward[3] = ivec2(1, 0);
    moveForward[4] = ivec2(0, -1);
    moveForward[5] = ivec2(1, 0);
    moveForward[6] = ivec2(1, 0);
    moveForward[7] = ivec2(0, 1);
    moveForward[8] = ivec2(0, 1);
    moveForward[9] = ivec2(0, 1);
    moveForward[10] = ivec2(-1, 0);
    moveForward[11] = ivec2(-1, 0);
    moveForward[12] = ivec2(-1, 0);
    moveForward[13] = ivec2(-1, 0);
    moveForward[14] = ivec2(0, -1);
    moveForward[15] = ivec2(0, -1);
    moveForward[16] = ivec2(0, -1);
    moveForward[17] = ivec2(0, -1);

    startPos[0] = 0;
    startPos[1] = 17;
    startPos[2] = 16;
    startPos[3] = 15;
    startPos[4] = 14;
    startPos[5] = 13;
    startPos[6] = 12;
    startPos[7] = 11;
    startPos[8] = 10;
    
    addTime[0] = 2.5;
    addTime[1] = 5.5;
    addTime[2] = 8.5;
    addTime[3] = 11.5;
    
    scaleTime[0] = vec2(2.5, 3.5);
    scaleTime[1] = vec2(5.5, 6.5);
    scaleTime[2] = vec2(8.5, 9.5);
    scaleTime[3] = vec2(11.5, 12.5);
    
    removeTime[0] = 11.0;
    removeTime[1] = 13.0;
    removeTime[2] = 15.0;
    removeTime[3] = 17.0;
    
    // 动画应该也要在这里面做完。
    //  Horizontal plane.
    Plane[0].A = 0.0;
    Plane[0].B = 1.0;
    Plane[0].C = 0.0;
    Plane[0].D = 0.0;
    Plane[0].materialID = 9;

    // Vertical plane.
    Plane[1].A = 0.0;
    Plane[1].B = 0.0;
    Plane[1].C = 1.0;
    Plane[1].D = 2.5;
    Plane[1].materialID = 9;

    // Vertical plane.
    Plane[2].A = 0.0;
    Plane[2].B = 0.0;
    Plane[2].C = 1.0;
    Plane[2].D = -6.5;
    Plane[2].materialID = 9;

    // Vertical plane.
    Plane[3].A = 1.0;
    Plane[3].B = 0.0;
    Plane[3].C = 0.0;
    Plane[3].D = 2.5;
    Plane[3].materialID = 9;

    // Vertical plane.
    Plane[4].A = 1.0;
    Plane[4].B = 0.0;
    Plane[4].C = 0.0;
    Plane[4].D = -6.5;
    Plane[4].materialID = 9;

    SetUpBalls();
    // 把球摆好

    // 材质初始化
    SetUpMaterial();

    // 光源初始化
    SetUpLight();
}

bool IntersectPlane(in Plane_t pln, in Ray_t ray, in float tmin, in float tmax,
                    out float t, out vec3 hitPos, out vec3 hitNormal) {
    vec3 N = vec3(pln.A, pln.B, pln.C);
    float NRd = dot(N, ray.d);
    float NRo = dot(N, ray.o);
    float t0 = (-pln.D - NRo) / NRd;
    if (t0 < tmin || t0 > tmax)
        return false;

    // We have a hit -- output results.
    t = t0;
    hitPos = ray.o + t0 * ray.d;
    hitNormal = normalize(N);
    return true;
}

bool IntersectPlane(in Plane_t pln, in Ray_t ray, in float tmin,
                    in float tmax) {
    vec3 N = vec3(pln.A, pln.B, pln.C);
    float NRd = dot(N, ray.d);
    float NRo = dot(N, ray.o);
    float t0 = (-pln.D - NRo) / NRd;
    if (t0 < tmin || t0 > tmax)
        return false;
    return true;
}

// 渲染模块
bool IntersectSphere(in Sphere_t sph, in Ray_t ray, in float tmin,
                     in float tmax, out float t, out vec3 hitPos,
                     out vec3 hitNormal) {

    vec3 oc = ray.o - sph.center; // 光线原点到球心
    float a = dot(ray.d, ray.d);  // 1
    float b = 2.0 * dot(ray.d, oc);
    float c = dot(oc, oc) - sph.radius * sph.radius;
    float d = b * b - 4.0 * a * c;
    if (d < 0.0)
        return false;
    float t1 = (-b + sqrt(d)) / (2.0 * a);
    float t2 = (-b - sqrt(d)) / (2.0 * a);
    float t0;
    if (t1 > 0.0 && t2 > 0.0)
        t0 = min(t1, t2);
    else if (t1 > 0.0 && t2 <= 0.0)
        t0 = t1;
    else if (t1 <= 0.0 && t2 > 0.0)
        t0 = t2;
    else
        return false;
    if (t0 < tmin || t0 > tmax)
        return false;

    t = t0;
    hitPos = ray.o + t0 * ray.d;
    hitNormal = normalize(hitPos - sph.center);
    return true;
}

bool IntersectSphere(in Sphere_t sph, in Ray_t ray, in float tmin,
                     in float tmax) {
    vec3 oc = ray.o - sph.center; // 光线原点到球心
    float a = dot(ray.d, ray.d);  // 1
    float b = 2.0 * dot(ray.d, oc);
    float c = dot(oc, oc) - sph.radius * sph.radius;
    float d = b * b - 4.0 * a * c;
    if (d < 0.0)
        return false;
    float t1 = (-b + sqrt(d)) / (2.0 * a);
    float t2 = (-b - sqrt(d)) / (2.0 * a);
    float t0;
    if (t1 > 0.0 && t2 > 0.0)
        t0 = min(t1, t2);
    else if (t1 > 0.0 && t2 <= 0.0)
        t0 = t1;
    else if (t1 <= 0.0 && t2 > 0.0)
        t0 = t2;
    else
        return false;
    if (t0 < tmin || t0 > tmax)
        return false;

    return true;
}

// 计算冯氏光照模型
vec3 PhongLighting(in vec3 L, in vec3 N, in vec3 V, in bool inShadow,
                   in Material_t mat, in Light_t light) {
    if (inShadow) {
        return light.I_a * mat.k_a;
    } else {
        vec3 R = reflect(-L, N);
        float N_dot_L = max(0.0, dot(N, L));
        float R_dot_V = max(0.0, dot(R, V));
        float R_dot_V_pow_n = (R_dot_V == 0.0) ? 0.0 : pow(R_dot_V, mat.n);

        return light.I_a * mat.k_a +
               light.I_source * (mat.k_d * N_dot_L + mat.k_r * R_dot_V_pow_n);
    }
}

// 渲染模块
vec3 CastRay(in Ray_t ray, out bool hasHit, out vec3 hitPos, out vec3 hitNormal,
             out vec3 k_rg) {
    // Find whether and where the ray hits some object.
    // Take the nearest hit point.

    bool hasHitSomething = false;
    float nearest_t =
        DEFAULT_TMAX;       // The ray parameter t at the nearest hit point.
    vec3 nearest_hitPos;    // 3D position of the nearest hit point.
    vec3 nearest_hitNormal; // Normal vector at the nearest hit point.
    int nearest_hitMatID; // MaterialID of the object at the nearest hit point.

    float temp_t;
    vec3 temp_hitPos;
    vec3 temp_hitNormal;
    bool temp_hasHit;

    // planes
    for (int i = 0; i < NUM_PLANES; i++) {
        if (IntersectPlane(Plane[i], ray, DEFAULT_TMIN, DEFAULT_TMAX)) {
            temp_hasHit = true;
            IntersectPlane(Plane[i], ray, DEFAULT_TMIN, DEFAULT_TMAX, temp_t,
                           temp_hitPos, temp_hitNormal);
            if (temp_t < nearest_t) {
                hasHitSomething = temp_hasHit;
                nearest_t = temp_t;
                nearest_hitPos = temp_hitPos;
                nearest_hitNormal = temp_hitNormal;
                if (i == 0) {
                    float tempX = mod(nearest_hitPos.x + 0.5, 2.0) - 1.0;
                    float tempZ = mod(nearest_hitPos.z + 0.5, 2.0) - 1.0;
                    if (tempX * tempZ < 0.0)
                        nearest_hitMatID = Plane[i].materialID;
                    else
                        nearest_hitMatID = BlackMaterial;
                }

                else if (i == 1) {
                    float tempX = mod(nearest_hitPos.x - 0.5, 2.0) - 1.0;
                    float tempY = mod(nearest_hitPos.y, 2.0) - 1.0;
                    if (tempX < 0.9 && tempY > -0.9 && tempX > 0.1 &&
                        tempY < -0.1)
                        nearest_hitMatID = 11;
                    else if (tempX > -0.9 && tempY < 0.9 && tempX < -0.1 &&
                             tempY > 0.1)
                        nearest_hitMatID = 12;
                    else if (tempX > -0.9 && tempY > -0.9 && tempX < -0.1 &&
                             tempY < -0.1)
                        nearest_hitMatID = 13;
                    else if (tempX < 0.9 && tempY < 0.9 && tempX > 0.1 &&
                             tempY > 0.1)
                        nearest_hitMatID = 14;
                    else
                        nearest_hitMatID = BlackMaterial;
                }

                else if (i == 2) {
                    float tempX = mod(nearest_hitPos.x - 0.5, 2.0) - 1.0;
                    float tempY = mod(nearest_hitPos.y, 2.0) - 1.0;
                    if (tempX < 0.9 && tempY > -0.9 && tempX > 0.1 &&
                        tempY < -0.1)
                        nearest_hitMatID = 11;
                    else if (tempX > -0.9 && tempY < 0.9 && tempX < -0.1 &&
                             tempY > 0.1)
                        nearest_hitMatID = 12;
                    else if (tempX > -0.9 && tempY > -0.9 && tempX < -0.1 &&
                             tempY < -0.1)
                        nearest_hitMatID = 13;
                    else if (tempX < 0.9 && tempY < 0.9 && tempX > 0.1 &&
                             tempY > 0.1)
                        nearest_hitMatID = 14;
                    else
                        nearest_hitMatID = BlackMaterial;
                }

                else if (i == 3) {
                    float tempX = mod(nearest_hitPos.z - 0.5, 2.0) - 1.0;
                    float tempY = mod(nearest_hitPos.y, 2.0) - 1.0;
                    if (tempX < 0.9 && tempY > -0.9 && tempX > 0.1 &&
                        tempY < -0.1)
                        nearest_hitMatID = 11;
                    else if (tempX > -0.9 && tempY < 0.9 && tempX < -0.1 &&
                             tempY > 0.1)
                        nearest_hitMatID = 12;
                    else if (tempX > -0.9 && tempY > -0.9 && tempX < -0.1 &&
                             tempY < -0.1)
                        nearest_hitMatID = 13;
                    else if (tempX < 0.9 && tempY < 0.9 && tempX > 0.1 &&
                             tempY > 0.1)
                        nearest_hitMatID = 14;
                    else
                        nearest_hitMatID = BlackMaterial;
                }

                else if (i == 4) {
                    float tempX = mod(nearest_hitPos.z - 0.5, 2.0) - 1.0;
                    float tempY = mod(nearest_hitPos.y, 2.0) - 1.0;
                    if (tempX < 0.9 && tempY > -0.9 && tempX > 0.1 &&
                        tempY < -0.1)
                        nearest_hitMatID = 15;
                    else if (tempX > -0.9 && tempY < 0.9 && tempX < -0.1 &&
                             tempY > 0.1)
                        nearest_hitMatID = 16;
                    else if (tempX > -0.9 && tempY > -0.9 && tempX < -0.1 &&
                             tempY < -0.1)
                        nearest_hitMatID = 17;
                    else if (tempX < 0.9 && tempY < 0.9 && tempX > 0.1 &&
                             tempY > 0.1)
                        nearest_hitMatID = 18;
                    else
                        nearest_hitMatID = BlackMaterial;
                }
            }
        }
    }
    // spheres
    for (int i = 0; i < NUM_SPHERES; i++) {
        if (IntersectSphere(Sphere[i], ray, DEFAULT_TMIN, DEFAULT_TMAX)) {
            temp_hasHit = true;
            IntersectSphere(Sphere[i], ray, DEFAULT_TMIN, DEFAULT_TMAX, temp_t,
                            temp_hitPos, temp_hitNormal);
            if (temp_t < nearest_t) {
                hasHitSomething = temp_hasHit;
                nearest_t = temp_t;
                nearest_hitPos = temp_hitPos;
                nearest_hitNormal = temp_hitNormal;
                nearest_hitMatID = Sphere[i].materialID;
            }
        }
    }

    // One of the output results.
    hasHit = hasHitSomething;
    if (!hasHitSomething)
        return BACKGROUND_COLOR;

    vec3 I_local = vec3(0.0); // Result color will be accumulated here.

    for (int i = 0; i < NUM_LIGHTS; i++) {
        Ray_t shadowRay;
        shadowRay.o = nearest_hitPos;
        shadowRay.d = normalize(Light[i].position - nearest_hitPos);
        bool inShadow = false;

        // check if the shadow ray intersects any of the objects
        for (int j = 0; j < NUM_PLANES; j++) {
            if (IntersectPlane(Plane[j], shadowRay, DEFAULT_TMIN,
                               length(Light[i].position - nearest_hitPos))) {
                inShadow = true;
                break;
            }
        }

        for (int j = 0; j < NUM_SPHERES; j++) {
            if (IntersectSphere(Sphere[j], shadowRay, DEFAULT_TMIN,
                                length(Light[i].position - nearest_hitPos))) {
                inShadow = true;
                break;
            }
        }

        I_local += PhongLighting(normalize(Light[i].position - nearest_hitPos),
                                 nearest_hitNormal, normalize(-ray.d), inShadow,
                                 Material[nearest_hitMatID], Light[i]);
    }

    // Populate output results.
    hitPos = nearest_hitPos;
    hitNormal = nearest_hitNormal;
    k_rg = Material[nearest_hitMatID].k_rg;

    return I_local;
}

// 将RGB颜色转换为HSL
vec3 rgb2hsl(vec3 color) {
    float maxColor = max(color.r, max(color.g, color.b));
    float minColor = min(color.r, min(color.g, color.b));
    float delta = maxColor - minColor;

    float h = 0.0;
    float s = 0.0;
    float l = (maxColor + minColor) / 2.0;

    if (delta != 0.0) {
        s = (l < 0.5) ? (delta / (maxColor + minColor)) : (delta / (2.0 - maxColor - minColor));

        if (maxColor == color.r) {
            h = (color.g - color.b) / delta + (color.g < color.b ? 6.0 : 0.0);
        } else if (maxColor == color.g) {
            h = (color.b - color.r) / delta + 2.0;
        } else {
            h = (color.r - color.g) / delta + 4.0;
        }

        h /= 6.0;
    }

    return vec3(h, s, l);
}

// 将HSL颜色转换为RGB
vec3 hsl2rgb(vec3 hsl) {
    float h = hsl.x;
    float s = hsl.y;
    float l = hsl.z;

    vec3 rgb = vec3(l);

    if (s != 0.0) {
        float q = (l < 0.5) ? (l * (1.0 + s)) : (l + s - l * s);
        float p = 2.0 * l - q;
        float t[3];
        t[0] = h + 1.0 / 3.0;
        t[1] = h;
        t[2] = h - 1.0 / 3.0;

        for (int i = 0; i < 3; i++) {
            if (t[i] < 0.0) t[i] += 1.0;
            if (t[i] > 1.0) t[i] -= 1.0;

            if (t[i] < 1.0 / 6.0) {
                rgb[i] = p + (q - p) * 6.0 * t[i];
            } else if (t[i] < 1.0 / 2.0) {
                rgb[i] = q;
            } else if (t[i] < 2.0 / 3.0) {
                rgb[i] = p + (q - p) * (2.0 / 3.0 - t[i]) * 6.0;
            } else {
                rgb[i] = p;
            }
        }
    }

    return rgb;
}

// 提高给定颜色的饱和度
vec3 increaseSaturation(vec3 color, float increaseFactor) {
    vec3 hsl = rgb2hsl(color);
    hsl.y = clamp(hsl.y + increaseFactor, 0.0, 1.0); // 增加饱和度并限制在0到1之间
    return hsl2rgb(hsl);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {

    initializeColors();
    int temp = 0;
    for (int i = 0; i < NUM_SPHERES; i++) {
        if (temp == 0)
            SphereLevel[i] = 1 + (i % 3);
        else
            SphereLevel[i] = 2 - (i % 3);
        if (i % 3 == 2)
            temp = 1 - temp;
    }

    // 以下所有部分都不需要修改
    // 初始化场景
    InitScene();

    // Scale pixel 2D position such that its y coordinate is in [-1.0, 1.0].
    vec2 pixel_pos = (2.0 * fragCoord.xy - iResolution.xy) / iResolution.y;

    // 调整照相机
    //  vec3 cam_pos = vec3( 1.0, 10.0, 1.0);
    vec3 cam_pos = vec3(2.0f + 4.0f * sin(iTime * PI * 0.2f),
                        5.0f + 2.0f * sin(iTime * PI * 0.3f),
                        2.0f + 4.0f * cos(iTime * PI * 0.2f));
    vec3 cam_lookat = Sphere[0].center - vec3(0.0, Sphere[0].center.y, 0.0);
    vec3 cam_up_vec = vec3(0.0, 1.0, 0.0);
    vec3 cam_z_axis = normalize(cam_pos - cam_lookat);
    vec3 cam_x_axis = normalize(cross(cam_up_vec, cam_z_axis));
    vec3 cam_y_axis = normalize(cross(cam_z_axis, cam_x_axis));

    // Create primary ray.
    float pixel_pos_z = -1.0 / tan(FOVY / 2.0);
    Ray_t pRay;
    pRay.o = cam_pos;
    pRay.d = normalize(pixel_pos.x * cam_x_axis + pixel_pos.y * cam_y_axis +
                       pixel_pos_z * cam_z_axis);

    // Start Ray Tracing.
    // Use iterations to emulate the recursion.

    vec3 I_result = vec3(0.0);
    vec3 compounded_k_rg = vec3(1.0);
    Ray_t nextRay = pRay;

    for (int level = 0; level <= NUM_ITERATIONS; level++) {
        bool hasHit;
        vec3 hitPos, hitNormal, k_rg;

        vec3 I_local = CastRay(nextRay, hasHit, hitPos, hitNormal, k_rg);

        I_result += compounded_k_rg * I_local;

        if (!hasHit)
            break;

        compounded_k_rg *= k_rg;

        nextRay = Ray_t(hitPos, normalize(reflect(nextRay.d, hitNormal)));
    }

    vec3 saturatedColor = increaseSaturation(I_result, 0.2); // 增加10%的饱和度
    fragColor = vec4(saturatedColor, 1.0);
}


#undef mainImage
// --- WLED Effects Studio: made to move with the music (not in the original) ----------------------------------
// the beat swells the picture from its middle and the bass lifts its light, as far as the deck's amount knob says
// (at amount 0 it is the shader as it was)
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 vj_c = 0.5 * iResolution.xy;
    float vj_swell = 1.0 + 0.10 * iAmount * iBeat;
    vj_inner(fragColor, vj_c + (fragCoord - vj_c) / vj_swell);
    fragColor.rgb *= 1.0 + iAmount * (0.5 * iBass - 0.2);
}
