import java.awt.*;
import java.awt.image.*;

/*
// using 12 RGB LEDs
static final int led_num_x = 4;
static final int led_num_y = 4;
static final int leds[][] = new int[][] {
  {1,3}, {0,3}, // Bottom edge, left half
  {0,2}, {0,1}, // Left edge
  {0,0}, {1,0}, {2,0}, {3,0}, // Top edge
  {3,1}, {3,2}, // Right edge
  {3,3}, {2,3}, // Bottom edge, right half
};
*/

// using 25 RGB LEDs
static final int led_num_x = 9;
static final int led_num_y = 6;
static final int leds[][] = new int[][] {
  {3,5}, {2,5}, {1,5}, {0,5}, // Bottom edge, left half
  {0,4}, {0,3}, {0,2}, {0,1}, // Left edge
  {0,0}, {1,0}, {2,0}, {3,0}, {4,0}, {5,0}, {6,0}, {7,0}, {8,0}, // Top edge
  {8,1}, {8,2}, {8,3}, {8,4}, // Right edge
  {8,5}, {7,5}, {6,5}, {5,5}  // Bottom edge, right half

};

static final short fade = 70;

// Preview windows
int window_width, window_height, preview_pixel_width, preview_pixel_height;

int[][] pixelOffset = new int[leds.length][256];
int[] screenData;

// RGB values for each LED
short[][]  ledColor    = new short[leds.length][3];  

//creates object from java library that lets us take screenshots
Robot bot;

// bounds area for screen capture, by default the whole screen
Rectangle dispBounds;

// Monitor Screen information    
GraphicsEnvironment     ge;
GraphicsConfiguration[] gc;
GraphicsDevice[]        gd;



void settings() {
  size(1000, 800);
}


void setup(){
  
  port = new Serial(this, Serial.list()[0],9600);
  /*
  fullScreen();
  background(0);
  noStroke();
  fill(102);
  */
  
  
  
  //size(640, 480); //window size (doesn't matter)
  int[] x = new int[16];
  int[] y = new int[16];
  
  
 


  // ge - Grasphics Environment
  ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
  // gd - Grasphics Device
  gd = ge.getScreenDevices();
  DisplayMode mode = gd[0].getDisplayMode();
  dispBounds = new Rectangle(0, 0, mode.getWidth(), mode.getHeight());

  // Preview windows
  window_width      = mode.getWidth()/5;
  window_height      = mode.getHeight()/5;
  preview_pixel_width     = window_width/led_num_x;
  preview_pixel_height   = window_height/led_num_y;

  //size(window_width, window_height);

  //standard Robot class error check
  try   {
    bot = new Robot(gd[0]);
  }
  catch (AWTException e)  {
    println("Robot class not supported by your system!");
    exit();
  }

  float range, step, start;

  for(int i=0; i<leds.length; i++) { // For each LED...

    // Precompute columns, rows of each sampled point for this LED

    // --- for columns -----
    range = (float)dispBounds.width / led_num_x;
    // we only want 256 samples, and 16*16 = 256
    step  = range / 16.0; 
    start = range * (float)leds[i][0] + step * 0.5;

    for(int col=0; col<16; col++) {
      x[col] = (int)(start + step * (float)col);
    }

    // ----- for rows -----
    range = (float)dispBounds.height / led_num_y;
    step  = range / 16.0;
    start = range * (float)leds[i][1] + step * 0.5;

    for(int row=0; row<16; row++) {
      y[row] = (int)(start + step * (float)row);
    }

    // ---- Store sample locations -----

    // Get offset to each pixel within full screen capture
    for(int row=0; row<16; row++) {
      for(int col=0; col<16; col++) {
        pixelOffset[i][row * 16 + col] = y[row] * dispBounds.width + x[col];
      }
    }

  }

}

void draw(){

  //get screenshot into object "screenshot" of class BufferedImage
  BufferedImage screenshot = bot.createScreenCapture(dispBounds);

  // Pass all the ARGB values of every pixel into an array
  screenData = ((DataBufferInt)screenshot.getRaster().getDataBuffer()).getData();

  for(int i=0; i<leds.length; i++) {  // For each LED...

    int r = 0;
    int g = 0;
    int b = 0;
    for(int o=0; o<256; o++) {              
                    //ARGB variable with 32 int bytes where       
                    int pixel = screenData[ pixelOffset[i][o] ];              
                    r += pixel & 0x00ff0000;       
                    g += pixel & 0x0000ff00;       
                    b += pixel & 0x000000ff;          
                 }          
                ledColor[i][0]  = (short)(r>>24 & 0xff);
    ledColor[i][1]  = (short)(g>>16 & 0xff);
    ledColor[i][2]  = (short)(b>>8  & 0xff);

    float preview_pixel_left  = (float)dispBounds.width  /5 / led_num_x * leds[i][0] ;
    float preview_pixel_top    = (float)dispBounds.height /5 / led_num_y * leds[i][1] ;

    color rgb = color(ledColor[i][0], ledColor[i][1], ledColor[i][2]);
    fill(rgb);  
    rect(preview_pixel_left, preview_pixel_top, preview_pixel_width, preview_pixel_height);

  }

  // Benchmark, how are we doing?
  println(frameRate);

}