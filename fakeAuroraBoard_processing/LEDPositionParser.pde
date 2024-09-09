import de.bezier.data.sql.SQLite;

public class LEDPositionParser {
  private final int BOLD_SET_ID = 1;
  private final int SCREW_SET_ID = 20;
  private final int LAYOUT_ID = 1;
  private final int PRODUCT_SIZE_ID = 10;
  private final int PRODUCT_ID = 1;
  
  // Maps aurora board position numbers to LED coordinates.
  private HashMap<Integer, int[]> boldPositions = new HashMap<Integer, int[]>();
  private HashMap<Integer, int[]> screwPositions = new HashMap<Integer, int[]>();
  
  // Constructor will open the database then map position numbers to x,y coordinates.
  public LEDPositionParser(PApplet parent) {
    SQLite db = new SQLite(parent, "database.db");
    if (!db.connect()) {
      throw new RuntimeException("Failed to open SQLite database!");
    }
    
    String sql = """
    SELECT holes.x/8 - 1 AS x, 18 - (holes.y/8 - 1) AS y, leds.position AS position FROM leds
    INNER JOIN holes ON leds.hole_id = holes.id INNER JOIN placements ON placements.hole_id = holes.id INNER JOIN holds ON holds.id = placements.hold_id
    WHERE holds.set_id = %d AND placements.layout_id = %d AND leds.product_size_id = %d AND holes.product_id = %d
    """;
    db.query(sql, BOLD_SET_ID, LAYOUT_ID, PRODUCT_SIZE_ID, PRODUCT_ID);
    while (db.next()) {
      boldPositions.put(db.getInt("position"), new int[] { db.getInt("x"), db.getInt("y") });
    }
    
    String sql2 = """
    SELECT holes.x/8 - 1 AS x, 18 - (holes.y/8 - 1) AS y, leds.position AS position FROM leds
    INNER JOIN holes ON leds.hole_id = holes.id INNER JOIN placements ON placements.hole_id = holes.id INNER JOIN holds ON holds.id = placements.hold_id
    WHERE holds.set_id = %d AND placements.layout_id = %d AND leds.product_size_id = %d AND holes.product_id = %d
    """;
    db.query(sql2, SCREW_SET_ID, LAYOUT_ID, PRODUCT_SIZE_ID, PRODUCT_ID);
    while (db.next()) {
      screwPositions.put(db.getInt("position"), new int[] { db.getInt("x"), db.getInt("y") });
    }
    
    db.close();
  }
  
  // Returns 2-element array of [x, y] coordinates for the specified position number
  public int[] getBoldCoordsFromPosition(Integer position) {
    return boldPositions.get(position);
  }
  
  public int[] getScrewCoordsFromPosition(Integer position) {
  return screwPositions.get(position);
  }
};
