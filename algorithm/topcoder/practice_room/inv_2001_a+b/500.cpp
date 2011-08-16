// =====================================================================================
// 
//       Filename:  500.cpp
// 
//    Description: problem Statement
//        
//    THIS PROBLEM WAS TAKEN FROM THE SEMIFINALS OF THE TOPCODER INVITATIONAL
//    TOURNAMENT
//
//    Class Name: Tothello
//    Method Name: bestMove
//    Parameters: String[], String[], String
//    Returns: int
//    Method signature (be sure your method is public):  int bestMove(String[]
//    redPieces, String[] blackPieces, String whoseTurn);
//
//
//    PROBLEM STATEMENT
//    The game Tothello is a TopCoder modified version of the board game Othello.
//    The game is played on an 8 x 8 grid with two players, Black and Red.  The
//    players alternate turns placing one piece representing their color in one empty
//    square of the grid.  When the Red player puts a red piece down, any black
//    pieces that end up between the piece that was placed on the board and any other
//    red piece already on the board should be changed to red.  If the change in
//    color from black to red of any piece on the board causes other black pieces to
//    lie between two red pieces, those black pieces should also be changed to red.
//    The changing of black pieces will continue until no one black piece lies
//    between two red pieces.  The manner that pieces change color apply when the
//    Black player places a piece on the grid, however, the pieces would then change
//    from red to black.  A player also has the option of passing - not putting any
//    pieces down - on his turn, in which case the other player just gets to go twice
//    in a row.
//
//    You are to write a program that helps a player determine their best possible
//    move - the move that results in the most pieces being that player's color at
//    the end of the move. 
//
//    Implement a class Tothello that contains a method bestMove.  bestMove inputs
//    the current state of the grid before a specified player's move and outputs the
//    number of the player's pieces on the board as a result of the player's best
//    move.  
//
//    NOTES
//    - redPieces is a String[] representing the current positions of red pieces on
//    the board.  
//    - blackPieces is a String[] representing the current positions of black pieces
//    on the board.  
//    - The board is an 8x8 grid with the columns referred to by the uppercase
//    letters A-H and the rows referred to by the numbers 1-8 (inclusive).  The
//    column is specified before the row.  A1 is in the upper left.  H8 is in the
//    lower right. 
//    - redPieces and blackPieces are not necessarily the same length (players may
//    have passed on moves).
//    - A black piece is between two red pieces if a red piece can be found before an
//    empty square on either side by following the horizontal, vertical, or either
//    diagonal out from the Black piece.  For example:
//
//    - - - R - - - -
//    - - - B - - - -
//    - - - B - - - -    All three Black pieces are between two red pieces.
//    - - - B - - - -
//    - - - R - - - -
//
//
//    - - - R - - - -
//    - - - B B - - -
//    - - - B - B - -   All four Black pieces are between two Red pieces.
//    - - - R R R R R
//
//
//    - - - R - - - -
//    - - - B R - - -
//    - - - - - - - -   The Black piece is not between two Red pieces.
//    - - - R R - - -
//
//
//    R R R R R R R R
//    R - - - - - - R
//    R - B B - B - R
//    R - B B B B - R   None of the Black pieces are between two Red pieces.
//    R - - - - - - R
//    R R R R R R R R
//
//    TopCoder will ensure the validity of the inputs.  Inputs are valid if all of
//    the following criteria are met:
//    - Both redPieces and blackPieces contain between 0 and 50 elements (inclusive).
//    - All elements of redPieces and blackPieces consist of uppercase letters A-H
//    and numbers 1-8 (inclusive).
//    - All elements of redPieces and blackPieces are in the form of letter-number
//    pairs with each letter representing the column and each number representing the
//    row of the piece's position (i.e. "A2" where 'A' is the column and '2' is the
//    row of the piece's position).
//    - whoseTurn is a String that is equal to either "Red" or "Black" representing
//    the player for which the method is being run.
//    - The current state of the board represented by redPieces and blackPieces
//    contains no red pieces between any black pieces and no black pieces between any
//    red pieces (a state where there were black pieces between red pieces is
//    impossible at the start of a move, assuming the game has been played
//    correctly.)  
//    - The elements are unique in redPieces and blackPieces, and redPieces and
//    blackPieces do not contain any of the same elements.
//    - The game board must start with at least one unoccupied space.
//
//    EXAMPLES
//    If redPieces=[C2,C3,C4,C5,D4,E4,F2,F3,F4,F5,G6] and
//    blackPieces=[B1,E1,G1,C6,H7,G4] and whoseTurn="Black", 
//    Before the player's move, the board is:
//
//        A B C D E F G H
//      1 - B - - B - B -
//      2 - - R - - R - -
//      3 - - R - - R - -
//      4 - - R R R R B -  
//      5 - - R - - R - -
//      6 - - B - - - R - 
//      7 - - - - - - - B
//      8 - - - - - - - -
//
//      Black's best move is C1, which results in:
//
//        A B C D E F G H       A B C D E F G H       A B C D E F G H       A B C D E F G H
//      1 - B - - B - B -     1 - B B - B - B -     1 - B B - B - B -     1 - B B - B - B - 
//      2 - - R - - R - -     2 - - B - - R - -     2 - - B - - R - -     2 - - B - - R - -
//      3 - - R - - R - -     3 - - B - - R - -     3 - - B - - R - -     3 - - B - - R - -
//      4 - - R R R R B - --> 4 - - B R R R B - --> 4 - - B B B B B - --> 4 - - B B B B B -
//      5 - - R - - R - -     5 - - B - - R - -     5 - - B - - R - -     5 - - B - - B - -
//      6 - - B - - - R -     6 - - B - - - R -     6 - - B - - - R -     6 - - B - - - B -
//      7 - - - - - - - B     7 - - - - - - - B     7 - - - - - - - B     7 - - - - - - - B
//      8 - - - - - - - -     8 - - - - - - - -     8 - - - - - - - -     8 - - - - - - - -
//
//      There end up being 16 black pieces, so the method should return 16.
//
//      If redPieces=[A1,B8,C6,C8,D8] and blackPieces=[B2,C2,C3,C4,C5] and
//      whoseTurn="Red", Red's best move is C1, and the method should return 11.
//
//
//
//      Definition
//          
//      Class:
//      Tothello
//      Method:
//      bestMove
//      Parameters:
//      vector <string>, vector <string>, string
//      Returns:
//      int
//      Method signature:
//      int bestMove(vector <string> param0, vector <string> param1, string param2)
//      (be sure your method is public)
// 
// 
// =====================================================================================


#include	<string>
#include	<vector>

using std::string;
using std::vector;

class Tothello
{
public:
      int bestMove(vector <string> param0, vector <string> param1, string param2);
private:
//      int 
};

int Tothello::bestMove(vector <string> param0, vector <string> param1, string param2)
{
    return 0;
}


int main ( int argc, char *argv[] )
{
    return 0;
}				// ----------  end of function main  ----------
