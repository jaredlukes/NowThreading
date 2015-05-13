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
int baseStroke = 5;                        // The Base stroke of the Data Objects
float basePadding = .1;
float baseMargin = .1;

//************
//* DEV VARS *
//************


import controlP5.*;
ControlP5 cp5;

RadioButton designRadioButton;

CheckBox diameterCheckbox;
CheckBox strokeCheckbox;
CheckBox angleCheckbox;
DropdownList loadList;

boolean isDrawingAxis = false;             // Draw helper Axis?
boolean isControlers = true;               // Draw contorlers

PImage controlBG;

int[] designSwitchs = new int[3];          // Defines what design is used to draw the data
int[] diameterSwitchs = new int[3];        // Defines what data is used to drive diameter
int[] strokeSwitchs = new int[3];          // Defines what data is used to drive stroke weight
int[] angleSwitchs = new int[3];           // Defines what data is used to drive angle

//*************
//* DATA VARS *
//*************

String dataBaseURL = "http://nowthreading.com/api/";
JSONArray recipes;                                    // Recipes holds the data
String[] loadSwitchs = {"threads-01.json", 
                        "threads-02.json", 
                        "threads-03.json"};           // What data do we want to use
int recipesSize;                                      // Commonly used count of recipes

//************
//* Arc VARS *
//************

int Stroke_Weight_Denominator = 100; // Makes a stroke thinner
int Circumference_Total = 100;
float diameterGrowthRatio = 1.2;
int arcAlpha = 128;
int ellipseAlpha = 255;

//************
//* EGG VARS *
//************

int eggAlpha = 128;

//************
//* HEX VARS *
//************

int hexCenterSize = 72;                       // Default at 72
int hexAlpha = 140;
int hexStroke = 0;

//*****************
//* CONTROLS VARS *
//*****************

void setup() {
  if (isControlers) {
    size(logoWidth,logoHeight*2, P2D);
  } else {
    size(logoWidth,logoHeight, P2D);
  }
  background(255);
  smooth(8);
  frameRate(30);
  logo = loadShape("ThreadLogo.svg");        // Load the logo
  if (isControlers) {
    controlBG = loadImage("d2-placeholder-1920.png");
    initControls();
    designRadioButton.activate(2);
    diameterCheckbox.activate(0);
    strokeCheckbox.activate(2);
    angleCheckbox.activate(1);
  }
  hyperbolicSizeMultiplier = logoHeight/PI;            // The max size is half the height
  getThreads();                                // Get Data
}

void draw() {
  background(255);    // White wash scene
  shape(logo, 0, 0);  // Draw Logo
  
  if (isDrawingAxis) { // Draw helper Axis?
    stroke(0);
    line(0,230,1080,230);
    line(230,0,230,460);
    noFill();
    ellipse(230,230,460,460);
  }
  
  // Draw arc design
  if(designSwitchs[0] == 1) {
    drawArcDesign();
  }
  
  
  // Draw egg design
  if(designSwitchs[1] == 1) {
    drawEggDesign();
  }
  
  // Draw hex design
  if(designSwitchs[2] == 1) {
    drawHexDesign();
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

//**************
//* ARC DESIGN *
//**************

void drawArcDesign() {
  pushMatrix();
  noFill();
  translate(logoHeight/2, logoHeight/2);
  
  for (int i = 0; i < recipesSize; i++) {
    JSONObject recipe = recipes.getJSONObject(i);
    boolean active = recipe.getBoolean("active");
    
    //first check to see if it's even an active thread
    if (active) {
// TEMP SHUT OFF UNTIL WIRE UP CONTROLS
      int d = recipe.getInt("shares")*diameterSwitchs[0]+recipe.getInt("likes")*diameterSwitchs[1]+recipe.getInt("comments")*diameterSwitchs[2]+baseDiameter; //this will someday be a var defined at run time.
      int w = ceil((recipe.getInt("shares")*strokeSwitchs[0]+recipe.getInt("likes")*strokeSwitchs[1]+recipe.getInt("comments")*strokeSwitchs[2])/Stroke_Weight_Denominator) + baseStroke; //this will someday be a var defined at run time.
      float a = float(recipe.getInt("shares")*angleSwitchs[0]+recipe.getInt("likes")*angleSwitchs[1]+recipe.getInt("comments")*angleSwitchs[2])/float(Circumference_Total); //this will someday be a var defined at run time.
//      int d = recipe.getInt("shares")+baseDiameter; //this will someday be a var defined at run time.
//      int w = ceil((recipe.getInt("comments"))/Stroke_Weight_Denominator) + baseStroke; //this will someday be a var defined at run time.
//      float a = float(recipe.getInt("likes"))/float(Circumference_Total); //this will someday be a var defined at run time.
      
      if (w < 1) {
        w = 1;
      }
      
      if (d != 0 && w != 0 && a > 0) {
        JSONArray colorArray = recipe.getJSONArray("color");
        int[] colors = colorArray.getIntArray();
        color strokeColor = color(colors[0],colors[1], colors[2], arcAlpha); // 4th argument is the alpha amount 0-255
        stroke(strokeColor);
        strokeWeight(w);
        rotate(i*GOLDEN);
        //if arc is over Circumference_Total then draw circle first then larger arc
        int diameterCheck = 0;
        while (a > 1) {
          strokeColor = color(colors[0],colors[1], colors[2], ellipseAlpha);
          stroke(strokeColor);
          int drawDiameter = hyperbolic(d);
          ellipse(-drawDiameter/2, 0, drawDiameter, drawDiameter);
          d = round(float(d) * (diameterGrowthRatio));
          a = a - 1;
        }
        float aAmount = a*TWO_PI;
        strokeColor = color(colors[0],colors[1], colors[2], arcAlpha);
        gradientArc(aAmount, w, hyperbolic(d), strokeColor );
        noFill();
      }
    }
  }
  popMatrix();
}

// draw gradient arc at origin
void gradientArc(float angle, float w, int d, color a) {
  if (d > logoHeight/2) {
   d = logoHeight/2; 
  }
  color newColor = color(red(a),green(a),blue(a),0); 
  float tStep = 1.0/(float(d)*PI);
  float angleStep = angle * tStep;
  float tAngle = 0.0;
  noStroke();
  for (float t = 0.0; t < 1.0; t += tStep) {
    tAngle += angleStep;
    fill(lerpColor(newColor, a, t));
    ellipse(cos(tAngle)*(d/2)-d/2,  sin(tAngle)*(d/2), w, w);
  }
}

//**************
//* EGG DESIGN *
//**************

void drawEggDesign() {
  int d1 = baseDiameter; // radius of the circle (ellipse with equal width and height
  int d2 = baseDiameter; // radius of the ellipse
  int a = 0; // radius of the ellipse
  noStroke();
  pushMatrix();
  translate(logoHeight/2, logoHeight/2);
  for (int i = 0; i < recipesSize; i++) {
    JSONObject recipe = recipes.getJSONObject(i);
    boolean active = recipe.getBoolean("active");
    
    if (active) {  //first check to see if it's even an active thread
      d1 = recipe.getInt("shares")+baseDiameter;
      d2 = recipe.getInt("shares")+recipe.getInt("likes")+recipe.getInt("comments")+baseDiameter;
      a = recipe.getInt("shares");
      if (d1 < 1) { // Make sure radius has a size
        d1 = 1;
      } // End if radius is less than 1
      d1 = hyperbolic(d1);
      if (d2 < 1) { // Make sure radius has a size
        d2 = 1;
      } // End if radius is less than 1
      d2 = hyperbolic(d2);
      JSONArray colorArray = recipe.getJSONArray("color");
      int[] colors = colorArray.getIntArray();
      fill(colors[0],colors[1], colors[2], eggAlpha);
      strokeWeight(1);
      rotate(a);
      ellipse(0,d1/2+basePadding*(d2-d1),d1,d1);
      ellipse(0,(d2+baseMargin*d1)/2,d1+2*basePadding*d2+baseMargin*d1,d2+baseMargin*d1);
      
    } // End if active
    
  } // End Hex Loop
  popMatrix();
}

//**************
//* HEX DESIGN *
//**************

void drawHexDesign() {
  int d = baseDiameter; // radius of the hex
  pushMatrix();
  translate(logoHeight/2, logoHeight/2);
  
  pushMatrix();
  for (int i = 0; i < recipesSize; i++) {
    JSONObject recipe = recipes.getJSONObject(i);
    boolean active = recipe.getBoolean("active");
    
    if (active) {  //first check to see if it's even an active thread
      d = recipe.getInt("shares")+recipe.getInt("likes")+recipe.getInt("comments")+baseDiameter;
      if (d < 1) { // Make sure radius has a size
        d = 1;
      } // End if radius is less than 1
      d = hyperbolic(d);
      JSONArray colorArray = recipe.getJSONArray("color");
      int[] colors = colorArray.getIntArray();
      color fillColor = color(colors[0],colors[1], colors[2], hexAlpha); // 4th argument is the alpha amount 0-255
      fill(fillColor);
      stroke(255);
      strokeWeight(baseStroke);
      rotate(i*GOLDEN);
      hex((d/2)*cos(radians(36)),0,d,0);
      
    } // End if active
    
  } // End Hex Loop
  popMatrix();
  
  //**************
  //* Center Hex *
  //**************
  
  fill(255);
  noStroke();
  rotate(-PI / 2.0);
  hex(0,0,hexCenterSize,0.0);
  popMatrix();
}

void hex(float cx, float cy, float d, float startAngle)
{
  polygon(5, cx, cy, d, d, startAngle);
}

// https://processing.org/tutorials/anatomy/
void polygon(int n, float cx, float cy, float w, float h, float startAngle)
{
  if (n > 2) {
    float angle = TWO_PI/ n;
  
    /* The horizontal "radius" is one half the width;
       The vertical "radius" is one half the height */
    w = w / 2.0;
    h = h / 2.0;
  
    beginShape();
    for (int i = 0; i < n; i++)
    {
      vertex(cx + w * cos(startAngle + angle * i),
        cy + h * sin(startAngle + angle * i));
    }
    endShape(CLOSE);
  }
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

  designRadioButton = cp5.addRadioButton("radioButton")
          .setPosition(x, (++counter)*rowHeight + logoHeight)
          .setSize((colWidth-textColWidth)/3, 20)
          .setItemsPerRow(3)
          .setSpacingColumn(25)
          .addItem("Arc", 1)
          .addItem("Egg", 1)
          .addItem("Pent", 1)
         ;
     
     for(Toggle t:designRadioButton.getItems()) {
       t.captionLabel().setColorBackground(color(200,200,200,64));
       t.captionLabel().style().moveMargin(-7,0,0,-3);
       t.captionLabel().style().movePadding(7,0,0,3);
       t.captionLabel().style().backgroundWidth = 20;
       t.captionLabel().style().backgroundHeight = 13;
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
  
  cp5.addToggle("isDrawingAxis")
  .setPosition(x, (++counter)*rowHeight + logoHeight)
  .setSize(20, 20)
  .setLabelVisible(false);
  
  cp5.addTextlabel("label")
  .setText("Draw Axis")
  .setPosition(x+25, counter*rowHeight + logoHeight + 5);
  
  
// NEW COLUMN
  x = x+colWidth;
  counter = 0;

  
  cp5.addTextlabel("ArcLabel")
  .setText("Arc Controls")
  .setPosition(x, counter*rowHeight + logoHeight + 20);
  
  cp5.addSlider("Circumference_Total")
  .setRange(10, 500)
  .setValue(Circumference_Total)
  .setPosition(x, (++counter)*rowHeight + logoHeight)
  .setSize(colWidth-textColWidth, 20)
  .setCaptionLabel("Circumference Total (" + Circumference_Total + ")");
 
  cp5.addSlider("Stroke_Weight_Denominator")
  .setRange(25, 200)
  .setValue(Stroke_Weight_Denominator)
  .setPosition(x, (++counter)*rowHeight + logoHeight)
  .setSize(colWidth-textColWidth, 20)
  .setCaptionLabel("Stroke Weight Denominator (" + Stroke_Weight_Denominator + ")");
  
  cp5.addSlider("diameterGrowthRatio")
  .setRange(.5, 4.5)
  .setValue(diameterGrowthRatio)
  .setPosition(x, (++counter)*rowHeight + logoHeight)
  .setSize(colWidth-textColWidth, 20)
  .setCaptionLabel("Diameter Growth Ratio (" + diameterGrowthRatio + ")");
  
  diameterCheckbox = cp5.addCheckBox("diameterCheckbox")
                .setPosition(x, (++counter)*rowHeight + logoHeight)
                .setSize(20, 20)
                .setItemsPerRow(3)
                .setSpacingColumn(50)
                .setSpacingRow(20)
                .addItem("d_Shares", 1)
                .addItem("d_Likes", 1)
                .addItem("d_Commments", 1)
                ;

  strokeCheckbox = cp5.addCheckBox("strokeCheckbox")
                .setPosition(x, (++counter)*rowHeight + logoHeight)
                .setSize(20, 20)
                .setItemsPerRow(3)
                .setSpacingColumn(50)
                .setSpacingRow(20)
                .addItem("s_Shares", 1)
                .addItem("s_Likes", 1)
                .addItem("s_Commments", 1)
                ;
  angleCheckbox = cp5.addCheckBox("angleCheckbox")
                .setPosition(x, (++counter)*rowHeight + logoHeight)
                .setSize(20, 20)
                .setItemsPerRow(3)
                .setSpacingColumn(50)
                .setSpacingRow(20)
                .addItem("a_Shares", 1)
                .addItem("a_Likes", 1)
                .addItem("a_Commments", 1)
                ;

  
// NEW COLUMN
  x = x+colWidth;
  counter = 0;
  
  
  cp5.addTextlabel("HexLabel")
  .setText("Pentagon Controls")
  .setPosition(x, counter*rowHeight + logoHeight + 20);
  
  
  cp5.addSlider("hexCenterSize")
  .setRange(1, 144)
  .setValue(hexCenterSize)
  .setPosition(x, (++counter)*rowHeight + logoHeight)
  .setSize(colWidth-textColWidth, 20)
  .setCaptionLabel("Center Size (" + hexCenterSize + ")");
  ;
  
}

void controlEvent(ControlEvent theEvent) {
  if(theEvent.isFrom(designRadioButton)) {
    for(int i=0;i<theEvent.getGroup().getArrayValue().length;i++) {
      designSwitchs[i] = int(theEvent.getGroup().getArrayValue()[i]);
    }
  }
  if (theEvent.isFrom(diameterCheckbox)) {
    int col = 0;
    for (int i=0;i<diameterCheckbox.getArrayValue().length;i++) {
      diameterSwitchs[i] = (int)diameterCheckbox.getArrayValue()[i];
    } 
  }
  if (theEvent.isFrom(strokeCheckbox)) {
    int col = 0;
    for (int i=0;i<strokeCheckbox.getArrayValue().length;i++) {
      strokeSwitchs[i] = (int)strokeCheckbox.getArrayValue()[i];
    } 
  }
  if (theEvent.isFrom(angleCheckbox)) {
    int col = 0;
    for (int i=0;i<angleCheckbox.getArrayValue().length;i++) {
      angleSwitchs[i] = (int)angleCheckbox.getArrayValue()[i];
    } 
  }
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
