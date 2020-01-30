/*
day004: 
30 Jan 2020

The blending led to this. Simplest emotion I could think of.
Need to work on the lighting in the eyes. Want to make that
a little more "glossy"? Also shadows may help.

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
float sdfEllipsoid(vec3 position, vec3 center, vec3 radii) {
    position -= center;
    float k0 = length(position/radii);
    float k1 = length(position/(radii*radii));
    return k0*(k0-1.0)/k1;
}
float sdfEllipsoidRotated(vec3 position, vec3 center, vec3 radii, vec3 rotation) {
	position -= center;
    position = rotate3D(position, rotation);
    float k0 = length(position/radii);
    float k1 = length(position/(radii*radii));
    return k0*(k0-1.0)/k1;
}

float sdfPlane( vec3 position, vec4 n ) {
    return dot(position, normalize(n.xyz)) + n.w;
}
float sdfRoundBoxRotated(vec3 position, vec3 center, vec3 box, vec3 rotation, float radius) {
    position -= center;
    position = rotate3D(position, rotation);
    vec3 q = abs(position) - box;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - radius;
}

float dot2(vec2 v) {
	return dot(v, v);
}
vec4 sdfJoint3DSphere(vec3 position, vec3 start, vec3 rotation, float len, float angle, float thickness) {
    vec3 p = position;
    float l = len;
    float a = angle;
    float w = thickness;
    p -= start;
    p = rotate3D(p, rotation);

    
    if( abs(a)<0.001 ) {
        return vec4( length(p-vec3(0,clamp(p.y,0.0,l),0))-w, p );
    }
    
    vec2  sc = vec2(sin(a),cos(a));
    float ra = 0.5*l/a;
    p.x -= ra;
    vec2 q = p.xy - 2.0*sc*max(0.0,dot(sc,p.xy));
    float u = abs(ra)-length(q);
    float d2 = (q.y<0.0) ? dot2( q+vec2(ra,0.0) ) : u*u;
    float s = sign(a);
    return vec4( sqrt(d2+p.z*p.z)-w,
               (p.y>0.0) ? s*u : s*sign(-p.x)*(q.x+ra),
               (p.y>0.0) ? atan(s*p.y,-s*p.x)*ra : (s*p.x<0.0)?p.y:l-p.y,
               p.z );
}

float smin(float d1, float d2, float k) {
    //float res = exp2( -k*d1 ) + exp2( -k*d2 );
    //return -log2( res )/k;
    
    float h = max(k-abs(d1-d2),0.0);
    return min(d1, d2) - h*h*0.25/k;
}
float smax(float d1, float d2, float k) {  
    float h = max(k-abs(d1-d2),0.0);
    return max(d1, d2) + h*h*0.25/k;
}

vec4 faceField(vec3 position) {
    float animTime = sin(iTime*1.8);
    float posTiming = (abs(animTime) / animTime) * abs(pow(animTime, 0.4));
    float lagAnimTime = sin((iTime-0.1)*1.8);
    float lagTiming = (abs(lagAnimTime) / lagAnimTime) * abs(pow(lagAnimTime, 0.4));

    position = rotate3D(position, vec3(-0.1+(abs(lagTiming)*0.1), 0.0+(0.13*lagTiming), 0.0));
	vec3 symPosX = vec3(abs(position.x), position.yz);
    float material = 1.0;
    
    float d = sdfSphere(position, vec3(0.0), 0.55);
    float d1 = sdfSphere(position, vec3(0.0, -0.55, -.15), 0.4);
    d = smin(d, d1, 0.5);   
    // brow
    d1 = sdfEllipsoid(position, vec3(0.0, 0.04, -0.35), vec3(0.35, 0.2, 0.2));
    d = smin(d, d1, 0.1);
    // eye socket
    d1 = sdfSphere(symPosX, vec3(0.4, -0.08, -.55), 0.1);
    d = smax(d, -d1, 0.3);
    
    
    // right eyebrow
    d1 = sdfJoint3DSphere(position, vec3(-0.15, 0.03+(0.05*lagTiming), -0.535+(0.015*lagTiming)), vec3(0.5, 0.0, 1.75), 0.2-(0.05*lagTiming), 0.4, 0.01).x;
    d = smin(d, d1, 0.2);
    // left eyebrow
    d1 = sdfJoint3DSphere(position, vec3(0.15, 0.03-(0.05*lagTiming), -0.535-(0.015*lagTiming)), vec3(0.5, 0.0, -1.75), 0.2+(0.05*lagTiming), -0.4, 0.01).x;
    d = smin(d, d1, 0.2);
    
    
    // bottom eyebrow?
    d1 = sdfJoint3DSphere(symPosX, vec3(0.2, -0.25, -0.48), vec3(0.52, 0.0, -1.95), 0.15, -0.4, 0.001).x;
    d = smin(d, d1, 0.22);
    
    
    // nose
    d1 = sdfEllipsoidRotated(position, vec3(0.0, -0.28, -0.55), vec3(0.07, 0.15, 0.1), vec3(3.14159/4.0, 0.0, 0.0));
    d1 = sdfRoundBoxRotated(position, vec3(0.0, -0.28, -0.49), vec3(0.03, 0.19, 0.1), vec3(3.14159/6.0, 0.0, 0.0), 0.02);
    d = smin(d, d1, 0.1);
    
    // eye
    d1 = sdfSphere(symPosX, vec3(0.18, -0.12, -.38), 0.2);
    if (d1 < d) {
    	d = d1;
        material = 2.0;
    }
    // iris
    vec3 irisPos = position;
    irisPos.x += posTiming * 0.06;
    d1 = sdfSphere(irisPos, vec3(0.23, -0.12, -0.545), 0.06);
    if (d1 < d) {
    	d = d1;
        material = 3.0;
    }
    d1 = sdfSphere(irisPos, vec3(-0.23, -0.12, -0.545), 0.06);
    if (d1 < d) {
    	d = d1;
        material = 3.0;
    }
    return vec4(d, material, 0.0, 0.0);
}

vec4 distanceField(vec3 position) {
	vec4 d = faceField(position);
    return d;
}

vec3 calcNormal( vec3 p ) 
{
    // We calculate the normal by finding the gradient of the field at the
    // point that we are interested in. We can find the gradient by getting
    // the difference in field at that point and a point slighttly away from it.
    const float h = 0.0001;
    return normalize( vec3(
        			       -distanceField(p).x+ distanceField(p+vec3(h,0.0,0.0)).x,
                           -distanceField(p).x+ distanceField(p+vec3(0.0,h,0.0)).x,
                           -distanceField(p).x+ distanceField(p+vec3(0.0,0.0,h)).x 
    				 ));
}

vec4 raymarch(vec3 direction, vec3 start) {
    // We need to cast out a ray in the given direction, and see which is
    // the closest object that we hit. We then move forward by that distance,
    // and continue the same process. We terminate when we hit an object
    // (distance is very small) or at some predefined distance.
    float far = 15.0;
    vec3 pos = start;
    float d = 0.0;
    vec4 obj = vec4(0.0, 0.0, 0.0, 0.0);
    for (int i=0; i<100; i++) {
    	obj = distanceField(pos);
        float dist = obj.x;
        pos += dist*direction;
        d += dist;
        if (dist < 0.01) {
        	break;
        }
        if (d > far) {
        	break;
        }
    }
    return vec4(d, obj.yzw);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalise and set center to origin.
    vec2 p = fragCoord/iResolution.xy;
    p -= 0.5;
    p.y *= iResolution.y/iResolution.x;
    
    float mouseX = ((iMouse.x/iResolution.x)-0.5) * 2.0 * 3.14159/2.0;
    mouseX = 0.0;
    vec3 cameraPosition = vec3(0.0, 0.0, -3.0);
    vec3 planePosition = vec3(p, 1.0) + cameraPosition;

    mat2 camRotate = mat2(cos(mouseX), -sin(mouseX), sin(mouseX), cos(mouseX));
    cameraPosition.xz = camRotate * cameraPosition.xz;    
    planePosition.xz = camRotate * planePosition.xz;    
    vec3 lookingDirection = (planePosition - cameraPosition);
    
    // This was fun to sort out, but is it the best way?
    float lightTime = iTime/3.0;
    float multiplier = -1.0 + (step(-0.0, sin(lightTime*3.14159)) *2.0);
    float parabola = (4.0 * fract(lightTime) * (1.0-fract(lightTime)));
    float lightX = multiplier*parabola *-1.2;
    vec3 lightPoint = normalize(vec3(lightX, 1.0, -1.0));
    vec3 lightFacing = lightPoint - vec3(0.0);
    //lightFacing = vec3(1.0, 1.0, -0.3) - vec3(0.0);
    
    // raymarch to check for colissions.
    vec4 obj = raymarch(lookingDirection, planePosition);
    float dist = obj.x;
    vec3 color = vec3(0.01);
    if (dist < 15.0) {
        vec3 normal = calcNormal(planePosition+ dist*lookingDirection);
        float light = dot(lightFacing, normal);
        if (obj.y < 1.5) {
            // skin
        	color = vec3(0.505, 0.205, 0.105);
            color += 0.4* smoothstep(0.3, 1.0, light);
        } else if (obj.y < 2.5) {
            //eyes
        	color = vec3(0.55, 0.55, 0.65);
            color += 0.3 * smoothstep(0.5, 1.0, light);
            color += 0.7 * pow(light, 15.0);
        } else if (obj.y < 3.5) {
        	color = vec3(0.01);
            color += 0.7 * smoothstep(0.4, 1.0, pow(light, 5.0));
        }
    }
    
    // gamma correction
    color = pow( color, vec3(1.0/2.2) );
    fragColor = vec4(color,1.0);
}