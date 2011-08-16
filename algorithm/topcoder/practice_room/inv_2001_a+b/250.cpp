// =====================================================================================
// 
//       Filename:  250.cpp
// 
//    Description:  blem Statement
//        
//    THIS PROBLEM WAS TAKEN FROM THE SEMIFINALS OF THE TOPCODER INVITATIONAL
//    TOURNAMENT
//
//    DEFINITION
//    Class Name: MatchMaker
//    Method Name: getBestMatches
//    Paramaters: String[], String, int
//    Returns: String[]
//    Method signature (be sure your method is public):  String[]
//    getBestMatches(String[] members, String currentUser, int sf);
//
//    PROBLEM STATEMENT
//    A new online match making company needs some software to help find the "perfect
//    couples".  People who sign up answer a series of multiple-choice questions.
//    Then, when a member makes a "Get Best Mates" request, the software returns a
//    list of users whose gender matches the requested gender and whose answers to
//    the questions were equal to or greater than a similarity factor when compared
//    to the user's answers.
//
//    Implement a class MatchMaker, which contains a method getBestMatches.  The
//    method takes as parameters a String[] members, String currentUser, and an int
//    sf:
//    - members contains information about all the members.  Elements of members are
//    of the form "NAME G D X X X X X X X X X X" 
//       * NAME represents the member's name
//          * G represents the gender of the current user. 
//             * D represents the requested gender of the potential mate. 
//             * Each X indicates the member's answer to one of the multiple-choice
//             questions.  The first X is the answer to the first question, the second is the
//             answer to the second question, et cetera. 
//             - currentUser is the name of the user who made the "Get Best Mates" request.  
//             - sf is an integer representing the similarity factor.
//
//             The method returns a String[] consisting of members' names who have at least sf
//             identical answers to currentUser and are of the requested gender.  The names
//             should be returned in order from most identical answers to least.  If two
//             members have the same number of identical answers as the currentUser, the names
//             should be returned in the same relative order they were inputted.
//
//             TopCoder will ensure the validity of the inputs.  Inputs are valid if all of
//             the following criteria are met:
//             - members will have between 1 and 50 elements, inclusive.
//             - Each element of members will have a length between 7 and 44, inclusive.
//             - NAME will have a length between 1 and 20, inclusive, and only contain
//             uppercase letters A-Z.
//             - G can be either an uppercase M or an uppercase F.
//             - D can be either an uppercase M or an uppercase F.
//             - Each X is a capital letter (A-D).
//             - The number of Xs in each element of the members is equal.  The number of Xs
//             will be between 1 and 10, inclusive. 
//             - No two elements will have the same NAME.
//             - Names are case sensitive.
//             - currentUser consists of between 1 and 20, inclusive, uppercase letters, A-Z,
//             and must be a member.
//             - sf is an int between 1 and 10, inclusive.
//             - sf must be less than or equal to the number of answers (Xs) of the members.
//
//             NOTES
//             The currentUser should not be included in the returned list of potential mates.
//
//
//             EXAMPLES
//
//             For the following examples, assume members =
//             {"BETTY F M A A C C",
//              "TOM M F A D C A",
//               "SUE F M D D D D",
//                "ELLEN F M A A C A",
//                 "JOE M F A A C A",
//                  "ED M F A D D A",
//                   "SALLY F M C D A B",
//                    "MARGE F M A A C C"}
//
//                    If currentUser="BETTY" and sf=2, BETTY and TOM have two identical answers and
//                    BETTY and JOE have three identical answers, so the method should return
//                    {"JOE","TOM"}.
//
//                    If currentUser="JOE" and sf=1, the method should return
//                    {"ELLEN","BETTY","MARGE"}.
//
//                    If currentUser="MARGE" and sf=4, the method should return [].
//                    Definition
//                        
//                    Class:
//                    MatchMaker
//                    Method:
//                    getBestMatches
//                    Parameters:
//                    vector <string>, string, int
//                    Returns:
//                    vector <string>
//                    Method signature:
//                    vector <string> getBestMatches(vector <string> param0, string param1, int param2)
//                    (be sure your method is public)
//                        
//
//                    This problem statement is the exclusive and proprietary property of TopCoder, Inc. Any unauthorized use or reproduction of this information without the prior written consent of TopCoder, Inc. is strictly prohibited. (c)2003, TopCoder, Inc. All rights reserved.
// 
//        Version:  1.0
//        Created:  08/13/2011 08:56:07 AM
//       Revision:  none
//       Compiler:  g++
// 
//         Author:  Raymond Wen (), 
//        Company:  
// 
// =====================================================================================


#include	<vector>
#include	<string>

using std::vector;
using std::string;

vector<string> split_string(const string& str, char splitter)
{
    vector<string> result;
    int index = 0, pos = 0;
    while(string::npos != (index = str.find_first_of(splitter, pos)))
    {
        result.push_back(str.substr(pos, index-pos));
        pos = index+1;
    }
    if(pos != str.length())
        result.push_back(str.substr(pos));
    return result;
}

class MatchMaker
{
public:
    vector<string> getBestMatches(vector <string> param0, string param1, int param2);
};

vector<string> MatchMaker::getBestMatches(vector <string> param0, string param1, int param2)
{
    vector<string> result;
    vector<string> ele = split_string(param1, ' '); 
    for(vector<string>::const_iterator ite_input = param0.begin(); 
            ite_input != param0.end(); ++ite_input)
    {
        vector<string> e = split_string(*ite_input, ' ');
        if(ele[0] == e[0])
            continue;
        if(ele[2] != e[1])
            continue;
        int match_count = 0, i = 2;
        while(i < e.size() && i < ele.size())
        {
            if(e[i] == ele[i])
                ++match_count;
            ++i;
        }
        if(match_count >= param2)
            result.push_back(e[0]);
    }
    return result;
}

#include	<iostream>

int main ( int argc, char *argv[] )
{
    MatchMaker mm;
    string str("BETTY F M A A C C");
    vector<string> input;
    input.push_back("BETTY F M A A C C");
    input.push_back("TOM M F A D C A");
    input.push_back("SUE F M D D D D");
    input.push_back("ELLEN F M A A C A");
    input.push_back("JOE M F A A C A");
    input.push_back("ED M F A D D A");
    input.push_back("SALLY F M C D A B");
    input.push_back("MARGE F M A A C C");
    vector<string> r = mm.getBestMatches(input, str, 2);
    using namespace std;
    cout << r.size() << endl;
    for(vector<string>::iterator i = r.begin(); i != r.end(); ++i)
        cout << *i << endl;
    return 0;
}				// ----------  end of function main  ----------
