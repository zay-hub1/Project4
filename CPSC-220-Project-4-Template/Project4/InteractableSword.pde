/**
 *      Author: LaTorres
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

    public Sword(int x, int y) {}

    public Sword(JSONObject json) {}

    public JSONObject serialize() {
        JSONObject obj = new JSONObject();
        obj.setString("type", "Sword");
        return obj;
    }

    public void draw() {
        fill(200, 200, 50);
        rect(0, 0, 25, 25);
    }

    public boolean interact(Player player) {
        player.increaseDamage(2);
        return true;
    }
}
