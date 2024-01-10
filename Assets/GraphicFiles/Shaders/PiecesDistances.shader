Shader "PiecesDistances"
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


float dot2( in float2 v ) { return dot(v,v); }
float msign( in float x ) { return (x>0.0)?1.0:-1.0; }

// https://iquilezles.org/articles/distfunctions2d
float sdCircle( in float2 p, in float2 c, in float r )
{
    return length(p-c) - r;
}

// https://iquilezles.org/articles/distfunctions2d
float sdBox( in float2 p, in float2 c, in float2 b ) 
{
    float2 q = abs(p-c) - b;
    return min(max(q.x,q.y),0.0) + length(max(q,0.0));
}

// https://iquilezles.org/articles/distfunctions2d
float2 sdSqLine( in float2 p, in float2 a, in float2 b )
{
    float2 pa = p-a, ba = b-a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return float2( dot2(pa-ba*h), ba.x*pa.y-ba.y*pa.x );
}

// float sdCrescent(float2 p, float r0, float r1, float d, float sign0, float sign1)
// {
    // float a = (r0*r0 - r1*r1 + d*d) / (2.0 * d);
    // 
    // if( a < r0)
    // {
        // p.y = abs(p.y);
        // float b = sqrt(r0*r0-a*a);
        // float k = p.y*a - p.x*b;
        // float h = min(d*sign0*(d*(p.y-b)-k ),
                      // d*sign1*k);
        // if (h>0.0)
        // {
            // return length(p-float2(a,b));
        // }
    // }
    // 
    // return max(sign0*(length(p          )-r0),
               // sign1*(length(p-float2(d,0))-r1));
// }

// https://iquilezles.org/articles/distfunctions2d
float2 sdSqArc( in float2 p, in float2 a, in float2 b, in float h, float d2min )
{
    float2  ba  = b-a;
    float l   = length(ba);
    float ra2 = h*h + l*l*0.25;

    // recenter
    p -= (a+b)/2.0 + float2(-ba.y,ba.x)*h/l;
    
    float m = ba.y*p.x-ba.x*p.y;
    float n = dot(p,p);
    
    if( abs(h)*abs(ba.x*p.x+ba.y*p.y) < msign(h)*l*0.5*m )
    {
        d2min = min( d2min, n + ra2 - 2.0*sqrt(n*ra2) );
    }

    return float2(d2min, -max(m,ra2-n) );
}


//------------------------------------------------------------

static const int sizekType = 9;
static const float sizekPath = 21;


// SDF of a shape made of a set line and arc segments
// float sdShape( in float2 p, int kType[sizekType], float kPath[sizekPath] )
float sdShape( in float2 p)
{
    int kType[sizekType] = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0};
    float kPath[sizekPath] = {   0.5, 0.5,   
                                 0.5,-0.5,
                                -0.5,-0.5,
                                -0.5, 0.5,
                                 0.5, 0.5,
                                -0.4,-0.8,
                                -0.4,-0.2,
                                 0.0,-0.4, 0.8,
                                -1.0,-0.8,
                                 1.0,1.0};
    int IterationArray = sizekType - 5;

    float2 vb = float2(kPath[0],kPath[1]);
    
    float d = dot2(p-vb);
    int off = 0;
    float s = 1.0;
    for( int i=0; i<IterationArray; i++ )
    {
        float2 va = vb;
        float2 ds;
        
        if( kType[i]==0) // line (x,y)
        {
            vb = float2(kPath[off+2],kPath[off+3]);
            ds = sdSqLine( p, va, vb );
            off += 2;
        }
        else if( kType[i]==1) // arc (x,y,r)
        {
            vb = float2(kPath[off+3],kPath[off+4]);
            ds = sdSqArc(p, va, vb, kPath[off+2], d );
            off += 3;

        }
        
        // in/out test
        float3 cond = float3( p.y>=va.y, p.y<vb.y, ds.y>0.0 );
        if( (cond.x == true && cond.y == true &&  cond.z == true)|| (cond.x != true && cond.y != true && cond.z != true)  ) s*=-1.0;  

        d = min( d, ds.x );
    }
    return s*sqrt(d);
}

// correct both in side and outside
// float sdC( in float2 p )
// {
//     int kType[sizekType] = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0};
//     float kPath[sizekPath] = { -1.0, 1.0,   
//                          0.4, 0.8,
//                          0.4,-0.0,
//                          0.8,-0.0,
//                          0.8,-0.8,
//                         -0.4,-0.8,
//                         -0.4,-0.2,
//                          0.0,-0.4, 0.8,
//                         -1.0,-0.8,
//                          1.0,1.0};
//     return sdShape(p,kType,kPath );
// }


              
// correct outside, incorrect inside
float sdA( in float2 p )
{
    float d = sdCircle( p, float2(-0.4, 0.3), 0.5);
    // d = min(d,sdBox( p, float2( 0.4,-0.4), float2(0.4,0.4) ));
    // d = min(d,sdBox( p, float2( 0.0, 0.0), float2(0.4,0.8) ));
    return d;
}

// correct inside, incorrect outside
float sdB( in float2 p )
{
   float d =     sdBox( p, float2( 0.0, 1.0), float2(2.0,0.2) );
       // d = min(d,sdBox( p, float2( 1.2, 1.0), float2(0.8,1.0) ));
       // d = min(d,sdBox( p, float2( 1.4,-0.3), float2(0.6,0.9) ));
       // d = min(d,sdBox( p, float2( 0.0,-1.0), float2(1.0,0.2) ));
       // d = min(d,sdBox( p, float2(-1.2,-0.8), float2(0.8,0.6) ));
       // d = min(d,sdBox( p, float2(-1.5, 0.3), float2(0.6,0.7) ));
       // d = min(d,sdCrescent( p-float2(-0.4-1.0, 0.3), 1.1, 0.5, 1.0, 1.0, -1.0 ));
    return -d;
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
            
                // distance computations
                float dWrongInterior = sdA(p); // interior modeling
                float dWrongExterior = sdB(p); // exterior modeling
                float dCorrectBoth   = sdShape(p); // boundary modeling
            
                // animation
                float f = frac(TIME/8.0);
                float g = frac(TIME/2.0);
                // float d = (f<0.5) ? ((g<0.5)?dWrongInterior:dCorrectBoth) 
                                  // : ((g<0.5)?dWrongExterior:dCorrectBoth);
                
                float d = dCorrectBoth;
            
                // coloring
                float4 col = (d<0.0) ? float4(1.0,0.0,0.0,1.0) : float4(col2, 1.0);
                // col *= 1.0 - exp(-9.0*abs(d));
                // col *= 1.0 + 0.2*cos(128.0*abs(d));
                // col = lerp( col, float3(1.0,1.0, 1.0), 1.0-smoothstep(0.0,0.015,abs(d)) );

				return float4(col);


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

























