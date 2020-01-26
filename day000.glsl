/*
Day 000 : Hello Shadertoy
26 Jan 2020

So, day 0. I think I want to do a waving hand.
To kinda say hi to everyone, welcome to the project.
*/

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float pi = 3.14159;
    float handWaveAngle = pi/6.0 * sin(iTime*4.0);
    mat2 handRotate = mat2(cos(handWaveAngle), -sin(handWaveAngle),
                           sin(handWaveAngle), cos(handWaveAngle));

    vec2 center = vec2(0.5, 0.4);
    vec2 uv = fragCoord/iResolution.xy;
    vec2 q = (uv - center);
    q = handRotate * q;

    vec3 bgColor = 0.5 + 0.5 * (uv.xyy);
    float hand = 0.13;
    float fingers = 0.06 * cos(atan(q.x,q.y)*4.0 + 58.0*q.x);
    hand += fingers;

    bgColor *= smoothstep(hand, hand+0.005, length(q));
    fragColor = vec4(bgColor, 1.0);
}
