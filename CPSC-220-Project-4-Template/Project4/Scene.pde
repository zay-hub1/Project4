/**
 *      Author: Isaiah Foreman, LaTorres, Maks Zielanski
 *      Course: CPSC 220
 *  Instructor: Prof. Morales
 *     Created: 2026-04-15
 *         Due: 2026-05-10
 *  Assignment: Project 4
 *        File: Scene.pde
 * Description: The game scene that handles each room
 *              and all objects within those rooms,
 *              including the player and enemies
 *
 *              - procedural generation (doors, enemies, items, obstacles)
 *              - player and enemy turn logic
 *              - combat and movement validation
 *              - level progression and scaling difficulty
 *              - game over state with delayed reset
 *
 * Additional Features:
 *              - Randomized door generation (not always 4 exits)
 *              - Enemy spawn balancing (avoids unfair proximity)
 *              - Sound effects for combat, items, and doors
 */
import java.util.*;

/**
 * Class: Scene
 * Represents a dungeon room and controls all gameplay logic
 * including actors, objects, and turn execution.
 */

class Scene {

  /* Constructor: public scene(JSONObject data)
   * Parameter: JSONObject data - saved scene data
   * return: void
   * Description: initializes a new random dungeon.
   */

  public JSONObject serialize() {
    JSONObject data = new JSONObject();

    data.setInt("roomWidth", this.roomWidth);
    data.setInt("roomHeight", this.roomHeight);

    return data;
  }

  private boolean gameOver = false;
  private int gameOverTimer = 0; // frames to show text
  private int level =1;
  private int roomWidth;
  private int roomHeight;
  private WorldObject[][] room;
  private Direction entry;
  private Player player;
  private LinkedList<Actor> enemies;
  private HashMap<WorldObject, Position> positions;
  private HashMap<Direction, Position> doors;

  public Scene() {
    Direction[] directions = Direction.values();
    Direction direction = directions[int(random(directions.length))];

    this.player = new Player(direction);
    this.reset(direction);
  }

  public Scene(JSONObject data) {
    Direction[] directions = Direction.values();
    Direction direction = directions[int(random(directions.length))];

    this.player = new Player(direction);
    this.reset(direction);
  }

  /**
   *      Method: private reset()
   *  Parameters: Direction entry - The direction from which
   *                                the player entered the room
   *      Return: void
   * Description: Resets the room to a random state
   */

  private void reset(Direction entry) {
    if (entry == null) {
      return;
    }

    this.entry = entry;

    this.roomWidth = 11;
    this.roomHeight = 9;

    this.room = new WorldObject[roomWidth][roomHeight];
    this.positions = new HashMap<WorldObject, Position>();
    this.enemies = new LinkedList<Actor>();
    this.doors = new HashMap<Direction, Position>();

    // make sure player exists
    if (this.player == null) {
      this.player = new Player(entry.inverse());
    }



    for (Direction direction : Direction.values()) {

      //Always add entry door
      if (direction == entry.inverse()) {
        addDoor(direction);
        continue;
      }

      //Random chance for other doors
      if (random(1) < 0.6) {
        addDoor(direction);
      }
    }

    //Make sure atleast one extra door exists
    if (this.doors.size() <= 1) {
      Direction[] dirs = Direction.values();
      Direction randomDir;

      do {
        randomDir = dirs[int(random(dirs.length))];
      } while (randomDir == entry.inverse());

      addDoor(randomDir);
    }


    Position doorPos = this.doors.get(entry.inverse());

    Position start;

    if (doorPos == null) {
      start = new Position(roomWidth / 2, roomHeight / 2, this);
    } else {

      int px = doorPos.getX() + entry.x;
      int py = doorPos.getY() + entry.y;

      start = new Position(px, py, this);
    }

    this.positions.put(this.player, start);
    this.room[start.getX()][start.getY()] = this.player;

    Position playerPos = this.positions.get(this.player);

    //random obstacles
    for (int x = 0; x < this.roomWidth; ++x) {
      for (int y = 0; y < this.roomHeight; ++y) {

        //skip filled tiles
        if (this.room[x][y] != null) {
          continue;
        }

        //skip door tiles
        boolean isDoor = false;

        for (Position door : this.doors.values()) {
          if (door.getX() == x && door.getY() == y) {
            isDoor = true;
            break;
          }
        }

        if (isDoor) {
          continue;
        }

        // % chance to place obstacle
        if (random(1) < 0.05) {
          this.room[x][y] = new Rock(x, y);
        }
      }
    }


    // obstacles
    for (int i = 0; i < 7; i++) {
      int x = int(random(roomWidth));
      int y = int(random(roomHeight));

      if (room[x][y] == null && hasOpenNeighbor(x, y)) {

        // prevent placing on doors
        boolean isDoor = false;
        for (Position door : this.doors.values()) {
          if (door.getX() == x && door.getY() == y) {
            isDoor = true;
            break;
          }
        }

        if (isDoor) continue;

        // prevent placing on player
        if (playerPos != null && playerPos.getX() == x && playerPos.getY() == y) {
          continue;
        }

        room[x][y] = new Rock(x, y);
      }
    }

    // potions
    for (int i = 0; i < 3; i++) {
      int x = int(random(roomWidth));
      int y = int(random(roomHeight));

      if (room[x][y] == null) {

        boolean isDoor = false;
        for (Position door : this.doors.values()) {
          if (door.getX() == x && door.getY() == y) {
            isDoor = true;
            break;
          }
        }

        if (isDoor) continue;

        // prevent placing on player
        if (playerPos != null && playerPos.getX() == x && playerPos.getY() == y) {
          continue;
        }

        room[x][y] = new Potion(x, y);
      }
    }

    // Swords
    for (int i = 0; i < 2; i++) {
      int x = int(random(roomWidth));
      int y = int(random(roomHeight));

      if (room[x][y] == null) {

        // prevent placing on doors
        boolean isDoor = false;
        for (Position door : this.doors.values()) {
          if (door.getX() == x && door.getY() == y) {
            isDoor = true;
            break;
          }
        }

        if (isDoor) continue;

        // prevent placing on player
        if (playerPos != null && playerPos.getX() == x && playerPos.getY() == y) {
          continue;
        }

        room[x][y] = new Sword(x, y);
      }
    }

    // enemies
    int spawned = 0;

    while (spawned < 3) {
      int x = int(random(roomWidth));
      int y = int(random(roomHeight));

      boolean tooClose = false;

      if (playerPos != null) {
        tooClose =
          abs(playerPos.getX() - x) <= 2 &&
          abs(playerPos.getY() - y) <= 2;
      }

      if (room[x][y] == null && !tooClose && hasOpenNeighbor(x, y)) {

        // prevent placing on doors
        boolean isDoor = false;
        for (Position door : this.doors.values()) {
          if (door.getX() == x && door.getY() == y) {
            isDoor = true;
            break;
          }
        }

        if (isDoor) continue;

        int health = 10 + level * 3; // scale health

        Skeleton s = new Skeleton(health, 10, Direction.SOUTH);

        room[x][y] = s;
        enemies.add(s);
        positions.put(s, new Position(x, y, this));

        spawned++;
      }
    }
  }

  /**
   *      Method: private updateActions()
   *  Parameters: Actor actor - The actor whose actions will be
   *                            updated to reflect their validity
   *      Return: void
   * Description: Updates an actor's list of valid actions
   */

  private void updateActions(Actor actor) {
    for (Action action : Action.values()) {
      actor.setActionValidity(action, this.isActionValid(actor, action));
    }
  }

  /**
   *      Method: public tryTurn()
   *  Parameters: void
   *      Return: boolean - Whether or not the state of
   *                        the scene should be saved
   * Description: Tries to execute a single turn of game
   *              logic for the player and all enemies
   */

  public boolean tryTurn() {

    if (gameOverTimer > 0) {
      gameOverTimer--;

      if (gameOverTimer == 0) {

        // ✅ NOW reset AFTER delay
        Direction[] directions = Direction.values();
        Direction direction = directions[int(random(directions.length))];

        this.player = new Player(direction);
        this.reset(direction);

        gameOver = false;
      }

      return false; // freeze game during game over
    }

    // If the player is dead, reset the room
    if (this.player == null || this.player.getHealth() == 0) {

      //trigger game over state
      if (!gameOver) {
        gameOver = true;
        gameOverTimer = 120;
        level = 1;
      }

      return false;
    }

    // Get the player's action
    this.updateActions(this.player);

    Action action = this.player.getAction();

    // If no action was chosen, do nothing
    if (action == null) {
      return false;
    }

    // If the player attacked or entered a new room, save the game
    Position door = this.doors.get(action.direction);
    boolean save = action.isAttack || door != null && door.equals(this.positions.get(this.player)) && this.enemies.size() == 0;

    // If the action failed, do nothing
    if (!this.tryAction(this.player, action)) {
      return false;
    }

    for (int i = 0; i < this.enemies.size(); ++i) {
      Actor enemy = this.enemies.get(i);

      // Remove dead enemies
      if (enemy.getHealth() == 0) {
        this.enemies.remove(i--);
        continue;
      }

      // Get the enemy's action
      this.updateActions(enemy);
      action = enemy.getAction();

      if (this.tryAction(enemy, action) && action.isAttack) {
        // If the player died, reset the room and save the game
        if (player.getHealth() == 0) {
          if (!gameOver) {
            gameOver = true;
            gameOverTimer = 300;
            level = 1;
          }

          return false;
        }

        // If the enemy attacked, save the game
        save = true;
      }
    }

    this.updateActions(this.player);
    return save;
  }

  /**
   *      Method: private tryAction()
   *  Parameters: Actor  actor  - The actor performing the action
   *              Action action - The action being performed
   *      Return: boolean - Whether or not the action succeeded
   * Description: Tries to execute an action on behalf of an actor
   */

  private boolean tryAction(Actor actor, Action action) {
    if (!isActionValid(actor, action)) {
      return false;
    }

    Position position = this.positions.get(actor);

    if (position == null) {
      return false;
    }

    // Get the position of the cell being targeted
    int x = position.getX() + action.direction.x;
    int y = position.getY() + action.direction.y;

    // Check if the player can enter a new room
    if (!action.isAttack && actor == this.player && action.direction != this.entry.inverse() && this.enemies.size() == 0) {
      Position door = this.doors.get(action.direction);

      if (door != null && door.equals(position)) {
        doorSound.play();
        level++;
        this.reset(action.direction);
        return true;
      }
    }

    // Check if the actor is facing a wall
    if (x < 0 || x >= this.roomWidth || y < 0 || y >= this.roomHeight) {
      return false;
    }

    // Check if the actor can attack
    if (action.isAttack) {
      boolean isActionValid = this.room[x][y] instanceof Actor && (actor == this.player || this.room[x][y] == this.player);

      if (isActionValid) {
        Actor enemy = (Actor)this.room[x][y];

        if (enemy.getHealth() > 0) {
          enemy.updateHealth(-actor.getDamage());


          // MAKS ADDED THIS BELOW
          if (actor == this.player) {
            attackSound.play(); // player attacking
          } else {
            hitSound.play(); // player getting hit
          }
        } else {
          this.room[x][y] = null;
        }
      }

      return isActionValid;
    }

    // Check if the actor can interact with an interactable object
    if (actor == this.player && this.room[x][y] instanceof Interactable) {
      Interactable interactable = (Interactable)this.room[x][y];

      if (!interactable.interact(this.player)) {
        return false;
      }
    } else if (this.room[x][y] != null) {
      return false;
    }

    // Check if the actor can move
    this.room[x][y] = actor;
    this.room[position.getX()][position.getY()] = null;
    actor.facing = action.direction;
    position.move(action.direction);
    return true;
  }

  /**
   *      Method: private isActionValid()
   *  Parameters: Actor  actor  - The actor performing the action
   *              Action action - The action being performed
   *      Return: boolean - Whether or not the action is valid
   * Description: Determines if an actor's action would be valid
   */

  private boolean isActionValid(Actor actor, Action action) {
    if (actor == null || action == null || actor.getHealth() == 0) {
      return false;
    }

    Position position = this.positions.get(actor);

    if (position == null) {
      return false;
    }

    // Get the position of the cell being targeted
    int x = position.getX() + action.direction.x;
    int y = position.getY() + action.direction.y;

    // Check if the player can enter a new room
    if (!action.isAttack && actor == this.player && action.direction != this.entry.inverse() && this.enemies.size() == 0) {
      Position door = this.doors.get(action.direction);

      if (door != null && door.equals(position)) {
        return true;
      }
    }

    // Check if the actor is facing a wall
    if (x < 0 || x >= this.roomWidth || y < 0 || y >= this.roomHeight) {
      return false;
    }

    // Check if the actor can attack
    if (action.isAttack) {
      return this.room[x][y] instanceof Actor && (actor == this.player || this.room[x][y] == this.player);
    }

    // Check if the actor can move
    return this.room[x][y] == null || this.room[x][y] instanceof Interactable && actor == this.player;
  }

  /**
   *      Method: public getRoomWidth()
   *  Parameters: void
   *      Return: int - The width of the room, in number of columns
   * Description: Returns the width of the room
   */

  public int getRoomWidth() {
    return roomWidth;
  }

  /**
   *      Method: public getRoomHeight()
   *  Parameters: void
   *      Return: int - The height of the room, in number of rows
   * Description: Returns the height of the room
   */

  public int getRoomHeight() {
    return roomHeight;
  }


  /**
   * Adds a door at the correct position based on direction.
   */

  private void addDoor(Direction direction) {

    switch (direction) {

    case NORTH:
      this.doors.put(direction,
        new Position(roomWidth / 2, 0, this));
      break;

    case SOUTH:
      this.doors.put(direction,
        new Position(roomWidth / 2, roomHeight - 1, this));
      break;

    case EAST:
      this.doors.put(direction,
        new Position(roomWidth - 1, roomHeight / 2, this));
      break;

    case WEST:
      this.doors.put(direction,
        new Position(0, roomHeight / 2, this));
      break;
    }
  }

  /**
   * Checks if at least one adjacent tile is empty.
   * Used to prevent blocking paths with obstacles or enemies.
   */

  private boolean hasOpenNeighbor(int x, int y) {
    int[][] dirs = {
      {0, -1}, {0, 1}, {1, 0}, {-1, 0}
    };

    for (int[] d : dirs) {
      int nx = x + d [0];
      int ny = y + d [1];

      if (nx >= 0 && nx < roomWidth && ny >= 0 && ny < roomHeight) {
        if (room[nx][ny] == null) {
          return true;
        }
      }
    }
    return false;
  }

  /**
   *      Method: public keyPressed()
   *  Parameters: void
   *      Return: void
   * Description: Passes key press events to the player
   */

  public Player getPlayer() {
    return this.player;
  }

  public int getLevel() {
    return this.level;
  }

  public boolean isGameOver() {
    return this.gameOver;
  }

  public void keyPressed() {
    if (this.player != null) {
      this.player.keyPressed();
    }
  }

  /**
   *      Method: public keyReleased()
   *  Parameters: void
   *      Return: void
   * Description: Passes key release events to the player
   */

  public void keyReleased() {
    if (this.player != null) {
      this.player.keyReleased();
    }
  }


  /**
   *      Method: public draw()
   *  Parameters: void
   *      Return: void
   * Description: Draws the scene
   */

  public void draw() {
    float size = min((float)width / (this.roomWidth + 2), (float)height / (this.roomHeight + 2));

    float offsetX = (width - this.roomWidth * size) / 2;
    float offsetY = (height - this.roomHeight * size) / 2;

    for (int x = 0; x < this.roomWidth; ++x) {
      for (int y = 0; y < this.roomHeight; ++y) {

        float drawX = offsetX + x * size;
        float drawY = offsetY + y * size;

        fill(50);
        stroke(100);
        rect(drawX, drawY, size, size);

        Position current = new Position(x, y, this);

        // draw doors
        for (Direction direction : this.doors.keySet()) {
          Position door = this.doors.get(direction);

          if (door != null && door.equals(current)) {

            // diff color if doors are locked
            boolean locked = this.enemies.size() > 0;



            // entry door diff color
            if (direction == this.entry.inverse()) {
              fill(185, 80, 0); // darker brown = where you came from
            } else if (locked) {
              fill(165, 60, 0); // even darker brown = locked
            } else {
              fill(255, 150, 0); // brown = normal doors
            }

            rect(drawX + size * 0.25, drawY + size * 0.25, size * 0.5, size * 0.5);

            if (locked && direction != this.entry.inverse()) {
              fill(50);
              rectMode(CENTER);
              rect(drawX + size * 0.5, drawY + size * 0.5, size * 0.2, size * 0.25);
              rectMode(CORNER);

              fill(0);
              rectMode(CENTER);
              rect(drawX + size * 0.5, drawY + size * 0.5, size * 0.06, size * 0.1);
              rectMode(CORNER);
            }
          }
        }

        // draw objects
        if (this.room[x][y] != null) {
          pushMatrix();
          translate(drawX + size / 2, drawY + size / 2);
          this.room[x][y].draw();
          popMatrix();
        }
      }
    }
  }
}
