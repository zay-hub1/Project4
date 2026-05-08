/**
 *      Author: LaTorres
 *      Course: CPSC 220
 *  Instructor: Prof. Morales
 *     Created: 2026-04-15
 *         Due: 2026-05-10
 *  Assignment: Project 4
 *        File: InteractablePotion.pde
 * Description: Potion that can only be interacted with by the player
 */

class Potion extends Interactable { 
  
  Potion(int x, int y) {}
  
  Potion(JSONObject json) {}
  
  public JSONObject serialize() {
    
    JSONObject obj = new JSONObject();
    
    obj.setString("type", "Potion");
    
    return obj;
    
  }
  
  public void draw() {
    
    fill(255, 0, 0);
    
    ellipse(20, 20, 25, 25);
    
  }
  
public boolean interact(Player player) {

    if (player.getHealth() >= 1.0f) {
        return false; // already full
    }

    player.updateHealth(5);
    
    //MAKS
    pickupSound.play();
    
    return true;
  }
}
