vec3 sRGBToLinear(vec3 c) {
    return mix(c / 12.92, pow((c + 0.055) / 1.055, vec3(2.4)), step(vec3(0.04045), c));
}

vec4 TRAIL_COLOR = vec4(sRGBToLinear(iCurrentCursorColor.rgb), iCurrentCursorColor.a);
const float DURATION = 0.1;
const float TRAIL_LENGTH = 0.25;
const float BLUR = 2.0;

const float PI = 3.14159265359;
const float C1_BACK = 1.70158;
const float C2_BACK = C1_BACK * 1.525;
const float C3_BACK = C1_BACK + 1.0;
const float C4_ELASTIC = (2.0 * PI) / 3.0;
const float C5_ELASTIC = (2.0 * PI) / 4.5;
const float SPRING_STIFFNESS = 9.0;
const float SPRING_DAMPING = 0.9;




float ease(float x) {
    return 1.0 - pow(1.0 - x, 3.0);
}









float getSdfRectangle(in vec2 point, in vec2 center, in vec2 halfSize)
{
    vec2 d = abs(point - center) - halfSize;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}


float seg(in vec2 p, in vec2 a, in vec2 b, inout float s, float d) {
    vec2 e = b - a;
    vec2 w = p - a;
    vec2 proj = a + e * clamp(dot(w, e) / dot(e, e), 0.0, 1.0);
    float segd = dot(p - proj, p - proj);
    d = min(d, segd);

    float c0 = step(0.0, p.y - a.y);
    float c1 = 1.0 - step(0.0, p.y - b.y);
    float c2 = 1.0 - step(0.0, e.x * w.y - e.y * w.x);
    float allCond = c0 * c1 * c2;
    float noneCond = (1.0 - c0) * (1.0 - c1) * (1.0 - c2);
    float flip = mix(1.0, -1.0, step(0.5, allCond + noneCond));
    s *= flip;
    return d;
}

float getSdfParallelogram(in vec2 p, in vec2 v0, in vec2 v1, in vec2 v2, in vec2 v3) {
    float s = 1.0;
    float d = dot(p - v0, p - v0);

    d = seg(p, v0, v3, s, d);
    d = seg(p, v1, v0, s, d);
    d = seg(p, v2, v1, s, d);
    d = seg(p, v3, v2, s, d);

    return s * sqrt(d);
}

vec2 normalize(vec2 value, float isPosition) {
    return (value * 2.0 - (iResolution.xy * isPosition)) / iResolution.y;
}

float antialising(float distance) {
	return 1. - smoothstep(0., normalize(vec2(BLUR, BLUR), 0.).x, distance);
}

float getTopVertexFlag(vec2 a, vec2 b) {
    float condition1 = step(b.x, a.x) * step(a.y, b.y);
    float condition2 = step(a.x, b.x) * step(b.y, a.y);

    return 1.0 - max(condition1, condition2);
}

vec2 getRectangleCenter(vec4 rectangle) {
    return vec2(rectangle.x + (rectangle.z / 2.), rectangle.y - (rectangle.w / 2.));
}


void mainImage(out vec4 fragColor, in vec2 fragCoord){
    #if !defined(WEB)
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
    #endif

    vec2 vu = normalize(fragCoord, 1.);
    vec2 offsetFactor = vec2(-.5, 0.5);
    
    vec4 currentCursor = vec4(normalize(iCurrentCursor.xy, 1.), normalize(iCurrentCursor.zw, 0.));
    vec4 previousCursor = vec4(normalize(iPreviousCursor.xy, 1.), normalize(iPreviousCursor.zw, 0.));

    vec2 centerCC = currentCursor.xy - (currentCursor.zw * offsetFactor);
    vec2 centerCP = previousCursor.xy - (previousCursor.zw * offsetFactor);

    float sdfCurrentCursor = getSdfRectangle(vu, centerCC, currentCursor.zw * 0.5);
    
     float lineLength = distance(centerCC, centerCP);
	
     vec4 newColor = vec4(fragColor);
	
     float minDist = currentCursor.w * 1.5;
     float progress = clamp((iTime - iTimeCursorChange) / DURATION, 0.0, 1.0);
     if (lineLength > minDist) {
         float shrinkFactor = ease(progress);

        vec2 delta = abs(centerCC - centerCP);
        float threshold = 0.001;
        float isHorizontal = step(delta.y, threshold);
        float isVertical = step(delta.x, threshold);
        float isStraightMove = max(isHorizontal, isVertical);

        float topVertexFlag = getTopVertexFlag(currentCursor.xy, previousCursor.xy);
        float bottomVertexFlag = 1.0 - topVertexFlag;
        vec2 v0 = vec2(currentCursor.x + currentCursor.z * topVertexFlag, currentCursor.y - currentCursor.w);
        vec2 v1 = vec2(currentCursor.x + currentCursor.z * bottomVertexFlag, currentCursor.y);
        vec2 v2_full = vec2(previousCursor.x + currentCursor.z * bottomVertexFlag, previousCursor.y);
        vec2 v3_full = vec2(previousCursor.x + currentCursor.z * topVertexFlag, previousCursor.y - previousCursor.w);

        vec2 v2_start = mix(v1, v2_full, TRAIL_LENGTH);
        vec2 v3_start = mix(v0, v3_full, TRAIL_LENGTH);
        vec2 v2_anim = mix(v2_start, v1, shrinkFactor);
        vec2 v3_anim = mix(v3_start, v0, shrinkFactor);
        
        float sdfTrail_diag = getSdfParallelogram(vu, v0, v1, v2_anim, v3_anim);

        vec2 min_center = min(centerCP, centerCC);
        vec2 max_center = max(centerCP, centerCC);

        vec2 bBoxSize_full = (max_center - min_center) + currentCursor.zw;
        vec2 bBoxCenter_full = (min_center + max_center) * 0.5;

        vec2 bBoxSize_start = mix(currentCursor.zw, bBoxSize_full, TRAIL_LENGTH);
        vec2 bBoxCenter_start = mix(centerCC, bBoxCenter_full, TRAIL_LENGTH);

        vec2 animSize = mix(bBoxSize_start, currentCursor.zw, shrinkFactor);
        vec2 animCenter = mix(bBoxCenter_start, centerCC, shrinkFactor);

        float sdfTrail_rect = getSdfRectangle(vu, animCenter, animSize * 0.5);

        float sdfTrail = mix(sdfTrail_diag, sdfTrail_rect, isStraightMove);

        vec4 trail = TRAIL_COLOR;
        float trailAlpha = antialising(sdfTrail);
        newColor = mix(newColor, trail, trailAlpha);

        newColor = mix(newColor, fragColor, step(sdfCurrentCursor, 0.));
    }


    fragColor = newColor;
}
