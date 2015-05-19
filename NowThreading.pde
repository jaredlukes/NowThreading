//****************
//* REQUIRED LIB *
//****************

import geomerative.*;

import controlP5.*;
ControlP5 cp5;


//***********
//* GLOBALS *
//***********

PShape logo;                               // The Logo
int logoHeight = 460;                      // The Logo height
int logoWidth = 1080;                      // The Logo Width
float hyperbolicSizeMultiplier;            // Max Size
float hyperbolicMultiplier = 3.333;          // Max Size .01
final float GOLDEN = 1.618033988;          // Golden Ratio
final float GOLDEN_ANGLE = GOLDEN*TWO_PI;  // Golden Ratio as Angle
int baseDiameter = 0;                      // The Base Radius of the Data Objects
int baseStroke = 4;                        // The Base stroke of the Data Objects
float basePadding = .1;
float baseMargin = .1;

//************
//* DEV VARS *
//************

CheckBox diameterCheckbox;
CheckBox strokeCheckbox;
CheckBox angleCheckbox;
DropdownList loadList;

boolean isDrawingAxis = false;             // Draw helper Axis?
boolean isControlers = true;               // Draw contorlers

PImage controlBG;

//*************
//* DATA VARS *
//*************

String dataBaseURL = "http://nowthreading.com/api/";
JSONArray recipes;                                    // Recipes holds the data
String[] loadSwitchs = {"threads-01.json", 
                        "threads-02.json", 
                        "threads-03.json"};           // What data do we want to use
int recipesSize;                                      // Commonly used count of recipes


//*****************
//* PENTAGON VARS *
//*****************

int  pentRecurseCount;
int[][] combinationGate;
int fragmentCount = 0;
int alphaAmount = 64;          // Was 102

//super RPolygon

int polyCount = 5;  //MAX 8

float[] pentSize = new float[polyCount];
RPolygon[] ss = new RPolygon[polyCount];  //Original Shapes
RPolygon[] fs;                            //Fragmented Shapes

color sc1 = color(192,216,45);  //actual color
color sc2 = color(0,179,240);  //actual color
color sc3 = color(237,37,92);  //actual color
color sc4 = color(192,216,45);
color sc5 = color(95,99,105);

color[] baseColors = {sc1, sc2, sc3, sc4, sc5, sc1, sc2, sc3};

int growthRate = 5;

//************

//************

//** SETUP **

//************

//************


void setup() {
  if (isControlers) {
    size(logoWidth,logoHeight*2);
  } else {
    size(logoWidth,logoHeight);
  }
  background(255);
  smooth(8);
  frameRate(30);
  
  RG.init(this);
  RG.setPolygonizer(RG.ADAPTATIVE);
  
  logo = loadShape("ThreadLogo.svg");        // Load the logo
  if (isControlers) {
    controlBG = loadImage("d2-placeholder-1920.png");
  }
  initControls();
  
  hyperbolicSizeMultiplier = logoHeight/PI;            // The max size is half the height
  getThreads();                                // Get Data
  
  //setup Pentagon
  int_array_recurse(polyCount);
  fs = new RPolygon[fragmentCount];
  
  randomSize();
  
}

void draw() {
  background(255);    // White wash scene
  shape(logo, 0, 0);  // Draw Logo
  
  
  // Draw Pentagons
  
  growSize();
  
  createFragments();
  
  
  pushMatrix();
  translate(logoHeight/2, logoHeight/2);
  
  for (int i = 0; i < ss.length; i++){
    ss[i].setStroke(false);
    ss[i].draw();
  };

  fs[2].draw();
  for (int i = 0; i < fs.length; i++){
    fs[i].setStroke(false);
    fs[i].draw();
  };
  
  for (int i = 0; i < ss.length; i++){
    ss[i].setStroke(color(255,255,255));
    ss[i].setStrokeAlpha(255);
    ss[i].setStrokeWeight(baseStroke);
    ss[i].setFill(false);
    ss[i].draw();
  };
  popMatrix();
  
  if (isDrawingAxis) { // Draw helper Axis?
    stroke(0);
    line(0,230,1080,230);
    line(230,0,230,460);
    noFill();
    ellipse(230,230,460,460);
  }
  
  // Draw controlers
  if (isControlers) {
    fill(128);
    image(controlBG, 0, logoHeight);
    stroke(0);
    strokeWeight(1);
    line(0, logoHeight, logoWidth, logoHeight);
  }
}

//********
//* DATA *
//********
void getThreads() {
  getThreads(0);
}

void getThreads(int index) {
  JSONObject json;
  JSONObject threadjson;
  json = loadJSONObject(dataBaseURL + loadSwitchs[index]);
  threadjson = json.getJSONObject("threads");
  recipes = threadjson.getJSONArray("recipe");
  for (int i = 0; i < recipes.size(); i++) {
    JSONObject recipe = recipes.getJSONObject(i);
    int id = recipe.getInt("id");
    boolean active = recipe.getBoolean("active");
    String name = recipe.getString("name");
    JSONArray channels = recipe.getJSONArray("channels");
    recipe.setInt("likes", 0);
    recipe.setInt("shares", 0);
    recipe.setInt("comments", 0);
    for (int j = 0; j < channels.size(); j++) {
      JSONObject channel = channels.getJSONObject(j);
      JSONObject likes = channel.getJSONObject("likes");
      recipe.setInt("likes", recipe.getInt("likes") + likes.getInt("weight") * likes.getInt("count"));
      JSONObject shares = channel.getJSONObject("shares");
      recipe.setInt("shares", recipe.getInt("shares") + shares.getInt("weight") * shares.getInt("count"));
      JSONObject comments = channel.getJSONObject("comments");
      recipe.setInt("comments", recipe.getInt("comments") + comments.getInt("weight") * comments.getInt("count"));
    }
  }
  recipesSize = recipes.size();
};

//used to define the scale of the circles
int hyperbolic(int a) {
  return round(atan(a*hyperbolicMultiplier/1000)*hyperbolicSizeMultiplier);
}


//***************
//* CONTROLS!!! *
//***************

void initControls() {
  cp5 = new ControlP5(this);

  int colWidth = 300;
  int textColWidth = 200;
  int x = 25;
  int counter = 0;
  int rowHeight = 50;
  
  cp5
  .setColorLabel(color(255,255,255))
  .setColorActive(color(200,200,200,128))
  .setColorBackground(color(200,200,200,64))
  .setColorCaptionLabel(color(255,255,255))
  .setColorForeground(color(200,200,200,64));
  
  loadList = cp5.addDropdownList("Load list")
    .setPosition(x, (++counter)*rowHeight + logoHeight)
    .setSize(colWidth-textColWidth, 300)
  ;
  loadList.setBackgroundColor(color(200,200,200,64));
  loadList.setItemHeight(15);
  loadList.setBarHeight(15);
  loadList.captionLabel().set("Data Source");
  loadList.captionLabel().style().marginTop = 3;
  loadList.captionLabel().style().marginLeft = 3;
  loadList.valueLabel().style().marginTop = 3;
  for (int i=0;i<loadSwitchs.length;i++) {
    loadList.addItem(loadSwitchs[i], i);
  }
     
  cp5.addSlider("hyperbolicMultiplier")
  .setRange(5, 10)
  .setValue(hyperbolicMultiplier)
  .setPosition(x, (++counter)*rowHeight + logoHeight)
  .setSize(colWidth-textColWidth, 20)
  .setCaptionLabel("Hyperbolic Multiplier (" + hyperbolicMultiplier + ")");
  
  cp5.addSlider("baseDiameter")
  .setRange(0, 1000)
  .setValue(baseDiameter)
  .setPosition(x, (++counter)*rowHeight + logoHeight)
  .setSize(colWidth-textColWidth, 20)
  .setCaptionLabel("Base Diameter (" + baseDiameter + ")");
  
  cp5.addSlider("baseStroke")
  .setRange(0, 20)
  .setValue(baseStroke)
  .setPosition(x, (++counter)*rowHeight + logoHeight)
  .setSize(colWidth-textColWidth, 20)
  .setNumberOfTickMarks(21)
  .setCaptionLabel("Base Stroke (" + baseStroke + ")");
  
  cp5.addSlider("growthRate")
  .setRange(0, 20)
  .setValue(growthRate)
  .setPosition(x, (++counter)*rowHeight + logoHeight)
  .setSize(colWidth-textColWidth, 20)
  .setNumberOfTickMarks(21)
  .setCaptionLabel("Growth Rate (" + growthRate + ")");
  
  cp5.addToggle("isDrawingAxis")
  .setPosition(x, (++counter)*rowHeight + logoHeight)
  .setSize(20, 20)
  .setLabelVisible(false);
  
  cp5.addTextlabel("label")
  .setText("Draw Axis")
  .setPosition(x+25, counter*rowHeight + logoHeight + 5);
  
}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isFrom(loadList)) {
    if (theEvent.isGroup()) {
      // check if the Event was triggered from a ControlGroup
      println("event from group : "+theEvent.getGroup().getValue()+" from "+theEvent.getGroup());
      getThreads(int(theEvent.getGroup().getValue()));
      
    } 
    else if (theEvent.isController()) {
      println("event from controller : "+theEvent.getController().getValue()+" from "+theEvent.getController());
    }
  }
}



void randomSize() {
  for (int i = 0; i < polyCount; i++){
    pentSize[i] = random(100,200);
  }
}
void growSize() {
  for (int i = 0; i < polyCount; i++){
    if (random(1) > .99) {
      pentSize[i] += growthRate;
    }
  }
}


void createFragments() {
  //define the original shapes
  for (int i = 0; i < ss.length; i++){
    ss[i] = new RPolygon(RPPent(pentSize[i]+baseDiameter, GOLDEN_ANGLE*i));
    ss[i].setFill(color(50,50,50));
  };
  
  // iterate over all the possible combinations of the original shapes to make fragments
  for (int i = 0; i < fs.length; i++){
    
    // union then intersect
    boolean isUnion = true;
    fs[i] = new RPolygon();
    for (int u = 0; u < polyCount; u++) {
      if (combinationGate[i][u] == 1) {
        if (isUnion) {
          //union
          fs[i] = fs[i].union(ss[u]);
          
          isUnion = false;
        } else if (fs[i].countContours() != 0) {
          //intersect
            try {
              fs[i] = fs[i].intersection(ss[u]);
            } 
            catch (Exception e) {
              fs[i] = new RPolygon();
            }
        }
      }
    }

    // difference
    for (int j = 0; j < polyCount; j++) {
      if (combinationGate[i][j] == 0 && fs[i].countContours() != 0) {
//          println("i = " +i + " and j = " + j);
          fs[i] = fs[i].diff(ss[j]);
      }
    }
    
    fs[i].setFill(multiply(combinationGate[i]));
// now doing a fixed applied alpha color from applyAlpha();
//    if (int_array_sum(combinationGate[i]) == 1) {
//      fs[i].setAlpha(alphaAmount);
//    } else {
//      fs[i].setAlpha(255);
//    }
  }
}

//**************
//** MULTIPLY **
//**************

color multiply(int[] colors) {
  color tempColor = color(0);
  boolean blending = false;
  for (int i=0; i < colors.length; i++) {
    if (colors[i] == 1) {
      if (blending) {
        tempColor = multiply(tempColor, baseColors[i]);
      } else {
        tempColor = applyAlpha(baseColors[i], alphaAmount);
        blending = true;
      }
    }
  }
  return tempColor;
}


color multiply(color c1, color c2) {
  int[] returnColor = new int[3];
  returnColor[0] = floor(red(c1) * red(c2) / 255);
  returnColor[1] = floor(green(c1) * green(c2) / 255);
  returnColor[2] = floor(blue(c1) * blue(c2) / 255);
  return color(returnColor[0], returnColor[1], returnColor[2]);
}



//***********
//** ALPHA **
//***********

color applyAlpha(color c1, int a) {
  int[] returnColor = new int[3];
  float opacity = float(a) / 255;
  returnColor[0] = floor(red(c1) * opacity + (1-opacity)*255);
  returnColor[1] = floor(green(c1) * opacity + (1-opacity)*255);
  returnColor[2] = floor(blue(c1) * opacity + (1-opacity)*255);
  return color(returnColor[0], returnColor[1], returnColor[2]);
}

//*******************
//** DRAW RPOLYGON **
//*******************

RPolygon RPPent(float d, float startAngle)
{
  return RPPolygon(5, d, d, startAngle);
}

RPolygon RPPolygon(int n, float w, float h, float startAngle)
{
  RPolygon RPtemp = new RPolygon();
  if (n > 2) {
    float angle = TWO_PI/ n;
  
    /* The horizontal "radius" is one half the width;
       The vertical "radius" is one half the height */
    w = w / 2.0;
    h = h / 2.0;
    
    beginShape();
    for (int i = 0; i < n; i++)
    {
      RPtemp.addPoint(cos(startAngle)*w*cos(radians(36)) + w * cos(startAngle + angle * i),
        sin(startAngle)*h*cos(radians(36)) + h * sin(startAngle + angle * i));
    }
    RPtemp.addClose();
  }
  return RPtemp;
}


//************
//** COMBO ***
//************

void int_array_recurse(int depth) {
  int[] int_rest = new int[depth];
  int[] int_active = new int[depth];
  for(int i = 0; i < depth; i++) {
    int_rest[i] = 1;
  }
   pentRecurseCount = 0;
  int_array_recurse(int_active, int_rest);
  combinationGate = new int[ fragmentCount][depth];
  int[] sec_rest = new int[depth];
  int[] sec_active = new int[depth];
   pentRecurseCount = 0;
  int_array_recurse(int_active, int_rest);
}

void int_array_recurse(int[] active, int[] rest) {
    if (int_array_sum(rest) == 0) {
      if(int_array_sum(active) != 0) {
        if ( fragmentCount != 0) {
          combinationGate[ pentRecurseCount] = active;
        }
         pentRecurseCount++;
      } else {
        if ( fragmentCount == 0) {
           fragmentCount =  pentRecurseCount;
        }
      }
    } else {
      int_array_recurse(int_array_add_next(active,rest), int_array_sub_next(rest));
      int_array_recurse(active, int_array_sub_next(rest));
    }
}

int int_array_sum(int[] subject) {
  int sum = 0;
  for (int i = 0; i < subject.length; i++) {
    sum += subject[i];
  }
  return sum;
}

int[] int_array_add_next(int[] subject, int[] next) {
  int int_length = next.length;
  int[] temp = new int[int_length];
  arrayCopy(subject, temp);
  int i = 0;
  while (i < int_length) {
    if (next[i] == 1) {
      temp[i] = 1;
      i = int_length;
    } else {
      i++;
    }
  }
  return temp;
}

int[] int_array_sub_next(int[] next) {
  int int_length = next.length;
  int[] temp = new int[int_length];
  arrayCopy(next, temp);
  int i = 0;
  while (i < int_length) {
    if (temp[i] == 1) {
      temp[i] = 0;
      i = int_length;
    } else {
      i++;
    }
  }
  return temp;
}
