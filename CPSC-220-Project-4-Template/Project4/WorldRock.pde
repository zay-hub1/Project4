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

    public void draw() {
        fill(100);
        rect(0, 0, 40, 40);
    }
}
