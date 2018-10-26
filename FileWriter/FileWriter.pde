//
Table table;

void setup() {
  //loads the master score file on start up
  table = loadTable("data/scores.csv", "header");
  table.setColumnType("score", Table.INT); // sets the scores as integers so they are parsed correctly when ordering the table.
  //eraseScores(); // use this to create a clean file (hopefully just for testing)
}

void draw(){
}

void keyPressed(){
  // when a player finishes the game (when the sound file stops), add their score to the main score file.
  // save the player's number (playerNum) and read which row it is in after reordering.
  int score = 699;
  TableRow newRow = table.addRow();
  int playerNum = table.getRowCount();
  newRow.setInt("playerNum", playerNum);
  newRow.setString("id", "AAA"); // should be changeable so that they can enter their ranking if it's a high score
  newRow.setInt("score", score);
  table.sortReverse(int(2)); // sorts the table by scores. if two players have the same score, sort them with the highest playerNum first!
  saveTable(table, "data/scores.csv"); // not sure if this should be before the re-sorting.
  int ranking = (table.findRowIndex(str(playerNum), 0)) + 1; // get index of thier row
  println("Your ranking is " + ranking); // show the row number in the newly sorted table
  println("TOP TEN");
  showTopScores();
}

//------ Create new CSV file or erase current one
void eraseScores() {
  table = new Table();
  table.addColumn("playerNum");
  table.addColumn("id");
  table.addColumn("score", Table.INT);
  TableRow newRow = table.addRow();
  newRow.setInt("playerNum", table.getRowCount() - 1);
  newRow.setString("id", "ERI");
  newRow.setInt("score", 145);
  saveTable(table, "data/scores.csv");
}

//------ Show the top 10 scores by ID and score
void showTopScores() {
  for (int i = 0; i < 10; i++) {
    String id = table.getString(i, 1);
    int score = table.getInt(i, 2);
    println(id + " " + score);
  }
}

//------ Show all scores
void showAllScores() {
 println(table.getRowCount() + " total scores"); 
  for (TableRow row : table.rows()) {
    int playerNum = row.getInt("playerNum");
    String id = row.getString("id");
    int score = row.getInt("score");
    println(id + " ( player number" + playerNum + ") has a score of " + score);
  }
}



//------ Attempts to create a system that orders scores that are the same. Annoying because even when order is changed it's glitchy. Maybe not necessary anyways.
/*
//saveTable(table, "data/scores.csv");
  
  // CHECK AGAINST CURRENT SCORE. 
  // If other rows have the same score, overwrite them? or reorder them somehow?
  //println(table.findRowIndices(str(score), 2));// score column Return a list of rows that contain the String passed in. If there are no matches, a zero length array will be returned (not a null array).
  // or findRowIterator(str(score), 2); Finds multiple rows that contain the given value
  // or matchRowIndices(str(score), 2); Return a list of rows that contain the String passed in. If there are no matches, a zero length array will be returned (not a null array).
  
  // replace the id (and playerNum?) of the top one with your own
  replace(String orig, String replacement, int col)
                    
  newRow.setInt("playerNum", playerNum);
  newRow.setString("id", "AAA"); // should be changeable so that they can enter their ranking if it's a high score
  newRow.setInt("score", score);
  */
