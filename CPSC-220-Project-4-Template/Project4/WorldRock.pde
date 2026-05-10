/**
 *      Author: LaTorres
 *      Course: CPSC 220
 *  Instructor: Prof. Morales
 *     Created: 2026-04-15
 *         Due: 2026-05-10
 *  Assignment: Project 4
 *        File: WorldRock.pde
 * Description: Rock(object) that exists within the scene
 */


class Rock extends WorldObject {
  /**
   * Constructor: public Rock()
   * Parameters: int x - X position
   *             int y - Y position
   * Description: Creates obstacle object
   **/
  private int x;
  private int y;

  public Rock(int x, int y) {
    this.x = x;
    this.y = y;
  }

  Rock(JSONObject json) {
    this.x = json.getInt("x");
    this.y = json.getInt("y");
  }

  public JSONObject serialize() {
    JSONObject obj = new JSONObject();
    obj.setString("type", "Rock");
    obj.setInt("x", x);
    obj.setInt("y", y);
    return obj;
  }

  /**
   * Method: public serialize()
   * Description: Converts the rock object into JSON format
   **/

  public void draw() {
    fill(120, 120, 120);
    rect(0, 0, 40, 40);
    /**
     * Method: public draw
     * Parameters: void
     * Description: Draws the rock obstacle on scene
     **/
  }
}
