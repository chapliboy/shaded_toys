/*
day002: Sphere
28 Jan 2020

So day2, implemented a camera, and rotation of the camera.
Output is super wonky, and it's not entirely clear as to
exactly what is happeneing... Eh. Life.

*/
vec3 rotate3D(vec3 point, vec3 rotation) {
    vec3 r = rotation;
	mat3 rz = mat3(cos(r.z), -sin(r.z), 0,
                   sin(r.z),  cos(r.z), 0,
                   0,         0,        1);
    mat3 ry = mat3( cos(r.y), 0, sin(r.y),
                    0       , 1, 0       ,
                   -sin(r.y), 0, cos(r.y));
    mat3 rx = mat3(1, 0       , 0        ,
                   0, cos(r.x), -sin(r.x),
                   0, sin(r.x),  cos(r.x));
    return rx * ry * rz * point;
}

float sdfSphere(vec3 position, vec3 center, float radius) {
    return distance(position, center) - radius;
}

float distanceField(vec3 position) {
	// sphere 1
    float d = sdfSphere(position, vec3(0.0, 0.0, 0.0), 0.55);
    //return d;
    vec2 moon = mat2(cos(iTime),-sin(iTime),sin(iTime),cos(iTime)) * vec2(1.0,0.0);
    float d1 = sdfSphere(position, vec3(moon.x, 0.1, moon.y), 0.25);
    float d2 = sdfSphere(position, vec3(2.0, 0.0, 0.0), 0.20);

    return min(d2, min(d, d1));
}

vec3 calcNormal( vec3 p ) 
{
    // We calculate the normal by finding the gradient of the field at the
    // point that we are interested in. We can find the gradient by getting
    // the difference in field at that point and a point slighttly away from it.
    const float h = 0.0001;
    return normalize( vec3(
        			       -distanceField(p)+ distanceField(p+vec3(h,0.0,0.0)),
                           -distanceField(p)+ distanceField(p+vec3(0.0,h,0.0)),
                           -distanceField(p)+ distanceField(p+vec3(0.0,0.0,h)) 
    				 ));
}

float raymarch( vec3 direction, vec3 start) {
    // We need to cast out a ray in the given direction, and see which is
    // the closest object that we hit. We then move forward by that distance,
    // and continue the same process. We terminate when we hit an object
    // (distance is very small) or at some predefined distance.
    float far = 15.0;
    float d = 0.0;
    vec3 pos = start;
    for (int i=0; i<100; i++) {
    	float sphereDistance = distanceField(pos);
        pos += sphereDistance*direction;

        d += sphereDistance;
        if (sphereDistance < 0.01) {
        	break;
        }
        if (d > far) {
        	break;
        }
    }
    return d;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalise and set center to origin.
    vec2 p = fragCoord/iResolution.xy;
    p -= 0.5;
    p.y *= iResolution.y/iResolution.x;
    
    vec3 cameraPosition = vec3(0.0, 0.0, -6.0);
    //vec3 cameraOrientation = vec3(0.0, 0.0, 0.0);
    vec3 planePosition = vec3(p, -5.0);
    planePosition = rotate3D(planePosition, vec3(0.0, 0.0, iTime));
    
    vec3 lookingDirection = (planePosition - cameraPosition);
    
    // Rotate light around origin in xz plane
    float angle = iTime;
    vec2 lightPos2D = mat2(cos(angle),-sin(angle),sin(angle),cos(angle))*vec2(0.0,1.0); 
    vec3 lightPoint = normalize(vec3(1.0, 1.0, -1.0));
    vec3 lightFacing = lightPoint - vec3(0.0);
    
    // raymarch to check for colissions.
    float dist = raymarch(lookingDirection, planePosition);
    vec3 color = vec3(0.1);
    if (dist < 15.0) {
        color = vec3(0.2, 0.2, 0.4);
    	vec3 normal = calcNormal(planePosition+ dist*lookingDirection);
        color += 0.3*dot(lightFacing, normal);
    }
    fragColor = vec4(color,1.0);
}
