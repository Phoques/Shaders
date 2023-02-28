Shader "Unlit/NewUnlitShader" // This is where the Shader will appear
{
    Properties // This is like a public variable or serialized field. all of these variables will show up in the inspector
    { // Where it says 'Texture' you could call it anything you like, this is what will show in the insector
        //The 'MainTex' are variables like the comment below. 
        _MainTex ("Texture", 2D) = "white" {}
        //e.g _MyFloat ("My Float", float) = 2.0

        //Color as well can be written as R,G,B,A (Which is what these mean)
        //Or X,Y,Z,W (If you look ar the xyz coords in unity they are these colours.)
        _ColorA("ColorA", Color) = (0,0,0,1) // The 4th number is alpha, 0 is invisible, 1 is full visible.
        _ColorB("ColorB", Color) = (1,1,1,1)

    }
    SubShader
    {// You can have multiple subshaders and Passes for more complex shaders.
        //These tags just benefit Unity 
        Tags { "RenderType"="Opaque" }

        //LOD is level of detail, e.g the further away it is the less detailed it is. (andrew thinks LOD is in unity units. e.g if its over 100 units away it sill stop rendering.)
        //But as it is an optimisation thing which we dont need for now.
        //LOD 100


        //This is where the shader will actually exist.
        Pass
        {//CG is C for Graphics as in like coding language. Nvidia has some documentation. HLSL Language is also relevant (Supposedly)
            CGPROGRAM // LOD will determine if we use verticie shading or fragment shading, or no shader at all.

            #pragma vertex vert // This is a verticie / vertex shader. as in will operate on each verticie. the further something is away the more vert calculations run.
            #pragma fragment frag // for every pixel on the screen, every 'frag' is run.
            //^The above are types, like a float int(SORT OF) so Fragment is the function, then you can name the variable, it names the function so below 'frag' is the Fragment function
            //Verts pass into frags

            // C (CG) only passes code once, which means that everything must be in order, you cannot define a function after it is called e.g


            // void function1()
            //{
            //  function2()
            //}
            // void function2()
            //{
            //  function1()
            //}

            //This wouldnt compile because C (CG) doesnt know what function 2 is as it runs only once.

        

            //#include is like 'using' for Unity engine.
            #include "UnityCG.cginc"

            //This is passing through data from the game to the verticies
            struct appdata // Mesh Data
            {
                //This passes in the position of the vertex position in mesh space, relative to its own origin.
                //Anything you tag as position it gets the vertex position
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0; // Where on the texture do I grab the pixel I need for this vertex / fragment
                
                //These are relating to 3d models.
                float3 normal : NORMAL; // Normals are the direction the face / vertici is facing.
                //float4 tangent : TANGENT;
                //float4 color : COLOR
               
            };

            //This is passing through the verticie info to the frag.
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;

                //This is passing through a
                float3 normal : TEXCOORD1;

            };
            //Takes in (# of arguments)

            //UNITY DOCS SL-Datatypes and precision

            //Most accurate but most processing power needed
            
            //float
            //float2
            //float3
            //float4

            //half
            //half1
            //half2
            //half3
            //half4

            //Most performant but least accurate
            
            //fixed
            //fixed2
            //fixed3
            //fixed4

            //Matricies
            //float2x2 (Is like 2 rows of two floats)
            //matricies must match cant do 2x3 for example

            //int
            //int 2-4 (Like the above examples)


            //Sampler 2d is a 2d texture
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _ColorA;
            float4 _ColorB;
            //This is the variable for Color, which is 4 floats!

            //This is a function
            // vtf vert to frag. appdata (Takes in game data)
            //Appdata takes in the vert, then below we give the space information, then frag sends out the colors etc.
            v2f vert (appdata v)
            {//vert to frag, create a variable o, taking in the v, returning the o etc.
                v2f o;

                //This function is taking the normals and moving them out from the mesh by 0.2 (Round things look bigger, but the cube kinda disects.)
                //The v.normal or the 'v' is taking in the value next to appdata.
                //v.vertex.xyz += 0.2 * v.normal;

                // If we were to remove UnityObjectToClipPos it means when you look at the model, it just puts the visual uo flat against the screen
                o.vertex = UnityObjectToClipPos(v.vertex);


                o.uv = v.uv; //TRANSFORM_TEX(v.uv, _MainTex);

                //This is passing in the normal variable (float3 normal : TEXCOORD1)
                //This is local space
                //o.normal = v.normal; 

                //This is like the above, but instead paints each normal assigned colour to a direction, red will always be the top, yellow in the middlesort of relative to camera.
                //this is clip / object space (We think?)
                o.normal = UnityObjectToClipPos(v.normal);


                //mul is matricie something locator, then add the verticie, then the v data / variable.
                //Object space to world space
                //o.normal = mul( (float3x3) unity_ObjectToWorld, v.normal);

                return o;
            }

            //v2f averages out data between verticies, 1 at a top left of a cube, and then 0 at bottom left, means middle of the magnitude is 0.5
            fixed4 frag (v2f i) : SV_Target
            {

                //Swiziling, replacing things with other things (Bit unsure)
                //float var1;
                //float3 var2 = var1.xxx;
                //return float4(i.uv,0,1);

                //Lerp is between two numbers say 5 and 10, if the last number (5, 10, 1) is one, it will be 10, if it is (5,10,0) it will be 5. And if it were (5,10,0.5) it would be 7.5;
                float4 outColor = lerp (_ColorA, _ColorB, i.uv.x );
                return outColor;


                // This relates to (float3 normal : TEXCOORD1)
                //return float4 (i.normal,1);


                //return _ColorA;
                //return float4(i.uv.x, i.uv.y,0,1);
                //The above is saying red on the x axis, green on the y axis, and then zero blue, therefore it creates yellow.
                //If you wanted to determine the x and or y value it scales things so return float4(i.uv.x * 0.5, i.uv.y * 0.5,0,1); means against a cube it
                //would only show half of the full range (Think doubling the cube size, then using the original cube size and where that colour shows is what it displays. makes it darker?)
                //The opposite would increase bloom effects (If you were using the post process)

                //The below will now essentially not work because we are already returning the new variable above.
                // sample the texture, every frag returns a colour (col)
                //fixed4 col = tex2D(_MainTex, i.uv);
               // return col;
            }
            ENDCG
        }
    }
}
