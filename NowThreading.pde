import controlP5.*;
ControlP5 cp5;

CheckBox diameterCheckbox;

String baseURL = "http://nowthreading.com/api/";
JSONObject json;
JSONObject threadjson;
JSONArray recipes;
String date;
int Stroke_Weight_Denominator = 20; // Makes a stroke thinner
int Circumference_Total = 12;
int dashLength = 6;
int dashLine = 1;
int dashAlpha = 128;
int dashWeight = 1;
float diameterGrothRatio = 1.2;
int arcAlpha = 128;
int ellipseAlpha = 255;
int[] diameterSwitchs = new int[3];

void setup() {
  getThreads();
  size(960, 720, P2D);
  smooth(8);
  frameRate(30);
  background(255, 255, 255);
  //noLoop();
  initControls();
};

void draw() {
  background(255, 255, 255);
  
  // draw axis
  drawAxis();
  
  // draw threads
  pushMatrix();
  noFill();
  translate(400, height/2);
  int recipesSize = recipes.size();
  float threadAngle = 360/recipesSize;
//  println("Thread angle " +threadAngle + " and thread count " + recipesSize);
  for (int i = 0; i < recipesSize; i++) {
    JSONObject recipe = recipes.getJSONObject(i);
    boolean active = recipe.getBoolean("active");
    
    //first check to see if it's even an active thread
    if (active) {
      int d = recipe.getInt("shares")*diameterSwitchs[0]+recipe.getInt("likes")*diameterSwitchs[1]+recipe.getInt("comments")*diameterSwitchs[2]; //this will someday be a var defined at run time.
      int w = ceil(recipe.getInt("comments")/Stroke_Weight_Denominator); //this will someday be a var defined at run time.
      float a = float(recipe.getInt("likes"))/float(Circumference_Total); //this will someday be a var defined at run time.
      // for the time being, we can't go over one loop, lame but will fix.
      
      if (d != 0 && w != 0 && a > 0) {
        JSONArray colorArray = recipe.getJSONArray("color");
        int[] colors = colorArray.getIntArray();
        color strokeColor = color(colors[0],colors[1], colors[2], arcAlpha); // 4th argument is the alpha amount 0-255
        stroke(strokeColor);
        strokeWeight(w);
        rotate(radians(threadAngle));
        
        //just draw a circle for now ...
        //ellipse(0, -d/2, d, d);
        
        //want to draw an arc ...
        //if arc is over Circumference_Total then draw circle first then larger arc
        while (a > 1) {
          strokeColor = color(colors[0],colors[1], colors[2], ellipseAlpha);
          stroke(strokeColor);
          ellipse(-d/2, 0, d, d);
          d = round(float(d) * (diameterGrothRatio));
          a = a - 1;
        }
        float aAmount = a*TWO_PI;
        strokeColor = color(colors[0],colors[1], colors[2], arcAlpha);
        gradientArc(aAmount, w, d, strokeColor );
        noFill();
      }
    }
  }
  popMatrix();
};

// draw axis
void drawAxis() {
  strokeWeight(dashWeight);
  stroke(dashAlpha); // a gray scale value from 0-255
  int dashX = round(width/dashLength);
  int dashY = round(height/dashLength);
  for (int x = 0; x < dashX; x++) {
    line((x*dashLength),height/2,(x*dashLength)+dashLine,height/2);
  }
  for (int y = 0; y < dashY; y++) {
    line(400,(y*dashLength),400,(y*dashLength)+dashLine);
  }
}

// draw gradient arc at origin
void gradientArc(float angle, float w, int d, color a) {
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

void getThreads() {
  json = loadJSONObject(baseURL + "threads.json");
  threadjson = json.getJSONObject("threads");
  date = threadjson.getString("date");
  recipes = threadjson.getJSONArray("recipe");
  println("The Thread date is " + date + " and there are " + recipes.size() + " recipes.");
  for (int i = 0; i < recipes.size(); i++) {
    JSONObject recipe = recipes.getJSONObject(i);
    
    int id = recipe.getInt("id");
    boolean active = recipe.getBoolean("active");
    String name = recipe.getString("name");
    JSONArray channels = recipe.getJSONArray("channels");
    println(id + ", " + active + ", " + name + " and there are " + channels.size() + " channels.");
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
    println(recipe.getInt("likes") + " " + recipe.getInt("shares") + " " + recipe.getInt("comments"));
  }
};

void initControls() {
  cp5 = new ControlP5(this);

  int colWidth = 200;
  int textColWidth = 100;
  int x = width - colWidth - 10;
  int counter = 0;
  int rowHeight = 50;
  
  cp5.addSlider("Circumference_Total")
  .setRange(1, 25)
  .setValue(Circumference_Total)
  .setPosition(x, (++counter)*rowHeight + 10)
  .setSize(colWidth-textColWidth, 20)
  .setColorLabel(color(0));
  
  cp5.addSlider("diameterGrothRatio")
  .setRange(.5, 4.5)
  .setValue(diameterGrothRatio)
  .setPosition(x, (++counter)*rowHeight + 10)
  .setSize(colWidth-textColWidth, 20)
  .setColorLabel(color(0));
  
  cp5.addSlider("Stroke_Weight_Denominator")
  .setRange(1, 50)
  .setValue(Stroke_Weight_Denominator)
  .setPosition(x, (++counter)*rowHeight + 10)
  .setSize(colWidth-textColWidth, 20)
  .setColorLabel(color(0));
  
  cp5.addSlider("dashLength")
  .setRange(1, 50)
  .setValue(dashLength)
  .setPosition(x, (++counter)*rowHeight + 10)
  .setSize(colWidth-textColWidth, 20)
  .setColorLabel(color(0));
  
  cp5.addSlider("dashLine")
  .setRange(1, 50)
  .setValue(dashLine)
  .setPosition(x, (++counter)*rowHeight + 10)
  .setSize(colWidth-textColWidth, 20)
  .setColorLabel(color(0));
  
  cp5.addSlider("dashAlpha")
  .setRange(0, 255)
  .setValue(dashAlpha)
  .setPosition(x, (++counter)*rowHeight + 10)
  .setSize(colWidth-textColWidth, 20)
  .setColorLabel(color(0));
  
  cp5.addSlider("dashWeight")
  .setRange(1, 10)
  .setValue(dashWeight)
  .setPosition(x, (++counter)*rowHeight + 10)
  .setSize(colWidth-textColWidth, 20)
  .setColorLabel(color(0));
  
  diameterCheckbox = cp5.addCheckBox("diameterCheckbox")
                .setPosition(x, (++counter)*rowHeight + 10)
                .setColorForeground(color(120))
                .setColorActive(color(255,0,0))
                .setColorLabel(color(0))
                .setSize(20, 20)
                .setItemsPerRow(3)
                .setSpacingColumn(40)
                .setSpacingRow(20)
                .addItem("Shares", 1)
                .addItem("Likes", 1)
                .addItem("Commments", 1)
                ;
}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isFrom(diameterCheckbox)) {
  print("got an event from "+diameterCheckbox.getName()+"\t\n");
  println(diameterCheckbox.getArrayValue());
  int col = 0;
  for (int i=0;i<diameterCheckbox.getArrayValue().length;i++) {
    diameterSwitchs[i] = (int)diameterCheckbox.getArrayValue()[i];
    print(diameterSwitchs[i]);
  }
  println();    
  }
}
