/**
 *      Author: LaTorres
 *      Course: CPSC 220
 *  Instructor: Prof. Morales
 *     Created: 2026-04-15
 *         Due: 2026-05-10
 *  Assignment: Project 4
 *        File: EnemySkeleton.pde
 * Description: Enemy actions
 */

import java.util.ArrayList;

class Skeleton extends Actor {
  
  Skeleton(int health, int damage, Direction facing){
    super(health, damage, facing);
  }
  /**
  * Constructor: public Skeleton()
  * Parameters: int health - Skeleton health value
  *             int damage - Skeleton damage value
  *             Direction facing - starting direction
  * Discription: creates a skeleton enemy actor
  **/
  
  Skeleton(JSONObject json) {
    super(json);
  }
  
  public JSONObject serialize() {
    
    JSONObject obj = super.serialize();
    obj.setString("type", "Skeleton");
    return obj;
    
  }
  /**
  * Method: public serialize()
  * Parameters: void
  * Return: JSONObject - serialized enemy data
  * Description: converts the skeleton actor into JSON format
  **/
  
  public void draw() {
    super.draw();
    
    fill(0, 200, 0);
    rect(5, 5, 30, 30);
    
  }
  /**
  * Method: public draw()
  * Parameters: void
  * Return: void
  * Description: draws the skeleton enemy and health bar
  **/
  
  public Action getAction() {
    //attack first
    for (Action action : Action.values()) {
      if (action.isAttack && getActionValidity(action)) {
        return action;
      }
    }
    /**
    * Method: public getAction()
    * Parameters: void
    * Return: Action
    * Description: Determines the skeleton enemy's next move/attack
    **/
    
    //random moves
    if (moves.size() > 0) {
      return moves.get(int(random(moves.size())));
    }
    
    return null;
  }
}
