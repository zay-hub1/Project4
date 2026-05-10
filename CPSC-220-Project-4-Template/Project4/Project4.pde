/**
 *      Author: Prof. Morales
 *      Course: CPSC 220
 *  Instructor: Prof. Morales
 *     Created: 2026-04-15
 *         Due: 2026-05-10
 *  Assignment: Project 4
 *        File: Project4.pde
 * Description: A dungeon crawler game
 */
import java.io.File;
import processing.sound.*;

SoundFile music;
SoundFile attackSound;
SoundFile pickupSound;
SoundFile hitSound;

Scene scene;
String fileName;

/**
 *      Method: setup()
 *  Parameters: void
 *      Return: void
 * Description: Constructs a scene from JSON
 *              save data or in a random state
 */

void setup() {
  fullScreen(P2D);
  pixelDensity(1);
  fileName = sketchPath("data/save.json");
  File file = new File(fileName);

  if (file.exists()) {
    JSONObject data = loadJSONObject(fileName);
    scene = new Scene(data);
  } else {
    scene = new Scene();
    JSONObject data = scene.serialize();
    file.getParentFile().mkdirs();
    saveJSONObject(data, fileName);
  }
  music = new SoundFile(this, "TITMH.mp3");
  attackSound = new SoundFile(this, "PlayerStrike.wav");
  pickupSound = new SoundFile(this, "ItemPickup.wav");
  hitSound = new SoundFile(this, "PlayerDamaged.wav");

  music.loop();
}

/**
 *      Method: draw()
 *  Parameters: void
 *      Return: void
 * Description: Draws the scene and all objects
 *              within it, additionally performing
 *              logic for the main game loop
 */

void draw() {
  background(0);

  fill(255);
  textSize(16);
  text("WASD = Move | SPACE = Attack", 20, 30);
  text("Kill all enemies to unlock doors", 20, 50);

  if (scene.tryTurn()) {
    // Save the state of the scene
    saveJSONObject(scene.serialize(), fileName);
  }

  scene.draw();
}

/**
 *      Method: keyPressed()
 *  Parameters: void
 *      Return: void
 * Description: Passes key press events to the scene
 */

void keyPressed() {
  scene.keyPressed();
}

/**
 *      Method: keyReleased()
 *  Parameters: void
 *      Return: void
 * Description: Passes key release events to the scene
 */

void keyReleased() {
  scene.keyReleased();
}

// Make potions do a little more.

// Add sound for health
