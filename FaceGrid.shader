// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/FaceGrid"
{
    Properties
    {
        _Color ("Color", Color) = (0.098, 0.773, 0.980, 1)
        _GlowColor ("Glow Color", Color) = (1, 1, 1, 1)
        //_Scale ("Scale", Int) = 2
        _Rows ("Rows", Int) = 10
        _Columns ("Columns", Int) = 10
        _Thickness ("Thickness", Float) = 1
        _Width ("Width", Float) = 10.0
        _Height ("Height", Float) = 10.0
        _xMin ("xMin", Float) = 0.0
        _yMin ("yMin", Float) = 0.0
        _MainTex ("Texture", 2D) = "white" {}
    }
        SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            //#pragma surface surf Standard fullforwardshadows alpha
            #pragma vertex vert            
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            float4 _Color;
            float4 _GlowColor;
            //int _Scale;
            int _Rows;
            int _Columns;
            float _Thickness;
            
            sampler2D _MainTex;
            
            float _Width;
            float _Height;
            float _xMin;
            float _yMin;

            

            float4 _MainTex_ST;
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : POSITION;
                float2 uv : TEXCOORD0;
                float4 modelPos : TEXCOORD1;
            };

            float3 rotateY(float _angle, float3 _point)
            {
                float3x3 rotMatrix = float3x3(
                    cos(_angle),    0.0f,   sin(_angle),
                    0.0f,            1.0f,   0.0f,
                    -sin(_angle),   0.0f,   cos(_angle)
                );

                return mul(rotMatrix, _point);
            }

            float3 rotateX(float _angle, float3 _point)
            {
                float3x3 rotMatrix = float3x3(
                    1.0f, 0.0f, 0.0f,
                    0.0f, cos(_angle), -sin(_angle),
                    0.0f, sin(_angle), cos(_angle)
                    );

                return mul(rotMatrix, _point);
            }

            v2f vert (appdata_base v)
            {
                v2f o;
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                // Apply the rotation to the face
                if (v.vertex.z > 0.1)
                {
                    float Pi = 3.1415f;
                    int ms = _Time * 1000;
                    int MS_IN_FACE_TURN = 400;
                    int turnPercent = ms % MS_IN_FACE_TURN;
                    float angle = sin(float(turnPercent) / float(MS_IN_FACE_TURN) * 2.0 * Pi) * Pi / 8.0f;
                    float nodAngle = sin(float(turnPercent) / float(MS_IN_FACE_TURN) * Pi) * Pi / 36.0f;
                    float4 rotVert = float4(rotateY(angle, v.vertex.xyz), 1);
                    rotVert = float4(rotateX(nodAngle, rotVert.xyz), 1);
                    o.modelPos = v.vertex;
                    o.pos = UnityObjectToClipPos(rotVert);
                }
                else
                // Draw the plane as normal
                {
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.modelPos = v.vertex;
                }

                return o;
            }

            fixed4 frag(v2f i) : SV_Target{
                //-----------------------------------------
                // Setup the grid in object space
                // Unitize the X and Y positions
                float uDistX = (i.modelPos.x - _xMin) / _Width;
                float uDistY = (i.modelPos.y - _yMin) / _Height;
                // Find the nearest row
                float rowDist = 1.0 / float(_Rows);
                int minRows = round(uDistY / rowDist);
                // Find the distance to nearest row
                float rowH = minRows * rowDist;
                float distRow = abs(uDistY - rowH);
                // Find the nearest column
                float colDist = 1.0 / float(_Columns);
                int minCols = round(uDistX / colDist);
                // Find the distance to the nearest column
                float colW = minCols * colDist;
                float distCol = abs(uDistX - colW);
                //--------------------------------------------
                // Calculate bubbles
                float Pi = 3.1415f;
                float bubbleHeight = _Thickness * 2.0;
                float bubbleWidth = bubbleHeight * 50.0;
                uint ms = _Time * 1000;
                // Calculate row bubble
                int msInRowBubble = 750;
                int rowBubProgress = ms % msInRowBubble;
                float rowBubPos = float(rowBubProgress) / float(msInRowBubble);
                float startXPos = 5.0 * sin(minRows * 24) * sin(13);
                float BubXPos = cos(startXPos + rowBubPos * Pi / 2.0f);                
                float rowBubDist = abs(uDistX - BubXPos);
                float bubWidthPercent = saturate(rowBubDist / (bubbleWidth * 2.0));
                float rowBubHeight = 0.0007 * cos(bubWidthPercent * Pi);
                // Calculate col bubble
                uint msInColBubble = 1000;
                uint colBubProgress = ms % msInColBubble;
                float colBubPos = float(colBubProgress) / float(msInColBubble);
                float startYPos = 5.0 * sin(minCols * 10) * sin(8);
                float BubYPos = 0.8 + 0.75 * sin(startYPos + colBubPos * 2.0 * Pi);
                float colBubDist = abs(uDistY - BubYPos);
                float bubHeightPercent = saturate(colBubDist / (bubbleWidth * 4.0));
                float colBubHeight = 0.0007 * cos(bubHeightPercent * Pi);
                //-----------------------------------------------------------
                // Draw the Grid
                if ( distRow < rowBubHeight && rowBubDist < bubbleWidth )       // Check if the pixel is inside one of the row highlights
                {
                    // Draw the pixel in the highlight
                    if (rowBubDist < bubbleWidth / 20.0)                        // Check if the pixel is in the pure specular part of the highlight
                    {
                        return float4(1, 1, 1, 1);                              // Set the pixel to white
                    }
                    return _GlowColor;                                          // Set the pixel to the Glow Color
                }
                // Draw the highlights on the columns
                else if (distCol < colBubHeight / 2.0f && colBubDist < bubbleWidth * 4.0f)      // Check if the pixel is inside one of the column highlights
                {
                    // Draw the pixel in the highlight
                    if (colBubDist < bubbleWidth / 10.0)                        // Check if the pixel is in the pure specular part of the highlight
                    {
                        return float4(1, 1, 1, 1);                              // Set the pixel to white
                    }
                    return _GlowColor;// *(1 - bubHeightPercent) + _Color * bubHeightPercent;
                }
                // Draw the grid
                else if (distRow < _Thickness || distCol < _Thickness / 2.0f)
                {
                    return _Color;
                }
                // Discard everything else
                else
                {
                    discard;
                }
                //------------------------------------------------------
                fixed4 texcol = tex2D(_MainTex, i.uv);
                return texcol * _Color;
            }
            ENDCG
        }
    }
}
