/*
day001: Sphere
27 Jan 2020

Looking to draw a basic sphere using sdf.
Using parallel projections
*/

float sdfSphere(vec3 position) {
    vec3 center = vec3(0.0);
    float radius = 0.25;
    return distance(position, center) - radius;
}

vec3 raymarch( vec3 direction, vec3 start) {
    // We need to cast out a ray in the given direction, and see which is
    // the closest object that we hit. We then move forward by that distance,
    // and continue the same process. We terminate when we hit an object
    // (distance is very small) or at some predefined distance.
    float far = 20.0;
    float d = 0.0;
    vec3 pos = start;
    for (int i=0; i<100; i++) {
    	float sphereDistance = sdfSphere(pos);
        pos += sphereDistance*direction;

        d += sphereDistance;
        if (d < 0.01) {
        	break;
        }
        if (d > far) {
        	break;
        }
    }
    vec3 col = vec3(0.0);
    if (d < far) {
    	col = vec3(1.0);
    }
	return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalise and set center to origin.
    vec2 p = fragCoord/iResolution.xy;
    p -= 0.5;
    p.x *= iResolution.x/iResolution.y;
    vec2 q = p - vec2(0.0, 0.0);
    
    vec3 planePosition = vec3(0.0, 0.0, -5.0);
    vec3 lookingDirection = vec3(0.0, 0.0, 1.0);
    
    // raymarch to check for colissions.
    vec3 col = raymarch(lookingDirection, vec3(p, planePosition.z));
    fragColor = vec4(col,1.0);
}
