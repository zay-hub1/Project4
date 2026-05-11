/**
 *      Author: LaTorres, Maks Zielanski
 *      Course: CPSC 220
 *  Instructor: Prof. Morales
 *     Created: 2026-04-15
 *         Due: 2026-05-10
 *  Assignment: Project 4
 *        File: InteractableSword.pde
 * Description: Sword that can only be interacted with by the player,
 *              bonus object that can increase damage
 */

class Sword extends Interactable {

  public Sword(int x, int y) {
    super();
  }

  public Sword(JSONObject json) {
    super();
  }

  public JSONObject serialize() {
    JSONObject obj = new JSONObject();
    obj.setString("type", "Sword");
    return obj;
  }
  /**
   * Constructor: public Sword()
   * Parameters: int x - X position
   *             int y - Y position
   * Description: creates a sword object item that increases damage
   **/

  public void draw() {
    fill(255, 255, 0);
    rectMode(CENTER);
    rect(0, 0, 25, 25);
    rectMode(CORNER);
  }

  public boolean interact(Player player) {
    player.increaseDamage(2);

    //MAKS
    pickupSound.play();

    return true;
  }
  /**
   * Method: public interact()
   * Parameters: Player player
   * Return: boolean
   * Description: Increases player damage ability when collected
   **/
}
