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
  /**
  * Constructor: public Potion()
  * Parameters: int x - X position
  *             int y - Y position
  * Description: creates an interactionable potion object
  **/
  
  public void draw() {
    
    fill(255, 0, 0);
    
    ellipse(20, 20, 25, 25);
    
  }
  /**
  * Method: public draw()
  * Parameters: void
  * Return: void
  * Description: draws the potion object on the screen
  **/
  
public boolean interact(Player player) {

    if (player.getHealth() >= 1.0f) {
        return false; // already full
    }
/**
* Method: public interact()
* Parameters: Player player
* Return: boolean
* Description: restores player health when interacted with
**/

    player.updateHealth(5);
    
    //MAKS
    pickupSound.play();
    
    return true;
  }
}
