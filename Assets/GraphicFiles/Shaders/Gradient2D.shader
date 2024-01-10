Shader "Gradient2D"
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



// float2 gra( in float2 p )
// {
//     const float e = 0.0002;
//     return float2(map(p + float2(e,0.0))-map(p-vec2(e,0.0)),
//                 map(p + float2(0.0,e))-map(p-float2(0.0,e)))/(2.0*e);
// }



// distance to rounded box


// .x = f(p)
// .yz = ∇f(p) = {∂f(p)/∂x, ∂f(p)/∂y} with ‖∇f(p)‖<1 unfortunatelly
float3 sdgSMin( in float3 a, in float3 b, in float k )
{
    float h = max(k-abs(a.x-b.x),0.0);
    float m = 0.25*h*h/k; // [0 - k/4] for [|a-b|=k - |a-b|=0]
    float n = 0.50*  h/k; // [0 - 1/2] for [|a-b|=k - |a-b|=0]
    return float3( min(a.x,  b.x) - m, 
                 lerp(a.yz, b.yz, (a.x<b.x)?n:1.0-n) );
}

// .x = f(p)
// .yz = ∇f(p) = {∂f(p)/∂x, ∂f(p)/∂y} with ‖∇f(p)‖=1 iff ‖∇a(p)‖=‖∇b(p)‖=1
// float3 sdgMin( in float3 a, in float3 b )
float sdgMin( in float a, in float b )
{
    // return (a.x<b.x) ? a : b;
    return (a<b) ? a : b;
}

// .x = f(p)
// .yz = ∇f(p) = {∂f(p)/∂x, ∂f(p)/∂y} with ‖∇f(p)‖=1
// float3 sdgBox( in float2 p, in float2 b )
float sdgBox( in float2 p, in float2 b )
{
    float2 w = abs(p)-b;
    float2 s = float2(p.x<0.0?-1:1,p.y<0.0?-1:1);
    
    float g = max(w.x,w.y);
	float2  q = max(w,0.0);
    float l = length(q);
    
    // return float3(   (g>0.0)?l   : g, s*((g>0.0)?q/l : ((w.x>w.y) ? float2(0,0):float2(0,1))));
    return(g>0.0)?l:g; 
}

// .x = f(p)
// .yz = ∇f(p) = {∂f(p)/∂x, ∂f(p)/∂y} with ‖∇f(p)‖=1
// float3 sdgSegment( in float2 p, in float2 a, in float2 b )
float sdgSegment( in float2 p, in float2 a, in float2 b )
{
    float2 ba = b-a;
    float2 pa = p-a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    float2  q = pa-h*ba;
    float d = length(q);
    // return float3(d,q/d);
    return d;
}


// float3 map( in float2 p )
void map( in float2 p, out float dg )
{
    float dg1 = sdgBox(p, float2(0.8,0.3));
    float dg2 = sdgSegment( p, float2(-1.0,-0.5), float2(0.7,0.7) ) - float3(0.15,0.0,0.0);

    // float3 dg1 = sdgBox(p, float2(0.8,0.3));
    // float3 dg2 = sdgSegment( p, float2(-1.0,-0.5), float2(0.7,0.7) ) - float3(0.15,0.0,0.0);


  	dg = sdgMin(dg1,dg2);
    //return sdgSMin(dg1,dg2,0.2);
}

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
                
				  // normalized pixel coordinates
    // float2 p = coordinate;
    
    // distance
    // float d = map(p);
    
    // coloring
    // float4 col = (d>0.0) ? float4(col2.x,col2.y, col2.z,1.0) : float4(0.0, 0.0, 0.0, 0.0);
	// col *= 1.0 - exp2(-1.0*abs(d));
	// col *= 0.8 + 0.2*cos(128.0*abs(d));
	// col = lerp( col, float4(0.0, 0.0, 0.0, 1.0), 1.0-smoothstep(0.002,0.005,abs(d)) );


    float px = 1.0;
    float2 p = coordinate;


    // sdf(p) and gradient(sdf(p))
    float dg;
     map(p,dg);
    float d = dg;
    float2  g = float2(dg,dg);
    
    // central differenes based gradient, for validation
    //g = vec2(dFdx(d),dFdy(d))/(2.0/iResolution.y);

	// coloring
    float3 col = (d>0.0) ? float3(0.9,0.6,0.3) : float3(0.4,0.7,0.85);
    col *= 1.0 + float3(0.5*g,0.0);
    col *= 1.0 - 0.5*exp(-16.0*abs(d));
	// col *= 0.9 + 0.1*cos(150.0*d);
	col = lerp( col, float3(1.0, 1.0, 1.0), 1.0-smoothstep(0.001,0.01,abs(d)) );
    

				return float4(col, 1.0);


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

			ENDHLSL
		}
	}
}

























