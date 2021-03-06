import java.util.*; //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//
import java.util.concurrent.*;

private String globalState;
private String action;
private Object world;

void setup() {
  size(1000, 1000);
  background(255, 255, 255);
  globalState = "initialize";
}

void draw() {
  //Button b = new Button(mouseX, mouseY, 50, 200, 0, 255, "Hello World");
  //b.draw();
  background(#FFFFFF);
  if (globalState.equals("initialize")) {
    promptScreen();
    globalState = "loading";
  } else if (globalState.equals("loading")) {
    if (action != null) {
      clear();  
      if (action.equals("play")) {
        globalState = "choosingWorld";
      } else if (action.equals("create")) {
        globalState = "generating";
      }
      action = null;//reset action here
    } else {
      promptScreen();
      if (checkMouse(500, 250, 300, 100)) {
        fill(#A3A3A3);
        promptButton(500, 250, 300, 100, "Play");
        noFill();
      } else if (checkMouse(500, 550, 300, 100)) {
        fill(#A3A3A3);
        promptButton(500, 550, 300, 100, "Create");
        noFill();
      }
    }
  } else if (globalState.equals("choosingWorld")) {
    selectInput("Choose a map file", "fileSelected");
    globalState = "tempPhaseOut";
    action = null;
  } else if (globalState.equals("running")) {
    try {
      ((World)(world)).display();
      noFill();
      stroke(2);
      if(checkMouse(950,25,100,50)){
        fill(#a3a3a3);  
      }
      promptButton(950,25,100,50,"Forfeit");
    }
    catch(Throwable t) {
      //println(t.getMessage());
      if (t.getMessage().equals("EndGame")) {
        globalState = "EndGame";
      } else if (t.getMessage().equals("Lose")) {
        globalState = "LoseGame";
      } else {
        t.printStackTrace();
      }
    }
  } else if (globalState.equals("EndGame")) {
    if (action == null) {
      promptEndScreen();
      if (checkMouse(500, 250, 300, 100)) {
        fill(#A3A3A3);
        promptButton(500, 250, 300, 100, "Play Again");
        noFill();
      } else if (checkMouse(500, 400, 300, 100)) {
        fill(#A3A3A3);
        promptButton(500, 400, 300, 100, "Play Another");
        noFill();
      } else if (checkMouse(500, 550, 300, 100)) {
        fill(#A3A3A3);
        promptButton(500, 550, 300, 100, "Quit");
        noFill();
      }
    } else {
      if (action.equals("Quit")) {
        globalState = "initialize";
      } else if (action.equals("Another")) {
        globalState = "choosingWorld";
      } else if (action.equals("Again")) {
        globalState = "running";
        ((World)(world)).reload();
      }
      action = null;
    }
  } else if (globalState.equals("LoseGame")) {
    if (action == null) {
      promptLoseScreen();
      if (checkMouse(500, 250, 300, 100)) {
        fill(#a3a3a3);
        promptButton(500, 250, 300, 100, "Try Again");
        noFill();
      } else if (checkMouse(500, 450, 300, 100)) {
        fill(#a3a3a3);
        promptButton(500, 450, 300, 100, "Quit");
        noFill();
      }
    } else {
      if (action.equals("Again")) {
        globalState = "running";
        ((World)(world)).reload();
      } else if (action.equals("Quit")) {
        globalState = "initialize";
      }
      action = null;
    }
  } else if (globalState.equals("generating")) {
    selectInput("Choose a map file to edit, or create a new one", "fileChanged");
    globalState = "tempPhaseOut";
    action = null;
  } else if (globalState.equals("worldMaking")) {
    background(loadImage("./Images/GeneratorGUI.jpg")); //<>// //<>//
    ((Generator)(world)).display();
  } else if (globalState.equals("Forfeit")){
    stroke(2);
    textAlign(CENTER,CENTER);
    textSize(28);
    fill(0);
    text("Are You Sure?", 500, 150);
    noFill();
    if(checkMouse(500,250,300,100)){
      fill(#a3a3a3);  
    }
    promptButton(500,250,300,100,"Return to Game");
    noFill();
    if(checkMouse(500,400,300,100)){
      fill(#a3a3a3);  
    }
    promptButton(500,400,300,100,"Quit");
  }
  //System.out.println(globalState);
}


void changeState(String in) {
  globalState = in;
}

void fileSelected(File selection) {
  if (selection == null) {
    globalState = "initialize";
  } else if (!selection.exists()) {
    println("file does not exist, rerouting to default");
    world = new World();
    globalState = "running";
  } else if (!(selection.getAbsolutePath().contains("MapSaves") && selection.getAbsolutePath().contains(".map") ) ) {
    println("file not in proper format or not in proper location");
    globalState = "initialize";
  } else {
    try {
      //println(selection.getAbsolutePath());
      //println(selection.getCanonicalPath());
      world = new World(selection.getAbsolutePath());
      globalState = "running";
    }
    catch(Exception e) {
      println("done goofed");
      e.printStackTrace();
    }
  }
}

void fileChanged(File selection) {
  if (selection == null) {
    world = new Generator();
    globalState = "worldMaking";
  } else if (!selection.exists()) {
    if (!selection.getAbsolutePath().contains(".map") || !selection.getAbsolutePath().contains("MapSaves")) {
      globalState = "initialize";
      return;
    }
    File f = new File(selection.getAbsolutePath());
    f.getParentFile().mkdirs();
    try {
      f.createNewFile();
      world = new Generator(selection.getAbsolutePath());
    }
    catch(IOException e) {
      println("What is going on?");
    }
    globalState = "worldMaking";
    //f.close();
    //println(action);
  } else {
    if (!selection.getAbsolutePath().contains(".map") || !selection.getAbsolutePath().contains("MapSaves")) {
      globalState = "initialize";
      return;
    }
    world = new Generator(selection.getAbsolutePath());
    globalState = "worldMaking";
    //println(action);
  }
}
void promptButton(float xCor, float yCor, float len, float ht, String txt) {
  rectMode(CENTER);
  textMode(CENTER);
  textAlign(CENTER);
  textSize(24);
  rect(xCor, yCor, len, ht);
  fill(0);
  text(txt, xCor, yCor);
  noFill();
  textSize(12);
}
void promptScreen() {
  fill(255);
  promptButton(500, 250, 300, 100, "Play");
  promptButton(500, 550, 300, 100, "Create");
}

void promptEndScreen() {
  //fill(255);
  stroke(2);
  noFill();
  textMode(CENTER);
  textAlign(CENTER);
  textSize(28);
  text("You Win!", 500, 150);
  promptButton(500, 250, 300, 100, "Play Again");
  promptButton(500, 400, 300, 100, "Play Another");
  promptButton(500, 550, 300, 100, "Quit");
}

void promptLoseScreen() {
  stroke(2);
  noFill();
  textMode(CENTER);
  textAlign(CENTER);
  textSize(28);
  text("You Lost!", 500, 150);
  promptButton(500, 250, 300, 100, "Try Again");
  promptButton(500, 450, 300, 100, "Quit");
}

//<>//
void mouseClicked() {
  //System.out.println(globalState);
  if (globalState.equals("loading")) {
    if (checkMouse(500, 250, 300, 100)) {
      action = "play";
    } else if (checkMouse(500, 550, 300, 100)) {
      action = "create";
    }
  } else if (globalState.equals("worldMaking")) {
    ((Generator)(world)).flashTriggered();
  } else if (globalState.equals("EndGame")) {
    if (checkMouse(500, 250, 300, 100)) {
      action = "Again";
    } else if (checkMouse(500, 400, 300, 100)) {
      action = "Another";
    } else if (checkMouse(500, 550, 300, 100)) {
      action = "Quit";
    }
  } else if (globalState.equals("LoseGame")) {
    if (checkMouse(500, 250, 300, 100)) {
      action = "Again";
    } else if (checkMouse(500, 450, 300, 100)) {
      action = "Quit";
    }
  } else if (globalState.equals("running")){
    if(checkMouse(950,25,100,50)){
      globalState = "Forfeit";  
    }
  } else if (globalState.equals("Forfeit")){
    if(checkMouse(500,250,300,100)){
      globalState = "running";  
    }else if(checkMouse(500,400,300,100)){
      globalState = "initialize";
      action = null;
    }
  }
}
//<>//
void mousePressed() {
  if (world instanceof Generator && globalState.equals("worldMaking")) {
    if (((Generator)(world)).hasBlock()) {
      ((Generator)(world)).dropBlock();
    } else {
      ((Generator)(world)).chooseBlock();
    }
  }
}


void keyTyped() {
  if (world instanceof World) {
    ((World)(world)).handleUserInput(""+key);
  }
}

public boolean checkMouse(double xCor, double yCor, double wid, double ht) {
  //System.out.println("testing");
  if (mouseX < xCor + wid / 2 && mouseX > xCor - wid / 2) {
    if (mouseY < yCor + ht / 2 && mouseY > yCor - ht / 2) {
      return true;
    }
  }
  return false;
}