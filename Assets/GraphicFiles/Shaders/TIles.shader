Shader "Tiles"
{
	Properties
	{
		_TextureChannel0 ("Texture", 2D) = "gray" {}
		_TextureChannel1 ("Texture", 2D) = "gray" {}
		_TextureChannel2 ("Texture", 2D) = "gray" {}
		_TextureChannel3 ("Texture", 2D) = "gray" {}


	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue" = "Transparent" "DisableBatching" ="true" }
		LOD 100

		Pass
		{
		    ZWrite Off
		    Cull off
		    Blend SrcAlpha OneMinusSrcAlpha
		    
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
                  #pragma multi_compile_instancing
			
			#include "UnityCG.cginc"

			struct vertexPoints
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
                  UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct pixel
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

            UNITY_INSTANCING_BUFFER_START(CommonProps)
            UNITY_DEFINE_INSTANCED_PROP(fixed4, _FillColor)
            UNITY_DEFINE_INSTANCED_PROP(float, _AASmoothing)
            UNITY_DEFINE_INSTANCED_PROP(float, _rangeZero_Ten)
            UNITY_DEFINE_INSTANCED_PROP(float, _rangeSOne_One)
            UNITY_DEFINE_INSTANCED_PROP(float, _rangeZoro_OneH)
            UNITY_DEFINE_INSTANCED_PROP(float, _mousePosition_x)
            UNITY_DEFINE_INSTANCED_PROP(float, _mousePosition_y)
            UNITY_INSTANCING_BUFFER_END(CommonProps)		

			pixel vert (vertexPoints v)
			{
				pixel o;
				
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.vertex.xy;
				return o;
			}
            
            sampler2D _TextureChannel0;
            sampler2D _TextureChannel1;
            sampler2D _TextureChannel2;
            sampler2D _TextureChannel3;
  			
            #define PI 3.1415926535897931
            #define TIME _Time.y
  
            float2 mouseCoordinateFunc(float x, float y)
            {
            	return normalize(float2(x,y));
            }

            /////////////////////////////////////////////////////////////////////////////////////////////
            // Default 
            /////////////////////////////////////////////////////////////////////////////////////////////

			#define TWO_PI PI*2
			
			float polygonDistanceField(in float2 pixelPos, in int N) {
			    // N = number of corners
			    float a = atan2(pixelPos.y, pixelPos.x) + PI/2.; // angle
			    float r = TWO_PI/float(N); // ~?
			    // shapping function that modulates the distances
			    float distanceField = cos(floor(0.5 + a/r) * r - a) * length(pixelPos);
			    return distanceField;
			}
			
			float minAngularDifference(in float angleA, in float angleB) {
			    // Ensure input angles are -Ï€ to Ï€
			    angleA = fmod(angleA, TWO_PI);
			    if (angleA>PI) angleA -= TWO_PI;
			    if (angleA<PI) angleA += TWO_PI;
			    angleB = fmod(angleB, TWO_PI);
			    if (angleB>PI) angleB -= TWO_PI;
			    if (angleB<PI) angleB += TWO_PI;
			
			    // Calculate angular difference
			    float angularDiff = abs(angleA - angleB);
			    angularDiff = min(angularDiff, TWO_PI - angularDiff);
			    return angularDiff;
			}
			
			float map(in float value, in float istart, in float istop, in float ostart, in float ostop) {
			    return ostart + (ostop - ostart) * ((value - istart) / (istop - istart));
			}
			float mapAndCap(in float value, in float istart, in float istop, in float ostart, in float ostop) {
			    float v = map(value, istart, istop, ostart, ostop);
			    v = max( min(ostart,ostop), v);
			    v = min( max(ostart,ostop), v);
			    return v;
			}
			
			
			// Matrix Transforms
			float2x2 rotate2d(float angle);


            fixed4 frag (pixel i) : SV_Target
			{
				
				//////////////////////////////////////////////////////////////////////////////////////////////
				///	DEFAULT
				//////////////////////////////////////////////////////////////////////////////////////////////

			    UNITY_SETUP_INSTANCE_ID(i);
			    
		    	float aaSmoothing = UNITY_ACCESS_INSTANCED_PROP(CommonProps, _AASmoothing);
			    fixed4 fillColor = UNITY_ACCESS_INSTANCED_PROP(CommonProps, _FillColor);
			   	float _rangeZero_Ten = UNITY_ACCESS_INSTANCED_PROP(CommonProps,_rangeZero_Ten);
				float _rangeSOne_One = UNITY_ACCESS_INSTANCED_PROP(CommonProps,_rangeSOne_One);
			    float _rangeZoro_OneH = UNITY_ACCESS_INSTANCED_PROP(CommonProps,_rangeZoro_OneH);
                float _mousePosition_x = UNITY_ACCESS_INSTANCED_PROP(CommonProps, _mousePosition_x);
                float _mousePosition_y = UNITY_ACCESS_INSTANCED_PROP(CommonProps, _mousePosition_y);

                float2 mouseCoordinate = mouseCoordinateFunc(_mousePosition_x, _mousePosition_y);
                float2 mouseCoordinateScale = (mouseCoordinate + 1.0)/ float2(2.0,2.0);

                
                float2 coordinate = i.uv;
                
                float2 coordinateBase = i.uv/(float2(2.0, 2.0));
                
                float2 coordinateScale = (coordinate + 1.0 )/ float2(2.0,2.0);
                
                float2 coordinateFull = ceil(coordinateBase);

                //Test Output 
                float3 colBase  = 0.0;
                float3 col2 = float3(coordinate.x + coordinate.y, coordinate.y - coordinate.x, pow(coordinate.x,2.0f));
				//////////////////////////////////////////////////////////////////////////////////////////////
				///	DEFAULT
				//////////////////////////////////////////////////////////////////////////////////////////////
	
                colBase = 0.0;
                //////////////////////////////////////////////////////////////////////////////////////////////
				 float u_time = TIME;
  	

    float3 color = float3(0.2, 0.2, 0.2);
    float t = u_time;

    float2 st = coordinateScale;

    // manip st grid - into 3x3 tiles
    float divisions = 4.;
    float2 mst = st;
    mst *= divisions;

    // give each cell an index number according to position (left-right, down-up)
    float index = 0.;
    float cellx = floor(mst.x);
    float celly = floor(mst.y);
    index += floor(mst.x);
    index += floor(mst.y)*divisions;

    // tile mst
    mst = fmod(mst, 1.);
    
    ////
    // draw square tile
    
    // t = 1.6;
    float tt = t-(sin(cellx*.3)+cos(celly*.3))*.5; //t * .3;
    float squareProgress = fmod(tt*.3, 1.); //0.22; // mouse_n.x; //0.2; //mod(t*.3, 1.);
    float squareEntryProgress = mapAndCap(squareProgress, 0., 0.6, 0., 1.); //mod(t*.7, 1.); //mouse_n.x;
    float squareExitProgress = mapAndCap(squareProgress, 0.9, .999, 0., 1.);
        squareExitProgress = pow(squareExitProgress, 3.);

    float borderProgress = mapAndCap(squareEntryProgress,0.,0.55,0.,1.);
        borderProgress = pow(borderProgress, 1.5);
    float fillProgress = mapAndCap(squareEntryProgress,0.4, 0.9, 0., 1.);
        fillProgress = pow(fillProgress, 4.);

    // MATRIX MANIP
    mst = mst*2.-1.; // centre origin point
    // rotate
    // mst = rotate2d(floor(mod(index,2.))*PI*.5 + PI*.25)*mst;
    mst = mul(rotate2d(cellx*PI*.5 + celly*PI*.5 + PI*.25),mst);

    float d = polygonDistanceField(mst, 4);
    float r = map(squareExitProgress, 0., 1., 0.7, 0.); // 0.5;
    float innerCut = map(fillProgress, 0., 1., 0.9, 0.0001); //0.9; //mouse_n.x;
    float buf = 1.01;
    float shape = smoothstep(r*buf, r, d) - smoothstep(r*innerCut, r*innerCut/buf, d);
    // add smoother shape glow
    buf = 1.5;
    float shape2 = smoothstep(r*buf, r, d) - smoothstep(r*innerCut, r*innerCut/buf, d);
    // shape += shape2*.5;


    // angular mask on square tile
    float sta = atan2(mst.y, mst.x); // st-angle - technically its msta here
    float targetAngle = map(borderProgress, 0., 1., 0., PI)+PI*.251;
    float adiff = minAngularDifference(sta, targetAngle);
    float arange = map(borderProgress, 0., 1., 0., PI);
    float amask = 1. - smoothstep(arange, arange, adiff);
    shape *= amask;


    // color
    // color = vec3(shape) * vec3(0.8, 0.6, 0.8)*2.;
    color = float3(shape, shape, shape) * (float3(1.-st.x, st.y, st.y)+ float3(0.2, 0.2, 0.2));
    // color += vec3(mst.y, 0., mst.x);
    

				return float4(color, (color.x + color.y + color.z)/3.0);	

				// return float4(vPixel/GetWindowResolution(), 0.0, 1.0);


				//(colBase.x + colBase.y + colBase.z)/3.0
                // return float4(coordinateScale, 0.0, 1.0);
				// return float4(right.x, up2.y, 0.0, 1.0);
				// return float4(coordinate3.x, coordinate3.y, 0.0, 1.0);
				// return float4(ro.xy, 0.0, 1.0);

				// float radio = 0.5;
				// float lenghtRadio = length(offset);

    //             if (lenghtRadio < radio)
    //             {
    //             	return float4(1, 0.0, 0.0, 1.0);
    //             }
    //             else
    //             {
    //             	return 0.0;
    //             }


				
			}

			// rotate matrix
float2x2 rotate2d(float angle) {
    float2x2 mat2 = {cos(angle), -sin(angle),
                	sin(angle),  cos(angle) };
                	return mat2;
}


			ENDHLSL
		}
	}
}

























