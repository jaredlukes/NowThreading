String baseURL = "http://nowthreading.com/api/";
JSONObject json;
JSONObject threadjson;
JSONArray recipes;
String date;
int strokeWeightDenominator = 20; // Makes a stroke thinner
int circumferenceTotal = 14;
int dashLength = 10;
int dashLine = 2;

void setup() {
  getThreads();
  size(800, 800, P2D);
  smooth(8);
  noLoop();
};

void draw() {
  background(255, 255, 255);
  
  // draw axis
  drawAxis();
  
  // draw threads
  pushMatrix();
  noFill();
  translate(400, 400);
  int recipesSize = recipes.size();
  float threadAngle = 360/recipesSize;
  println("Thread angle " +threadAngle + " and thread count " + recipesSize);
  for (int i = 0; i < recipesSize; i++) {
    JSONObject recipe = recipes.getJSONObject(i);
    boolean active = recipe.getBoolean("active");
    
    //first check to see if it's even an active thread
    if (active) {
      int d = recipe.getInt("shares"); //this will someday be a var defined at run time.
      int w = recipe.getInt("comments")/strokeWeightDenominator; //this will someday be a var defined at run time.
      float a = float(recipe.getInt("likes"))/float(circumferenceTotal); //this will someday be a var defined at run time.
      println(a);
      // for the time being, we can't go over one loop, lame but will fix.
      if (a > 1) {
       a = 1; 
      }
      JSONArray colorArray = recipe.getJSONArray("color");
      int[] colors = colorArray.getIntArray();
      color strokeColor = color(colors[0],colors[1], colors[2], 125); // 4th argument is the alpha amount 0-255
      stroke(strokeColor);
      strokeWeight(w);
      rotate(radians(threadAngle));
      
      //just draw a circle for now ...
      //ellipse(0, -d/2, d, d);
      
      //want to draw an arc ...
      float aAmount = a*TWO_PI;
      println(aAmount + " " + a);
      //ellipseMode(CORNER);
      //QUARTER_PI
      //HALF_PI
      //PI
      //
      arc(-d/2, 0, d, d, 0, aAmount);
      
    }
  }
  popMatrix();
};

// draw axis
void drawAxis() {
  stroke(128); // a gray scale value from 0-255
  int dashX = round(width/dashLength);
  int dashY = round(height/dashLength);
  for (int x = 0; x < dashX; x++) {
    line((x*dashLength),400,(x*dashLength)+dashLine,400);
  }
  for (int y = 0; y < dashY; y++) {
    line(400,(y*dashLength),400,(y*dashLength)+dashLine);
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
